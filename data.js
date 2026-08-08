// Shared helpers used by index.html and trip.html

const HolidayData = {
  async listHolidays() {
    const { data, error } = await supabaseClient
      .from("holidays")
      .select("*")
      .order("depart_date", { ascending: true });
    if (error) throw error;
    return data;
  },

  async getHoliday(id) {
    const { data, error } = await supabaseClient
      .from("holidays")
      .select("*")
      .eq("id", id)
      .single();
    if (error) throw error;
    return data;
  },

  async addHoliday(holiday) {
    const { data, error } = await supabaseClient
      .from("holidays")
      .insert(holiday)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async deleteHoliday(id) {
    const { error } = await supabaseClient.from("holidays").delete().eq("id", id);
    if (error) throw error;
  },

  async listFlights(holidayId) {
    const { data, error } = await supabaseClient
      .from("flights")
      .select("*")
      .eq("holiday_id", holidayId)
      .order("depart_at", { ascending: true });
    if (error) throw error;
    return data;
  },

  async addFlight(flight) {
    const { error } = await supabaseClient.from("flights").insert(flight);
    if (error) throw error;
  },

  async updateFlight(id, flight) {
    const { error } = await supabaseClient.from("flights").update(flight).eq("id", id);
    if (error) throw error;
  },

  async deleteFlight(id) {
    const { error } = await supabaseClient.from("flights").delete().eq("id", id);
    if (error) throw error;
  },

  async listStays(holidayId) {
    const { data, error } = await supabaseClient
      .from("stays")
      .select("*")
      .eq("holiday_id", holidayId)
      .order("checkin", { ascending: true });
    if (error) throw error;
    return data;
  },

  async addStay(stay) {
    const { error } = await supabaseClient.from("stays").insert(stay);
    if (error) throw error;
  },

  async updateStay(id, stay) {
    const { error } = await supabaseClient.from("stays").update(stay).eq("id", id);
    if (error) throw error;
  },

  async deleteStay(id) {
    const { error } = await supabaseClient.from("stays").delete().eq("id", id);
    if (error) throw error;
  },

  async listDayItems(holidayId) {
    const { data, error } = await supabaseClient
      .from("day_items")
      .select("*")
      .eq("holiday_id", holidayId)
      .order("item_date", { ascending: true });
    if (error) throw error;
    return data;
  },

  async addDayItem(item) {
    const { error } = await supabaseClient.from("day_items").insert(item);
    if (error) throw error;
  },

  async toggleTaskDone(id, done) {
    const { error } = await supabaseClient.from("day_items").update({ done }).eq("id", id);
    if (error) throw error;
  },

  async updateDayItemText(id, text) {
    const { error } = await supabaseClient.from("day_items").update({ text }).eq("id", id);
    if (error) throw error;
  },

  async deleteDayItem(id) {
    const { error } = await supabaseClient.from("day_items").delete().eq("id", id);
    if (error) throw error;
  },

  async updateHoliday(id, fields) {
    const { error } = await supabaseClient.from("holidays").update(fields).eq("id", id);
    if (error) throw error;
  },
};

function formatDate(dateStr, opts) {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleDateString("en-GB", opts || { weekday: "short", day: "numeric", month: "short", year: "numeric" });
}

function formatDateTime(dtStr) {
  if (!dtStr) return "";
  return new Date(dtStr).toLocaleString("en-GB", { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" });
}

function daysBetween(a, b) {
  const msPerDay = 1000 * 60 * 60 * 24;
  const d1 = new Date(a); d1.setHours(0,0,0,0);
  const d2 = new Date(b); d2.setHours(0,0,0,0);
  return Math.round((d2 - d1) / msPerDay);
}
