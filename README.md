# Neend Companion — AI Personal Sleep & Morning Companion MVP

An AI-powered personal sleep and morning companion for Android built with Flutter, Riverpod, Hive, Supabase, and OpenAI (`gpt-4o-mini`).

The core product loop:
```
DAY → AI UNDERSTANDS CONTEXT → PERSONALIZED NIGHT EXPERIENCE → SLEEP → PERSONALIZED MORNING EXPERIENCE → FEEDBACK → LEARNING
```

---

## 1. Project Overview & Architecture

### Core Tech Stack
- **Frontend**: Flutter 3.22+ / Dart 3.4+
- **Architecture**: Pragmatic Feature-First Architecture with Riverpod
- **State Management**: `flutter_riverpod`
- **Navigation**: `go_router`
- **Local Storage**: `hive_flutter` + `hive_ce` (Local-first offline capability)
- **Secure Storage**: `flutter_secure_storage` (AES-256 for tokens)
- **Audio Engine**: `just_audio` + `audio_service` + `audio_session` (Runs as an Android Foreground Service with lockscreen controls; persists across app sleep/kill)
- **Alarms**: `android_alarm_manager_plus` (Uses `AlarmManager.setAlarmClock()` with `USE_EXACT_ALARM` to wake CPU from Doze mode)
- **Notifications**: `flutter_local_notifications` (Full-Screen Intent for wake-up screen over locked device)
- **Voice / Speech**: `speech_to_text` (Native Android SpeechRecognizer) + `flutter_tts` (Personalized reflections & greetings) + `record` (AAC recording for consented loved-one voice clips)
- **Backend & Cloud AI**: Supabase (PostgreSQL, Row Level Security, Storage) + Supabase Edge Functions (Deno proxy to OpenAI `gpt-4o-mini` with strict JSON Schema)

---

## 2. Directory Structure

```
neend_companion/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml       # Full permissions for exact alarms & foreground audio
│   │   │   └── res/
│   │   ├── build.gradle.kts
│   │   └── proguard-rules.pro            # R8 rules preserving audio & notification entrypoints
│   └── key.properties.example
├── assets/
│   ├── audio/                            # CC0 loopable & relaxing audio tracks
│   └── images/
├── supabase/
│   ├── schema.sql                        # PostgreSQL schema, RLS policies, rate limiting RPC
│   └── functions/
│       ├── _shared/cors.ts               # Shared CORS configuration
│       ├── extract-context/index.ts      # Context extraction Edge Function (gpt-4o-mini)
│       └── generate-plan/index.ts        # Night/Morning plan generator Edge Function
├── lib/
│   ├── main.dart                         # Service initialization, Hive setup, Alarm/Notif bootstrapping
│   ├── app/
│   │   ├── app.dart                      # MaterialApp.router configuration
│   │   ├── router.dart                   # GoRouter with guards and splash routing
│   │   └── theme/                        # Dark-first Night theme & warm Morning theme
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── errors/failures.dart
│   │   ├── utils/                        # date_utils.dart, string_utils.dart (Hinglish parser)
│   │   └── widgets/                      # AnimatedGradient, BreathingCircle, MicButton, FeedbackSelector, PlanStepCard, LoadingOverlay
│   ├── models/                           # 11 Domain models (UserProfile, ExtractedContext, NightPlan, etc.)
│   ├── data/
│   │   ├── intervention_registry.dart    # Controlled evidence-based scientific catalog (14 protocols)
│   │   ├── audio_catalog.dart            # Audio track metadata & categories
│   │   ├── personalization_engine.dart   # Scoring & recommendation engine based on user feedback
│   │   └── repositories/                 # Hive-backed repositories for user, check-ins, alarms, plans, voice, feedback
│   ├── services/
│   │   ├── ai/                           # OpenAI & Edge Function client
│   │   ├── audio/                        # Background audio player service & handler
│   │   ├── alarm/                        # Exact alarm service & entrypoint callback
│   │   ├── notification/                 # Notification service (Full-Screen Intent)
│   │   ├── speech/                       # STT & TTS services
│   │   ├── storage/                      # LocalStorageService & SecureStorageService
│   │   └── supabase/                     # SupabaseService & AuthService
│   └── features/
│       ├── onboarding/                   # Multi-step goal & preference setup
│       ├── home/                         # Tonight card, wake card, context summary, mic CTA
│       ├── checkin/                      # Text & voice daily reflection
│       ├── night/                        # Tonight's plan preview & immersive player
│       ├── alarm/                        # Alarm setup screen (with conversational time parsing)
│       ├── morning/                      # Full-screen ringing alarm & morning activation experience
│       ├── voice_messages/               # Loved-one voice recording & consent management
│       ├── feedback/                     # Night & morning feedback capture sheets
│       ├── settings/                     # Settings, privacy info, & complete data management
│       └── demo/                         # Standalone investor/advisor demo mode (Rahul profile)
├── pubspec.yaml
└── .env.example
```

