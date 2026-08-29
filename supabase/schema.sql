-- ============================================================
-- Neend Companion — Supabase Database Schema
-- Run this in the Supabase SQL Editor to set up all tables
-- ============================================================

-- 1. User Profiles (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    preferences JSONB DEFAULT '{}',
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON public.user_profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.user_profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.user_profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can delete own profile"
    ON public.user_profiles FOR DELETE
    USING (auth.uid() = id);

-- 2. Check-in History
CREATE TABLE IF NOT EXISTS public.checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    raw_input TEXT,
    extracted_context JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_checkins_user_date ON public.checkins (user_id, created_at DESC);

ALTER TABLE public.checkins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own checkins"
    ON public.checkins FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own checkins"
    ON public.checkins FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own checkins"
    ON public.checkins FOR DELETE
    USING (auth.uid() = user_id);

-- 3. Feedback Entries
CREATE TABLE IF NOT EXISTS public.feedback_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('night', 'morning')),
    rating TEXT NOT NULL,
    intervention_ids TEXT[] DEFAULT '{}',
    sleep_duration_minutes INT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_feedback_user_date ON public.feedback_entries (user_id, created_at DESC);

ALTER TABLE public.feedback_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own feedback"
    ON public.feedback_entries FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own feedback"
    ON public.feedback_entries FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own feedback"
    ON public.feedback_entries FOR DELETE
    USING (auth.uid() = user_id);

-- 4. Voice Consents
CREATE TABLE IF NOT EXISTS public.voice_consents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    voice_owner_name TEXT NOT NULL,
    relationship TEXT,
    permission_granted BOOLEAN DEFAULT FALSE,
    granted_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.voice_consents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own voice consents"
    ON public.voice_consents FOR ALL
    USING (auth.uid() = user_id);

-- 5. AI Usage Rate Limiting
CREATE TABLE IF NOT EXISTS public.ai_usage_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    endpoint TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_ai_usage_window
    ON public.ai_usage_logs (user_id, endpoint, created_at DESC);

-- 6. Rate Limit Check Function
CREATE OR REPLACE FUNCTION public.check_ai_rate_limit(
    p_user_id UUID,
    p_endpoint TEXT,
    p_max_requests INT,
    p_window_minutes INT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    request_count INT;
BEGIN
    SELECT COUNT(*)
    INTO request_count
    FROM public.ai_usage_logs
    WHERE user_id = p_user_id
      AND endpoint = p_endpoint
      AND created_at > (now() - (p_window_minutes || ' minutes')::INTERVAL);

    IF request_count >= p_max_requests THEN
        RETURN FALSE;
    END IF;

    INSERT INTO public.ai_usage_logs (user_id, endpoint)
    VALUES (p_user_id, p_endpoint);

    RETURN TRUE;
END;
$$;

-- 7. Cleanup: Auto-delete old rate limit logs (older than 24 hours)
-- Run this as a Supabase cron job or pg_cron extension
-- SELECT cron.schedule('cleanup-ai-logs', '0 */6 * * *', $$
--     DELETE FROM public.ai_usage_logs WHERE created_at < now() - INTERVAL '24 hours';
-- $$);

-- 8. Storage bucket for voice recordings (optional cloud sync)
-- Run in Supabase Dashboard > Storage > Create Bucket
-- Bucket name: voice-recordings
-- Public: false
-- File size limit: 10MB
-- Allowed MIME types: audio/aac, audio/mp4, audio/wav, audio/mpeg
