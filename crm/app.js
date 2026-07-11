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
    fAddress: document.getElementById("f-address"),
    fStatus: document.getElementById("f-status"),
    deleteBtn: document.getElementById("delete-contact-btn"),
    peopleSection: document.getElementById("people-section"),
    peopleList: document.getElementById("people-list"),
    personAddForm: document.getElementById("person-add-form"),
    pNewName: document.getElementById("p-new-name"),
    pNewRole: document.getElementById("p-new-role"),
    pNewPhone: document.getElementById("p-new-phone"),
    pNewEmail: document.getElementById("p-new-email"),
    pNewPrimary: document.getElementById("p-new-primary"),
    activitySection: document.getElementById("activity-section"),
    activityList: document.getElementById("activity-list"),
    activityForm: document.getElementById("activity-form"),
    activityNote: document.getElementById("activity-note"),
  };

  let allContacts = [];
  let primaryContactNames = {}; // contact_id -> navn på hovedkontakt, for tabellvisning/søk

  function escapeHtml(str) {
    if (str == null) return "";
    return String(str).replace(/[&<>"']/g, (c) => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
    }[c]));
  }

  function editorName(profile) {
    if (!profile) return "";
    return profile.full_name || profile.email || "";
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
    const [{ data, error }, peopleRes] = await Promise.all([
      supabase
        .from("contacts")
        .select("*, updated_by_profile:profiles!updated_by(full_name, email)")
        .order("updated_at", { ascending: false }),
      supabase.from("contact_people").select("contact_id, full_name, is_primary").order("full_name"),
    ]);

    if (error) {
      els.tbody.innerHTML = `<tr><td colspan="6" class="empty-row">Feil ved lasting: ${escapeHtml(error.message)}</td></tr>`;
      return;
    }
    allContacts = data || [];

    primaryContactNames = {};
    (peopleRes.data || []).forEach((p) => {
      const existing = primaryContactNames[p.contact_id];
      if (!existing || (p.is_primary && !existing.is_primary)) {
        primaryContactNames[p.contact_id] = { name: p.full_name, is_primary: p.is_primary };
      }
    });

    renderContacts();
  }

  function renderContacts() {
    const search = els.searchInput.value.trim().toLowerCase();
    const statusFilterVal = els.statusFilter.value;

    const filtered = allContacts.filter((c) => {
      if (statusFilterVal && c.status !== statusFilterVal) return false;
      if (!search) return true;
      const personName = (primaryContactNames[c.id] || {}).name;
      const haystack = [c.company_name, personName, c.email, c.phone, c.address]
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
        <td>${escapeHtml((primaryContactNames[c.id] || {}).name)}</td>
        <td>${escapeHtml(c.phone)}</td>
        <td>${escapeHtml(c.email)}</td>
        <td><span class="status-badge status-${escapeHtml(c.status)}">${escapeHtml(STATUS_LABELS[c.status] || c.status)}</span></td>
        <td class="meta-cell">${formatDateTime(c.updated_at)}<br>${escapeHtml(editorName(c.updated_by_profile))}</td>
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
      els.fAddress.value = contact.address || "";
      els.fStatus.value = contact.status || "ny";
      els.deleteBtn.hidden = false;
      els.peopleSection.hidden = false;
      els.activitySection.hidden = false;
      loadPeople(contact.id);
      loadActivities(contact.id);
    } else {
      els.modalTitle.textContent = "Ny firma";
      els.contactId.value = "";
      els.fStatus.value = "ny";
      els.deleteBtn.hidden = true;
      els.peopleSection.hidden = true;
      els.peopleList.innerHTML = "";
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

  // ---------- Contact people (kontaktpersoner, flere per firma) ----------

  let currentPeople = [];

  function companyOptions(selectedId) {
    return allContacts
      .slice()
      .sort((a, b) => a.company_name.localeCompare(b.company_name, "no"))
      .map((c) => `<option value="${escapeHtml(c.id)}" ${c.id === selectedId ? "selected" : ""}>${escapeHtml(c.company_name)}</option>`)
      .join("");
  }

  async function loadPeople(contactId) {
    els.peopleList.innerHTML = "<li>Laster…</li>";
    const { data, error } = await supabase
      .from("contact_people")
      .select("*, updated_by_profile:profiles!updated_by(full_name, email)")
      .eq("contact_id", contactId)
      .order("is_primary", { ascending: false })
      .order("full_name");

    if (error) {
      els.peopleList.innerHTML = `<li>Feil: ${escapeHtml(error.message)}</li>`;
      return;
    }
    currentPeople = data || [];
    renderPeople();
  }

  function renderPeople() {
    if (currentPeople.length === 0) {
      els.peopleList.innerHTML = "<li>Ingen kontaktpersoner ennå.</li>";
      return;
    }
    els.peopleList.innerHTML = currentPeople.map((p) => `
      <li class="person-item" data-id="${escapeHtml(p.id)}">
        <form class="person-form">
          <div class="form-row">
            <input type="text" class="p-name" value="${escapeHtml(p.full_name)}" placeholder="Navn">
            <input type="text" class="p-role" value="${escapeHtml(p.role || "")}" placeholder="Stilling">
          </div>
          <div class="form-row">
            <input type="text" class="p-phone" value="${escapeHtml(p.phone || "")}" placeholder="Telefon">
            <input type="email" class="p-email" value="${escapeHtml(p.email || "")}" placeholder="E-post">
          </div>
          <div class="form-row">
            <label class="checkbox-label"><input type="checkbox" class="p-primary" ${p.is_primary ? "checked" : ""}> Hovedkontakt</label>
            <select class="p-company">${companyOptions(p.contact_id)}</select>
          </div>
          <div class="person-actions">
            <span class="meta-cell">${escapeHtml(editorName(p.updated_by_profile))} · ${formatDateTime(p.updated_at)}</span>
            <div class="person-actions-buttons">
              <button type="button" class="btn-danger btn-delete-person">Slett</button>
              <button type="submit" class="btn-ghost btn-save-person">Lagre</button>
            </div>
          </div>
        </form>
      </li>
    `).join("");
  }

  els.peopleList.addEventListener("submit", async (e) => {
    const li = e.target.closest("li.person-item");
    if (!li) return;
    e.preventDefault();

    const personId = li.dataset.id;
    const payload = {
      full_name: li.querySelector(".p-name").value.trim(),
      role: li.querySelector(".p-role").value.trim() || null,
      phone: li.querySelector(".p-phone").value.trim() || null,
      email: li.querySelector(".p-email").value.trim() || null,
      is_primary: li.querySelector(".p-primary").checked,
      contact_id: li.querySelector(".p-company").value,
    };

    const { error } = await supabase.from("contact_people").update(payload).eq("id", personId);
    if (error) {
      alert("Feil ved lagring av person: " + error.message);
      return;
    }
    loadPeople(els.contactId.value);
    loadContacts();
  });

  els.peopleList.addEventListener("click", async (e) => {
    if (!e.target.classList.contains("btn-delete-person")) return;
    const li = e.target.closest("li.person-item");
    if (!li) return;
    if (!confirm("Slette denne kontaktpersonen?")) return;

    const { error } = await supabase.from("contact_people").delete().eq("id", li.dataset.id);
    if (error) {
      alert("Feil ved sletting: " + error.message);
      return;
    }
    loadPeople(els.contactId.value);
  });

  els.personAddForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const contactId = els.contactId.value;
    const fullName = els.pNewName.value.trim();
    if (!contactId || !fullName) return;

    const { error } = await supabase.from("contact_people").insert({
      contact_id: contactId,
      full_name: fullName,
      role: els.pNewRole.value.trim() || null,
      phone: els.pNewPhone.value.trim() || null,
      email: els.pNewEmail.value.trim() || null,
      is_primary: els.pNewPrimary.checked,
    });
    if (error) {
      alert("Feil ved lagring av person: " + error.message);
      return;
    }
    els.personAddForm.reset();
    loadPeople(contactId);
    loadContacts();
  });

  // ---------- Activity log ----------

  async function loadActivities(contactId) {
    els.activityList.innerHTML = "<li>Laster…</li>";
    const { data, error } = await supabase
      .from("contact_activities")
      .select("*, created_by_profile:profiles!created_by(full_name, email)")
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
        <span class="activity-meta">${escapeHtml(editorName(a.created_by_profile))} · ${formatDateTime(a.created_at)}</span>
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
