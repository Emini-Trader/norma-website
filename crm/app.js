(function () {
  "use strict";

  if (!window.SUPABASE_URL || window.SUPABASE_URL.includes("TWOJ-PROJEKT")) {
    document.body.innerHTML =
      '<div style="padding:40px;font-family:sans-serif;max-width:560px;margin:0 auto">' +
      "<h2>Konfiguracja niekompletna</h2>" +
      "<p>Uzupełnij <code>crm/config.js</code> danymi Twojego projektu Supabase (URL i anon key), " +
      "zanim uruchomisz CRM. Znajdziesz je w Supabase Dashboard → Project Settings → API.</p>" +
      "</div>";
    return;
  }

  const supabase = window.supabase.createClient(
    window.SUPABASE_URL,
    window.SUPABASE_ANON_KEY
  );

  const STATUS_LABELS = {
    ny: "Ny",
    kontaktet: "Kontaktet",
    venter_svar: "Venter på svar",
    kunde: "Kunde",
    avslatt: "Avslått",
  };

  const els = {
    loginView: document.getElementById("login-view"),
    appView: document.getElementById("app-view"),
    userBox: document.getElementById("user-box"),
    userEmail: document.getElementById("user-email"),
    logoutBtn: document.getElementById("logout-btn"),
    loginForm: document.getElementById("login-form"),
    loginEmail: document.getElementById("login-email"),
    loginPassword: document.getElementById("login-password"),
    loginError: document.getElementById("login-error"),
    searchInput: document.getElementById("search-input"),
    statusFilter: document.getElementById("status-filter"),
    newContactBtn: document.getElementById("new-contact-btn"),
    tbody: document.getElementById("contacts-tbody"),
    modal: document.getElementById("contact-modal"),
    modalTitle: document.getElementById("modal-title"),
    modalClose: document.getElementById("modal-close"),
    modalCancel: document.getElementById("modal-cancel"),
    contactForm: document.getElementById("contact-form"),
    formError: document.getElementById("form-error"),
    contactId: document.getElementById("contact-id"),
    fCompany: document.getElementById("f-company"),
    fPhone: document.getElementById("f-phone"),
    fEmail: document.getElementById("f-email"),
    fWebsite: document.getElementById("f-website"),
    fPerson: document.getElementById("f-person"),
    fAddress: document.getElementById("f-address"),
    fStatus: document.getElementById("f-status"),
    deleteBtn: document.getElementById("delete-contact-btn"),
    activitySection: document.getElementById("activity-section"),
    activityList: document.getElementById("activity-list"),
    activityForm: document.getElementById("activity-form"),
    activityNote: document.getElementById("activity-note"),
  };

  let allContacts = [];

  function escapeHtml(str) {
    if (str == null) return "";
    return String(str).replace(/[&<>"']/g, (c) => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
    }[c]));
  }

  function formatDateTime(iso) {
    if (!iso) return "";
    const d = new Date(iso);
    return d.toLocaleString("no-NO", { day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit" });
  }

  // ---------- Auth ----------

  async function checkSession() {
    const { data } = await supabase.auth.getSession();
    if (data.session) {
      showApp(data.session.user);
    } else {
      showLogin();
    }
  }

  supabase.auth.onAuthStateChange((_event, session) => {
    if (session) {
      showApp(session.user);
    } else {
      showLogin();
    }
  });

  function showLogin() {
    els.loginView.hidden = false;
    els.appView.hidden = true;
    els.userBox.hidden = true;
  }

  function showApp(user) {
    els.loginView.hidden = true;
    els.appView.hidden = false;
    els.userBox.hidden = false;
    els.userEmail.textContent = user.email;
    loadContacts();
  }

  els.loginForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    els.loginError.hidden = true;
    const { error } = await supabase.auth.signInWithPassword({
      email: els.loginEmail.value.trim(),
      password: els.loginPassword.value,
    });
    if (error) {
      els.loginError.textContent = "Feil e-post eller passord.";
      els.loginError.hidden = false;
    }
  });

  els.logoutBtn.addEventListener("click", async () => {
    await supabase.auth.signOut();
  });

  // ---------- Load & render contacts ----------

  async function loadContacts() {
    els.tbody.innerHTML = '<tr><td colspan="6" class="loading-row">Laster…</td></tr>';
    const { data, error } = await supabase
      .from("contacts")
      .select("*")
      .order("updated_at", { ascending: false });

    if (error) {
      els.tbody.innerHTML = `<tr><td colspan="6" class="empty-row">Feil ved lasting: ${escapeHtml(error.message)}</td></tr>`;
      return;
    }
    allContacts = data || [];
    renderContacts();
  }

  function renderContacts() {
    const search = els.searchInput.value.trim().toLowerCase();
    const statusFilterVal = els.statusFilter.value;

    const filtered = allContacts.filter((c) => {
      if (statusFilterVal && c.status !== statusFilterVal) return false;
      if (!search) return true;
      const haystack = [c.company_name, c.contact_person, c.email, c.phone, c.address]
        .filter(Boolean).join(" ").toLowerCase();
      return haystack.includes(search);
    });

    if (filtered.length === 0) {
      els.tbody.innerHTML = '<tr><td colspan="6" class="empty-row">Ingen treff.</td></tr>';
      return;
    }

    els.tbody.innerHTML = filtered.map((c) => `
      <tr data-id="${escapeHtml(c.id)}">
        <td class="company-cell">${escapeHtml(c.company_name)}</td>
        <td>${escapeHtml(c.contact_person)}</td>
        <td>${escapeHtml(c.phone)}</td>
        <td>${escapeHtml(c.email)}</td>
        <td><span class="status-badge status-${escapeHtml(c.status)}">${escapeHtml(STATUS_LABELS[c.status] || c.status)}</span></td>
        <td class="meta-cell">${formatDateTime(c.updated_at)}<br>${escapeHtml(c.updated_by_email || "")}</td>
      </tr>
    `).join("");
  }

  els.searchInput.addEventListener("input", renderContacts);
  els.statusFilter.addEventListener("change", renderContacts);

  els.tbody.addEventListener("click", (e) => {
    const row = e.target.closest("tr[data-id]");
    if (!row) return;
    const contact = allContacts.find((c) => c.id === row.dataset.id);
    if (contact) openModal(contact);
  });

  // ---------- Modal: create / edit contact ----------

  els.newContactBtn.addEventListener("click", () => openModal(null));
  els.modalClose.addEventListener("click", closeModal);
  els.modalCancel.addEventListener("click", closeModal);
  els.modal.addEventListener("click", (e) => {
    if (e.target === els.modal) closeModal();
  });

  function openModal(contact) {
    els.formError.hidden = true;
    els.contactForm.reset();
    if (contact) {
      els.modalTitle.textContent = contact.company_name;
      els.contactId.value = contact.id;
      els.fCompany.value = contact.company_name || "";
      els.fPhone.value = contact.phone || "";
      els.fEmail.value = contact.email || "";
      els.fWebsite.value = contact.website || "";
      els.fPerson.value = contact.contact_person || "";
      els.fAddress.value = contact.address || "";
      els.fStatus.value = contact.status || "ny";
      els.deleteBtn.hidden = false;
      els.activitySection.hidden = false;
      loadActivities(contact.id);
    } else {
      els.modalTitle.textContent = "Ny firma";
      els.contactId.value = "";
      els.fStatus.value = "ny";
      els.deleteBtn.hidden = true;
      els.activitySection.hidden = true;
      els.activityList.innerHTML = "";
    }
    els.modal.hidden = false;
  }

  function closeModal() {
    els.modal.hidden = true;
  }

  els.contactForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    els.formError.hidden = true;

    const payload = {
      company_name: els.fCompany.value.trim(),
      phone: els.fPhone.value.trim() || null,
      email: els.fEmail.value.trim() || null,
      website: els.fWebsite.value.trim() || null,
      contact_person: els.fPerson.value.trim() || null,
      address: els.fAddress.value.trim() || null,
      status: els.fStatus.value,
    };

    let error;
    if (els.contactId.value) {
      ({ error } = await supabase.from("contacts").update(payload).eq("id", els.contactId.value));
    } else {
      ({ error } = await supabase.from("contacts").insert(payload));
    }

    if (error) {
      els.formError.textContent = "Feil ved lagring: " + error.message;
      els.formError.hidden = false;
      return;
    }

    closeModal();
    loadContacts();
  });

  els.deleteBtn.addEventListener("click", async () => {
    if (!els.contactId.value) return;
    if (!confirm("Slette denne firmaet permanent? Dette kan ikke angres.")) return;
    const { error } = await supabase.from("contacts").delete().eq("id", els.contactId.value);
    if (error) {
      els.formError.textContent = "Feil ved sletting: " + error.message;
      els.formError.hidden = false;
      return;
    }
    closeModal();
    loadContacts();
  });

  // ---------- Activity log ----------

  async function loadActivities(contactId) {
    els.activityList.innerHTML = "<li>Laster…</li>";
    const { data, error } = await supabase
      .from("contact_activities")
      .select("*")
      .eq("contact_id", contactId)
      .order("created_at", { ascending: false });

    if (error) {
      els.activityList.innerHTML = `<li>Feil: ${escapeHtml(error.message)}</li>`;
      return;
    }
    if (!data || data.length === 0) {
      els.activityList.innerHTML = "<li>Ingen notater ennå.</li>";
      return;
    }
    els.activityList.innerHTML = data.map((a) => `
      <li class="activity-item">
        ${escapeHtml(a.note)}
        <span class="activity-meta">${escapeHtml(a.created_by_email || "")} · ${formatDateTime(a.created_at)}</span>
      </li>
    `).join("");
  }

  els.activityForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const contactId = els.contactId.value;
    const note = els.activityNote.value.trim();
    if (!contactId || !note) return;

    const { error } = await supabase.from("contact_activities").insert({
      contact_id: contactId,
      note,
    });
    if (error) {
      alert("Feil ved lagring av notat: " + error.message);
      return;
    }
    els.activityNote.value = "";
    loadActivities(contactId);
    loadContacts(); // updated_at endres ikke her, men holder lista i sync
  });

  checkSession();
})();
