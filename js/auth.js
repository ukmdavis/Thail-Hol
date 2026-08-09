// Real authentication via Supabase Auth.
//
// Roles live in the `profiles` table and are enforced by database rules,
// so the checks below are for showing/hiding controls only — even if
// someone bypassed the interface, the database would still refuse them.
//
//   viewer     - read only (default for new sign-ups)
//   editor     - can add, edit and delete
//   organiser  - as editor, plus sees surprise trips early and sets roles

const Auth = {
  session: null,
  profile: null,

  async init() {
    const { data } = await supabaseClient.auth.getSession();
    this.session = data.session;
    if (this.session) await this.loadProfile();
    return this.session;
  },

  async loadProfile() {
    const { data, error } = await supabaseClient
      .from("profiles")
      .select("*")
      .eq("id", this.session.user.id)
      .single();
    if (!error) this.profile = data;
  },

  role() {
    return this.profile?.role || "viewer";
  },

  canEdit() {
    return ["editor", "organiser"].includes(this.role());
  },

  isOrganiser() {
    return this.role() === "organiser";
  },

  email() {
    return this.session?.user?.email || "";
  },

  // Sends a one-time sign-in link to the given email address.
  async sendMagicLink(email) {
    const redirectTo = location.origin + location.pathname.replace(/[^/]*$/, "") + "index.html";
    const { error } = await supabaseClient.auth.signInWithOtp({
      email,
      options: { emailRedirectTo: redirectTo },
    });
    if (error) throw error;
  },

  async signOut() {
    await supabaseClient.auth.signOut();
    location.href = "login.html";
  },

  // Call at the top of any protected page. Redirects to login if needed.
  async requireAuth() {
    await this.init();
    if (!this.session) {
      location.href = "login.html";
      return false;
    }
    document.body.classList.toggle("readonly", !this.canEdit());
    document.body.classList.toggle("organiser", this.isOrganiser());
    return true;
  },

  // Renders the "signed in as / sign out" control.
  renderControl(el) {
    const labels = { viewer: "View only", editor: "Editing", organiser: "Organiser" };
    el.innerHTML = `<span class="badge">${labels[this.role()]}</span> <button id="signOutBtn">Sign out</button>`;
    el.querySelector("#signOutBtn").title = this.email();
    el.querySelector("#signOutBtn").onclick = () => this.signOut();
  },

  // ---------- Organiser-only: managing who can do what ----------
  async listProfiles() {
    const { data, error } = await supabaseClient
      .from("profiles")
      .select("*")
      .order("created_at", { ascending: true });
    if (error) throw error;
    return data;
  },

  async setRole(userId, role) {
    const { error } = await supabaseClient
      .from("profiles")
      .update({ role })
      .eq("id", userId);
    if (error) throw error;
  },
};
