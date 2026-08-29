import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

const ContextExtractionSchema = {
  name: "extracted_context",
  strict: true,
  schema: {
    type: "object",
    properties: {
      mood_context: {
        type: "string",
        description:
          "1-2 sentence English summary of the user's emotional state and what happened today.",
      },
      stressors: {
        type: "array",
        items: { type: "string" },
        description:
          "Distinct stressors identified (work, health, relationships, etc). Empty array if none.",
      },
      tomorrow_goals: {
        type: "array",
        items: { type: "string" },
        description:
          "Actionable tasks or goals the user mentioned for tomorrow.",
      },
      wake_time: {
        type: ["string", "null"],
        description:
          'Target wake-up time in 24-hour "HH:MM" format, or null if not mentioned.',
      },
      sleep_preference: {
        type: "string",
        enum: [
          "deep_sleep",
          "quick_wind_down",
          "anxiety_relief",
          "light_rest",
          "unspecified",
        ],
        description: "Preferred sleep approach inferred from context.",
      },
      energy_level: {
        type: "string",
        enum: ["exhausted", "low", "neutral", "wired_tired", "high"],
        description: "Current physical and mental energy state.",
      },
      desired_experience: {
        type: "string",
        enum: [
          "guided_meditation",
          "breathwork",
          "journaling",
          "soundscape_only",
          "body_scan",
          "story",
        ],
        description: "Ideal wind-down modality for tonight.",
      },
      language_detected: {
        type: "string",
        enum: ["english", "hindi", "hinglish", "other"],
        description: "Primary language detected in the input.",
      },
    },
    required: [
      "mood_context",
      "stressors",
      "tomorrow_goals",
      "wake_time",
      "sleep_preference",
      "energy_level",
      "desired_experience",
      "language_detected",
    ],
    additionalProperties: false,
  },
};

const SYSTEM_PROMPT = `You are an empathetic sleep wellness intelligence parser.
Your task is to analyze user check-in input (which may be in English, Hindi, or conversational Hinglish) and extract structured wellness context.

EXTRACTION RULES:
1. mood_context: Provide a clean 1-2 sentence English summary of the user's emotional state.
2. stressors: List distinct stressors. If none mentioned, return [].
3. tomorrow_goals: List specific tasks/goals for tomorrow.
4. wake_time: Convert to 24-hour "HH:MM" format. Examples:
   - "7 am" -> "07:00"
   - "subah saat baje" -> "07:00"
   - "5 baje uthna hai" -> "05:00"
   - "der se uthna hai" -> null (too vague)
   If no time stated, return null.
5. sleep_preference: Choose one:
   - "deep_sleep": Wants restorative rest
   - "quick_wind_down": Exhausted, needs to sleep fast
   - "anxiety_relief": Racing thoughts, nervousness
   - "light_rest": Short nap or light downtime
   - "unspecified": No clear preference
6. energy_level: Choose one:
   - "exhausted": Completely drained
   - "low": Tired but functional
   - "neutral": Normal energy
   - "wired_tired": Physically tired but mentally hyperactive
   - "high": Energized
7. desired_experience: Infer the best modality.
8. language_detected: Detect the primary language mode.

EXAMPLES:

Input: "Aaj interview ki wajah se stressed tha. Kal 5 baje running ke liye uthna hai."
Output: { "mood_context": "Stressed and nervous after a job interview today.", "stressors": ["Job interview stress"], "tomorrow_goals": ["Running"], "wake_time": "05:00", "sleep_preference": "anxiety_relief", "energy_level": "wired_tired", "desired_experience": "breathwork", "language_detected": "hinglish" }

Input: "Had a great workout, feeling good. Want to read before bed. Wake me at 8."
Output: { "mood_context": "Feeling positive and relaxed after a good workout.", "stressors": [], "tomorrow_goals": [], "wake_time": "08:00", "sleep_preference": "deep_sleep", "energy_level": "neutral", "desired_experience": "soundscape_only", "language_detected": "english" }

Input: "Bohot thak gaya hu aaj. Kal office jaana hai early morning."
Output: { "mood_context": "Physically exhausted after a long day with early office tomorrow.", "stressors": ["Physical exhaustion"], "tomorrow_goals": ["Early morning office"], "wake_time": null, "sleep_preference": "quick_wind_down", "energy_level": "exhausted", "desired_experience": "soundscape_only", "language_detected": "hinglish" }`;

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Authenticate user
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

    // 2. Rate limiting (15 requests per hour)
    const { data: isAllowed, error: rateLimitErr } = await supabase.rpc(
      "check_ai_rate_limit",
      {
        p_user_id: user.id,
        p_endpoint: "extract-context",
        p_max_requests: 15,
        p_window_minutes: 60,
      }
    );

    if (rateLimitErr || !isAllowed) {
      return new Response(
        JSON.stringify({
          error: "You've been active! Please try again in a bit.",
        }),
        {
          status: 429,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 3. Parse and validate input
    const body = await req.json();
    const userInput = body.user_input?.trim();
    if (!userInput) {
      return new Response(
        JSON.stringify({ error: "user_input is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Cap input length to prevent abuse
    const sanitizedInput = userInput.substring(0, 1000);

    // 4. Call OpenAI with Structured Outputs
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
          temperature: 0.2,
          max_tokens: 500,
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            { role: "user", content: sanitizedInput },
          ],
          response_format: {
            type: "json_schema",
            json_schema: ContextExtractionSchema,
          },
        }),
      }
    );

    if (!openAiResponse.ok) {
      const errorText = await openAiResponse.text();
      console.error("OpenAI API Error:", openAiResponse.status, errorText);
      return new Response(
        JSON.stringify({ error: "AI processing temporarily unavailable" }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const aiData = await openAiResponse.json();
    const parsedContext = JSON.parse(aiData.choices[0].message.content);

    // 5. Store check-in (without raw input for privacy)
    await supabase.from("checkins").insert({
      user_id: user.id,
      extracted_context: parsedContext,
    });

    return new Response(
      JSON.stringify({ success: true, context: parsedContext }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
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
