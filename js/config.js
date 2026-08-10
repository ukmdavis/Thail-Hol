// Paste your own Supabase project values here.
// Find them in Supabase: Project Settings > API
const SUPABASE_URL = "https://xhedxbccytvprkxkdtbk.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhoZWR4YmNjeXR2cHJreGtkdGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYyMDQxNDMsImV4cCI6MjEwMTc4MDE0M30.zj9g40adLnFm5P_6OWLN3xJY4c1dtiTJLyi714QDlQs;

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
