import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

const PlanSchema = {
  name: "routine_plan",
  strict: true,
  schema: {
    type: "object",
    properties: {
      night_plan: {
        type: "object",
        properties: {
          theme: { type: "string", description: "2-5 word theme for tonight" },
          estimated_duration_minutes: { type: "integer" },
          recommended_bedtime: {
            type: "string",
            description: "HH:MM format",
          },
          steps: {
            type: "array",
            items: {
              type: "object",
              properties: {
                step_order: { type: "integer" },
                title: { type: "string" },
                intervention_id: { type: "string" },
                duration_minutes: { type: "integer" },
                instructions: { type: "string" },
                soundscape: { type: "string" },
              },
              required: [
                "step_order",
                "title",
                "intervention_id",
                "duration_minutes",
                "instructions",
                "soundscape",
              ],
              additionalProperties: false,
            },
          },
          wind_down_quote: {
            type: "string",
            description:
              "A calming, personalized 1-2 sentence message for the user",
          },
        },
        required: [
          "theme",
          "estimated_duration_minutes",
          "recommended_bedtime",
          "steps",
          "wind_down_quote",
        ],
        additionalProperties: false,
      },
      morning_plan: {
        type: "object",
        properties: {
          wake_time: { type: "string", description: "HH:MM format" },
          theme: {
            type: "string",
            description: "2-5 word theme for morning",
          },
          steps: {
            type: "array",
            items: {
              type: "object",
              properties: {
                step_order: { type: "integer" },
                title: { type: "string" },
                intervention_id: { type: "string" },
                duration_minutes: { type: "integer" },
                instructions: { type: "string" },
              },
              required: [
                "step_order",
                "title",
                "intervention_id",
                "duration_minutes",
                "instructions",
              ],
              additionalProperties: false,
            },
          },
          affirmation: {
            type: "string",
            description: "A motivating morning affirmation for the user",
          },
        },
        required: ["wake_time", "theme", "steps", "affirmation"],
        additionalProperties: false,
      },
    },
    required: ["night_plan", "morning_plan"],
    additionalProperties: false,
  },
};

const SYSTEM_PROMPT = `You are a sleep routine architect that creates personalized night and morning plans.

You receive:
1. Extracted context about the user's day (mood, stressors, energy, goals)
2. User preferences (experience style, sleep/wake times)
3. Available intervention registry

Create a night wind-down plan (3-4 steps, 15-25 minutes total) and morning activation plan (2-3 steps, 10-15 minutes total).

AVAILABLE INTERVENTIONS (use ONLY these IDs):
Night:
- INT_BREATH_478: 4-7-8 Breathing (5-8 min, best for anxiety/racing thoughts)
- INT_BREATH_BOX: Box Breathing (4-6 min, focus/reset)
- INT_PMR: Progressive Muscle Relaxation (10-15 min, physical tension)
- INT_BODY_SCAN: Body Scan (10-15 min, general stress)
- INT_GUIDED_IMAGERY: Guided Imagery (8-12 min, calming visualization)
- INT_THOUGHT_DUMP: Worry Brain Dump (5 min, high stressor load)
- INT_SOUND_RAIN: Gentle Rain (15-60 min, sleep onset)
- INT_SOUND_BROWN: Brown Noise (15-60 min, noise masking)
- INT_SOUND_NATURE: Nature Sounds (15-60 min, relaxation)
- INT_SOUND_PIANO: Soft Piano (15-30 min, calming instrumental)

Morning:
- INT_WAKE_LIGHT: Morning Light Exposure (10 min, circadian)
- INT_WAKE_HYDRATE: Morning Hydration (3 min, metabolism)
- INT_WAKE_STRETCH: Morning Stretch (5 min, physical activation)
- INT_WAKE_PRIMING: Goal Visualization (5 min, intention setting - experimental)

SOUNDSCAPE OPTIONS (for night steps): INT_SOUND_RAIN, INT_SOUND_BROWN, INT_SOUND_NATURE, INT_SOUND_PIANO, none

RULES:
1. Only use intervention IDs from the list above.
2. If energy_level is "wired_tired" with stressors, prioritize INT_THOUGHT_DUMP then INT_BREATH_478.
3. If energy_level is "exhausted", keep night plan short (≤15 min), use soundscape only.
4. Always end night with a sleep soundscape step.
5. Calculate recommended_bedtime to allow 7.5-8 hours before wake_time.
6. If wake_time is null, use "07:00" as default.
7. Align morning plan to support tomorrow_goals.
8. Keep wind_down_quote and affirmation warm, personal, and non-clinical.
9. Instructions should be conversational and clear, not clinical.
10. Do NOT claim any medical or therapeutic benefits.`;

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Auth
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing Authorization header" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Rate limit
    const { data: isAllowed } = await supabase.rpc("check_ai_rate_limit", {
      p_user_id: user.id,
      p_endpoint: "generate-plan",
      p_max_requests: 15,
      p_window_minutes: 60,
    });

    if (!isAllowed) {
      return new Response(
        JSON.stringify({ error: "Please try again in a bit." }),
        {
          status: 429,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 3. Parse request
    const body = await req.json();
    const { context, preferences } = body;

    if (!context) {
      return new Response(
        JSON.stringify({ error: "context is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 4. Build user message
    const userMessage = `
User Context:
- Mood: ${context.mood_context}
- Stressors: ${context.stressors?.join(", ") || "None"}
- Tomorrow's goals: ${context.tomorrow_goals?.join(", ") || "None specified"}
- Desired wake time: ${context.wake_time || "Not specified"}
- Sleep preference: ${context.sleep_preference}
- Energy level: ${context.energy_level}
- Desired experience: ${context.desired_experience}

User Preferences:
- Experience style: ${preferences?.experience_style || "calm"}
- Usual sleep time: ${preferences?.usual_sleep_time || "23:00"}
- Usual wake time: ${preferences?.usual_wake_time || "07:00"}

Create a personalized night wind-down plan and morning activation plan.`;

    // 5. Call OpenAI
    const openAiResponse = await fetch(
      "https://api.openai.com/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${OPENAI_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "gpt-4o-mini",
          temperature: 0.4,
          max_tokens: 800,
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            { role: "user", content: userMessage },
          ],
          response_format: {
            type: "json_schema",
            json_schema: PlanSchema,
          },
        }),
      }
    );

    if (!openAiResponse.ok) {
      console.error("OpenAI Error:", await openAiResponse.text());
      return new Response(
        JSON.stringify({ error: "AI planning temporarily unavailable" }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const aiData = await openAiResponse.json();
    const plan = JSON.parse(aiData.choices[0].message.content);

    return new Response(JSON.stringify({ success: true, plan }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Internal Error:", err);
    return new Response(
      JSON.stringify({ error: "Something went wrong. Please try again." }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
