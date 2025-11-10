# Momentum LCR Setup Guide

## Quick Start

1. **Set up Supabase**
   - Go to [supabase.com](https://supabase.com) and create a new project
   - Run the SQL schema from `supabase-schema.sql` in the SQL Editor
   - Copy your project URL and anon key

2. **Configure the App**
   - Open `index.html`
   - Find the Supabase configuration section (around line 557)
   - Add your Supabase URL and anon key:
   ```javascript
   const SUPABASE_URL = 'https://your-project.supabase.co';
   const SUPABASE_ANON_KEY = 'your-anon-key';
   ```

3. **Deploy to Vercel**
   - The repository is already set up for Vercel
   - Connect your GitHub repo to Vercel
   - Add environment variables in Vercel dashboard:
     - `VITE_SUPABASE_URL`
     - `VITE_SUPABASE_ANON_KEY`
   - Deploy!

## Features

### Pattern Matching
- Automatically detects time patterns in your activity
- Tracks most active hours and days
- Calculates consistency scores

### Gamification
- Streak tracking
- Achievement system
- Consistency scoring
- Weekly activity charts

### Real-time Sync
- Tasks sync across devices via Supabase
- Event logging for pattern analysis
- Statistics aggregation

## Database Schema

The app uses the following tables:
- `tasks` - User tasks organized by lanes
- `events` - Event logging for pattern matching
- `patterns` - Detected behavior patterns
- `achievements` - Unlocked achievements
- `stats` - Daily aggregated statistics

## Local Development

1. Serve the files locally:
   ```bash
   python -m http.server 8000
   ```

2. Open `http://localhost:8000` in your browser

3. The app will work with localStorage if Supabase is not configured

## Production Deployment

The app is configured for Vercel deployment. Simply:
1. Push to GitHub
2. Connect to Vercel
3. Add environment variables
4. Deploy!

