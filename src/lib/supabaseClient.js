import { createClient } from '@supabase/supabase-js';

let supabase;

export function getSupabaseClient() {
  if (!supabase) {
    const cfg = typeof window !== 'undefined' ? window.__APP_CONFIG__ : {};
    const url = cfg?.SUPABASE_URL || import.meta.env.PUBLIC_SUPABASE_URL;
    const key = cfg?.SUPABASE_ANON_KEY || import.meta.env.PUBLIC_SUPABASE_ANON_KEY;
    if (!url || !key) {
      throw new Error('缺少 Supabase 配置');
    }
    supabase = createClient(url, key, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true
      }
    });
  }
  return supabase;
}