---

## 3. Environment Variables & Setup

Create a `.env` file or configure your Supabase project with:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Server-Side OpenAI Secret (Supabase Edge Functions)
To protect your OpenAI API key from exposure inside the mobile binary, store it in Supabase Secrets:
```bash
supabase secrets set OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxx
```

---

## 4. Supabase Backend Deployment

### Step 1: Deploy Database Schema
1. Open your [Supabase Dashboard](https://supabase.com/dashboard).
2. Navigate to the **SQL Editor**.
3. Paste and run the entire contents of [`supabase/schema.sql`](supabase/schema.sql).

This provisions:
- `user_profiles` table with Row Level Security (RLS)
- `checkins` table
- `feedback_entries` table
- `voice_consents` table
- `ai_usage_logs` table
- `check_ai_rate_limit` PostgreSQL security-definer function (rate limits users to 15 AI requests/hour)

### Step 2: Deploy Edge Functions
Ensure you have the [Supabase CLI](https://supabase.com/docs/guides/cli) installed:
```bash
supabase login
supabase link --project-ref your-project-ref
supabase functions deploy extract-context
supabase functions deploy generate-plan
```

---

## 5. Scientific Intervention Registry

The LLM is **never** permitted to hallucinate or invent clinical claims. It selects protocols from the hardcoded `InterventionRegistry` (`lib/data/intervention_registry.dart`):

| ID | Intervention | Category | Evidence Level | Duration | Indication |
|---|---|---|---|---|---|
| `INT_BREATH_478` | 4-7-8 Breathing | Breathwork | Moderate | 5–8 min | Anxiety, racing thoughts |
| `INT_BREATH_BOX` | Box Breathing 4-4-4-4 | Breathwork | Moderate | 4–6 min | Focus, nervous system reset |
| `INT_PMR` | Progressive Muscle Relaxation | Relaxation | Strong | 10–15 min | Physical tension |
| `INT_BODY_SCAN` | Somatic Body Scan | Relaxation | Moderate | 10–15 min | General stress |
| `INT_GUIDED_IMAGERY` | Guided Imagery | Relaxation | Moderate | 8–12 min | Calming visualization |
| `INT_THOUGHT_DUMP` | Worry Brain Dump | Cognitive | Moderate | 5 min | High stressor load / task overload |
| `INT_SOUND_RAIN` | Gentle Rain Soundscape | Sleep Audio | Supportive | 15–60 min | Sleep onset |
| `INT_SOUND_BROWN` | Deep Brown Noise | Sleep Audio | Supportive | 15–60 min | Noise masking |
| `INT_SOUND_NATURE` | Forest / Nature Sounds | Sleep Audio | Supportive | 15–60 min | Ambient relaxation |
| `INT_SOUND_PIANO` | Soft Piano Melodies | Sleep Audio | Supportive | 15–30 min | Calming instrumental |
| `INT_WAKE_LIGHT` | Morning Light Exposure | Morning Activation | Strong | 10 min | Circadian cortisol alignment |
| `INT_WAKE_HYDRATE` | Morning Hydration | Morning Activation | Supportive | 3 min | Metabolic awakening |
| `INT_WAKE_STRETCH` | Somatic Morning Stretch | Morning Activation | Supportive | 5 min | Physical mobility |
| `INT_WAKE_PRIMING` | Goal Visualization *(Experimental)* | Morning Activation | Experimental | 5 min | Intention setting |

---

## 6. Loved-One Voice & Consent Model

The app explicitly complies with strict ethical voice policies:
- **No unauthorized voice cloning**: V1 allows users to record and store consented high-quality audio clips directly from loved ones.
- **Explicit Consent**: Every recording is tied to a `VoiceConsent` model containing the person's name, relationship, grant date, and revoke controls.
- **Future AI Architecture Ready**: The model includes a `voiceModelId` slot to plug in consented voice synthesis APIs in future iterations without refactoring domain logic.

---

## 7. Android Reliability & Background Services

For a reliable alarm clock and audio experience on physical Android phones:

1. **Exact Alarms (`USE_EXACT_ALARM` & `SCHEDULE_EXACT_ALARM`)**:
   - `android_alarm_manager_plus` schedules via `AlarmManager.setAlarmClock()` to pierce Android Doze and Battery Saver modes.
   - Sideloaded APKs benefit directly from `USE_EXACT_ALARM` without Google Play policy restrictions.
2. **Foreground Audio Service**:
   - `audio_service` runs an Android `MediaBrowserService` with a persistent foreground notification, ensuring audio plays continuously when the screen is locked or the app is swiped from Recents.
3. **Full-Screen Wake Intent**:
   - When the morning alarm triggers, `flutter_local_notifications` uses `fullScreenIntent` to display the ringing screen directly over the device lockscreen.

---

## 8. Sideloading Release APK Build Instructions

To build a standalone production APK for direct installation on any physical Android device:

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Build Universal Release APK
```bash
flutter build apk --release
```
The output file will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 3: Sideload & Install via ADB
Connect your Android phone via USB with USB Debugging enabled, then run:
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

*Or transfer `app-release.apk` to your phone via Google Drive / WhatsApp / Cable and tap to install.*

---

## 9. Demo Mode (Founder / Investor Presentation)

A dedicated **Demo Mode** allows instantaneous demonstrations without requiring live AI API latency or internet connectivity:
- Accessible from **Settings > Demo Mode** or automatically when offline.
- Pre-loaded with persona **Rahul**:
  - *Context*: "Aaj interview ki wajah se stressed tha. Kal 5 baje running ke liye uthna hai."
  - *Generated Night Plan*: 4-7-8 Breathing + Worry Brain Dump + Rain Soundscape + Spoken Reflection.
  - *Generated Morning Plan*: 5:00 AM Alarm + Mom's Voice Greeting ("Beta uth ja. Aaj running pe jaana tha.") + Hydration + Goal Priming.

---

## 10. Status: Real vs Mock vs Future Functionality

| Feature Area | Implementation Status | Notes |
|---|---|---|
| **Onboarding & Profile** | **REAL** | Persisted locally via Hive; customizable goals and sleep schedules |
| **Check-in (Text & Voice)** | **REAL** | SpeechRecognizer integration + structured prompt ingestion |
| **AI Context Extraction** | **REAL** | Supabase Edge Function + OpenAI `gpt-4o-mini` with strict JSON output |
| **Intervention Registry** | **REAL** | Evidence-based catalog with strict categorization and experimental tagging |
| **Night Experience & Audio** | **REAL** | Foreground audio service with timer, crossfade, and background survival |
| **Conversational Alarm** | **REAL** | Natural language Hinglish parser ("kal 5 baje uthna") + native AlarmManager |
| **Loved-One Voice Clips** | **REAL** | Device-level microphone recording (AAC) + consent tracking |
| **Feedback & Personalization** | **REAL** | Scoring engine adjusting recommendations based on explicit ratings |
| **Demo Mode** | **REAL** | Instant offline presentation capabilities |
| **Health Connect Integration** | **STUB / FUTURE** | Clean abstract interface ready for wearable data ingestion |
| **Consented Voice Cloning** | **FUTURE ARCHITECTURE** | Prepared schema and model fields ready for ElevenLabs/PlayHT integration |

---

## 11. Next 10 Highest-Priority Product Improvements

1. **Health Connect / Apple HealthKit**: Ingest real resting heart rate (RHR) and sleep stage data.
2. **Consented Voice Cloning Pipeline**: Integrate an API for consented voice synthesis from 30s samples.
3. **Smart Sleep Window Optimization**: Dynamic alarm adjustment within a 30-minute window based on sleep debt.
4. **Offline Local LLM Option**: Support on-device Gemma-2-2B via MediaPipe for 100% offline context extraction.
5. **Interactive Audio Soundboard**: Allow mixing ambient rain with brown noise and gentle piano simultaneously.
6. **Smart Lighting Integration**: Connect to Philips Hue / Tuya for gentle sunrise light simulation.
7. **Streak & Consistency Insights**: Gentle monthly behavioral consistency metrics without gamified pressure.
8. **Multi-Language Audio Narrations**: Professional Hindi and English voice talent recordings for guided meditations.
9. **Partner Sync Routine**: Shared wake-up synchronization for couples with different schedules.
10. **Bedside Stand Companion Mode**: Always-on low-light OLED night clock with glanceable wind-down prompts.
