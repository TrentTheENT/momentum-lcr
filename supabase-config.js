/**
 * Supabase Configuration
 * Replace these with your actual Supabase project credentials
 */

// These will be set from environment variables in production
const SUPABASE_URL = import.meta.env?.VITE_SUPABASE_URL || '';
const SUPABASE_ANON_KEY = import.meta.env?.VITE_SUPABASE_ANON_KEY || '';

// Fallback: Check for script tag injection (for static HTML)
let supabaseClient = null;

async function initSupabase() {
    if (typeof window !== 'undefined' && window.supabase) {
        return window.supabase;
    }
    
    // Load Supabase client from CDN if not available
    if (!window.supabase) {
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
        script.onload = () => {
            if (SUPABASE_URL && SUPABASE_ANON_KEY) {
                window.supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
            }
        };
        document.head.appendChild(script);
        return new Promise((resolve) => {
            script.onload = () => {
                if (SUPABASE_URL && SUPABASE_ANON_KEY) {
                    window.supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
                    resolve(window.supabase);
                } else {
                    console.warn('Supabase credentials not configured');
                    resolve(null);
                }
            };
        });
    }
    
    return window.supabase;
}

export { initSupabase, SUPABASE_URL, SUPABASE_ANON_KEY };

