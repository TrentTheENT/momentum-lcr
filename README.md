# Momentum LCR

A gamified cognitive task management app with voice input, pattern matching, and real-time synchronization via Supabase.

## Features

- **Dashboard**: Beautiful Mondrian-style bento box layout
- **Brain Dump**: Voice and text input for quick task capture
- **AI Organization**: Automatic task categorization and organization
- **Pattern Matching**: Track patterns in your productivity
- **Gamification**: Streaks, consistency tracking, and achievements
- **Real-time Sync**: Supabase integration for cross-device synchronization

## Setup

1. Clone the repository
2. Set up Supabase project and add credentials to `.env`
3. Deploy to Vercel or run locally

## Environment Variables

```
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Development

Open `index.html` in a browser or use a local server:

```bash
python -m http.server 8000
```

## Deployment

Deployed automatically via Vercel when pushing to main branch.

