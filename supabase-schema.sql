-- Momentum LCR Database Schema
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    lane_id INTEGER NOT NULL, -- 0: Focus, 1: Flow, 2: Rest, 3: Silence
    content TEXT NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    priority INTEGER DEFAULT 0, -- 0: low, 1: medium, 2: high
    tags TEXT[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}'
);

-- Events table for pattern matching and gamification
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL, -- 'task_created', 'task_completed', 'lane_switch', 'brain_dump', etc.
    lane_id INTEGER,
    task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Patterns table for tracking user behavior patterns
CREATE TABLE IF NOT EXISTS patterns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    pattern_type TEXT NOT NULL, -- 'time_pattern', 'category_pattern', 'completion_pattern', etc.
    pattern_data JSONB NOT NULL,
    confidence DECIMAL(3,2) DEFAULT 0.5, -- 0.0 to 1.0
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Achievements table
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    achievement_type TEXT NOT NULL, -- 'streak', 'consistency', 'completion', etc.
    achievement_data JSONB NOT NULL,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Stats table for aggregated statistics
CREATE TABLE IF NOT EXISTS stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    stat_date DATE NOT NULL,
    total_tasks INTEGER DEFAULT 0,
    completed_tasks INTEGER DEFAULT 0,
    consistency_score DECIMAL(5,2) DEFAULT 0,
    streak_days INTEGER DEFAULT 0,
    lane_distribution JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, stat_date)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_lane_id ON tasks(lane_id);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at);
CREATE INDEX IF NOT EXISTS idx_events_user_id ON events(user_id);
CREATE INDEX IF NOT EXISTS idx_events_created_at ON events(created_at);
CREATE INDEX IF NOT EXISTS idx_events_event_type ON events(event_type);
CREATE INDEX IF NOT EXISTS idx_patterns_user_id ON patterns(user_id);
CREATE INDEX IF NOT EXISTS idx_achievements_user_id ON achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_stats_user_date ON stats(user_id, stat_date);

-- Row Level Security (RLS) Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE stats ENABLE ROW LEVEL SECURITY;

-- Users can only see their own data
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Tasks policies
CREATE POLICY "Users can view own tasks" ON tasks
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tasks" ON tasks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tasks" ON tasks
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tasks" ON tasks
    FOR DELETE USING (auth.uid() = user_id);

-- Events policies
CREATE POLICY "Users can view own events" ON events
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own events" ON events
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Patterns policies
CREATE POLICY "Users can view own patterns" ON patterns
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own patterns" ON patterns
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own patterns" ON patterns
    FOR UPDATE USING (auth.uid() = user_id);

-- Achievements policies
CREATE POLICY "Users can view own achievements" ON achievements
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own achievements" ON achievements
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Stats policies
CREATE POLICY "Users can view own stats" ON stats
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stats" ON stats
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own stats" ON stats
    FOR UPDATE USING (auth.uid() = user_id);

-- Functions for pattern matching
CREATE OR REPLACE FUNCTION detect_time_patterns(user_uuid UUID, days_back INTEGER DEFAULT 7)
RETURNS JSONB AS $$
DECLARE
    pattern_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'most_active_hour', (
            SELECT EXTRACT(HOUR FROM created_at)::INTEGER
            FROM events
            WHERE user_id = user_uuid
            AND created_at > NOW() - (days_back || ' days')::INTERVAL
            GROUP BY EXTRACT(HOUR FROM created_at)
            ORDER BY COUNT(*) DESC
            LIMIT 1
        ),
        'most_active_day', (
            SELECT EXTRACT(DOW FROM created_at)::INTEGER
            FROM events
            WHERE user_id = user_uuid
            AND created_at > NOW() - (days_back || ' days')::INTERVAL
            GROUP BY EXTRACT(DOW FROM created_at)
            ORDER BY COUNT(*) DESC
            LIMIT 1
        ),
        'average_tasks_per_day', (
            SELECT ROUND(COUNT(*)::DECIMAL / NULLIF(days_back, 0), 2)
            FROM tasks
            WHERE user_id = user_uuid
            AND created_at > NOW() - (days_back || ' days')::INTERVAL
        )
    ) INTO pattern_result;
    
    RETURN pattern_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to calculate consistency score
CREATE OR REPLACE FUNCTION calculate_consistency_score(user_uuid UUID, days_back INTEGER DEFAULT 7)
RETURNS DECIMAL AS $$
DECLARE
    total_days INTEGER;
    active_days INTEGER;
    score DECIMAL;
BEGIN
    total_days := days_back;
    
    SELECT COUNT(DISTINCT DATE(created_at))
    INTO active_days
    FROM events
    WHERE user_id = user_uuid
    AND created_at > NOW() - (days_back || ' days')::INTERVAL;
    
    score := (active_days::DECIMAL / NULLIF(total_days, 0)) * 100;
    
    RETURN COALESCE(score, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update stats
CREATE OR REPLACE FUNCTION update_daily_stats(user_uuid UUID, stat_date DATE DEFAULT CURRENT_DATE)
RETURNS VOID AS $$
BEGIN
    INSERT INTO stats (user_id, stat_date, total_tasks, completed_tasks, consistency_score, streak_days)
    VALUES (
        user_uuid,
        stat_date,
        (SELECT COUNT(*) FROM tasks WHERE user_id = user_uuid AND DATE(created_at) = stat_date),
        (SELECT COUNT(*) FROM tasks WHERE user_id = user_uuid AND DATE(completed_at) = stat_date),
        calculate_consistency_score(user_uuid, 7),
        (SELECT COALESCE(MAX(streak_days), 0) FROM stats WHERE user_id = user_uuid ORDER BY stat_date DESC LIMIT 1)
    )
    ON CONFLICT (user_id, stat_date)
    DO UPDATE SET
        total_tasks = EXCLUDED.total_tasks,
        completed_tasks = EXCLUDED.completed_tasks,
        consistency_score = EXCLUDED.consistency_score,
        streak_days = EXCLUDED.streak_days;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

