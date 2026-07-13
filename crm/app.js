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

  // Status på hovedsiden er ikke lenger et eget felt - den følger contact_type til siste
  // Historikk-oppføring for firmaet (se lastActivity()/renderContacts()), "ny" = ingen
  // Historikk-oppføring ennå.
  const CONTACT_TYPE_LABELS = {
    ny: "Ny",
    epost: "E-post",
    telefon: "Telefon",
    mote: "Møte",
    annet: "Annet",
    avslatt: "Avslått",
    svar_fra_kunden: "Svar fra kunden",
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
    modalEditBtn: document.getElementById("modal-edit-btn"),
    modalClose: document.getElementById("modal-close"),
    modalCancel: document.getElementById("modal-cancel"),
    viewSummary: document.getElementById("view-summary"),
    vPhone: document.getElementById("v-phone"),
    vEmail: document.getElementById("v-email"),
    vWebsite: document.getElementById("v-website"),
    vAddress: document.getElementById("v-address"),
    vCountry: document.getElementById("v-country"),
    vSpecialties: document.getElementById("v-specialties"),
    vStatus: document.getElementById("v-status"),
    contactForm: document.getElementById("contact-form"),
    formError: document.getElementById("form-error"),
    contactId: document.getElementById("contact-id"),
    fCompany: document.getElementById("f-company"),
    fPhone: document.getElementById("f-phone"),
    fEmail: document.getElementById("f-email"),
    fWebsite: document.getElementById("f-website"),
    fAddress: document.getElementById("f-address"),
    fCountry: document.getElementById("f-country"),
    fSpecialties: document.getElementById("f-specialties"),
    deleteBtn: document.getElementById("delete-contact-btn"),
    peopleSection: document.getElementById("people-section"),
    peopleHint: document.getElementById("people-hint"),
    peopleList: document.getElementById("people-list"),
    personAddForm: document.getElementById("person-add-form"),
    pNewName: document.getElementById("p-new-name"),
    pNewRole: document.getElementById("p-new-role"),
    pNewPhone: document.getElementById("p-new-phone"),
    pNewEmail: document.getElementById("p-new-email"),
    pNewPrimary: document.getElementById("p-new-primary"),
    activitySection: document.getElementById("activity-section"),
    activityTbody: document.getElementById("activity-tbody"),
    activityForm: document.getElementById("activity-form"),
    activityDate: document.getElementById("activity-date"),
    activityPerson: document.getElementById("activity-person"),
    activityType: document.getElementById("activity-type"),
    activityNote: document.getElementById("activity-note"),
    activityAttachmentInput: document.getElementById("activity-attachment-input"),
  };

  let allContacts = [];
  let primaryContactNames = {}; // contact_id -> navn på hovedkontakt, for tabellvisning/søk
  let latestActivityByContact = {}; // contact_id -> siste contact_activities-rad (occurred_at, contact_type, redigert av)
  let sortState = { column: "last_activity", direction: "desc" };
  let modalMode = "view"; // "view" (kun lesing) eller "edit"
  let allSpecialties = []; // { id, name }, lastet én gang
  let currentSpecialtyIds = new Set();

  function escapeHtml(str) {
    if (str == null) return "";
    return String(str).replace(/[&<>"']/g, (c) => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
    }[c]));
  }

  function editorName(profile) {
    if (!profile) return "";
    return profile.first_name || profile.email || "";
  }

  function groupDigits(digits, sizes) {
    // sizes f.eks. [3,2,3] -> grupperer digits etter disse lengdene, resten i grupper på 3
    const groups = [];
    let i = 0;
    let s = 0;
    while (i < digits.length) {
      const size = sizes[s] || 3;
      groups.push(digits.slice(i, i + size));
      i += size;
      s++;
    }
    return groups.join(" ");
  }

  function formatPhone(raw) {
    if (!raw) return "";
    let s = raw.replace(/^tel[:.]?\s*/i, "").trim();
    if (!s) return "";
    s = s.replace(/^00/, "+"); // 00-prefiks = internasjonalt, tilsvarer +
    const cleaned = s.replace(/[^\d+]/g, "");
    if (!cleaned) return raw.trim();

    const intlMatch = cleaned.match(/^\+(\d{2})/);
    if (intlMatch && intlMatch[1] !== "47") {
      // Utenlandsk nummer: landskode + siffer i grupper på 3
      const rest = cleaned.slice(intlMatch[0].length);
      return `+${intlMatch[1]} ${groupDigits(rest, [3, 3, 3])}`.trim();
    }

    // Norsk nummer (med eller uten +47) - 8 siffer, gruppert xxx xx xxx
    const local = cleaned.replace(/^\+47/, "");
    if (local.length === 8) {
      return groupDigits(local, [3, 2, 3]);
    }
    return local || raw.trim();
  }

  function formatDateTime(iso) {
    if (!iso) return "";
    const d = new Date(iso);
    return d.toLocaleString("no-NO", { day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit" });
  }

  function formatDateOnly(iso) {
    if (!iso) return "";
    const d = new Date(iso);
    return d.toLocaleDateString("no-NO", { day: "2-digit", month: "2-digit", year: "numeric" });
  }

  function formatDate(dateStr) {
    if (!dateStr) return "";
    const [y, m, d] = dateStr.split("-");
    return `${d}.${m}.${y}`;
  }

  function todayStr() {
    return new Date().toISOString().slice(0, 10);
  }

  function websiteHref(url) {
    if (!url) return "";
    return /^https?:\/\//i.test(url) ? url : "https://" + url;
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
    loadSpecialtiesList();
  }

  async function loadSpecialtiesList() {
    const { data, error } = await supabase.from("specialties").select("id, name").order("name");
    if (!error) allSpecialties = data || [];
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
    const [{ data, error }, peopleRes, activitiesRes] = await Promise.all([
      supabase
        .from("contacts")
        .select("*, updated_by_profile:profiles!updated_by(first_name, email)")
        .order("updated_at", { ascending: false }),
      supabase.from("contact_people").select("contact_id, full_name, is_primary").order("full_name"),
      supabase
        .from("contact_activities")
        .select("contact_id, occurred_at, contact_type, created_by_profile:profiles!created_by(first_name, email)")
        .order("occurred_at", { ascending: false })
        .order("created_at", { ascending: false }),
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

    latestActivityByContact = {};
    (activitiesRes.data || []).forEach((a) => {
      if (!latestActivityByContact[a.contact_id]) {
        latestActivityByContact[a.contact_id] = a; // sortert synkende - forste treff er nyest
      }
    });

    renderContacts();
  }

  // Status på hovedsiden = contact_type til siste Historikk-oppføring ("ny" = ingen ennå)
  function lastActivity(c) {
    return latestActivityByContact[c.id];
  }

  function lastActivityIso(c) {
    const a = lastActivity(c);
    return (a && a.occurred_at) || c.updated_at;
  }

  function lastActivityTime(c) {
    const iso = lastActivityIso(c);
    return iso ? new Date(iso).getTime() : 0;
  }

  function lastActivityTypeKey(c) {
    const a = lastActivity(c);
    return a ? a.contact_type : "ny";
  }

  function lastActivityEditorName(c) {
    const a = lastActivity(c);
    return editorName(a ? a.created_by_profile : c.updated_by_profile);
  }

  function renderContacts() {
    const search = els.searchInput.value.trim().toLowerCase();
    const statusFilterVal = els.statusFilter.value;

    const filtered = allContacts.filter((c) => {
      if (statusFilterVal && lastActivityTypeKey(c) !== statusFilterVal) return false;
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

    filtered.sort((a, b) => {
      let cmp;
      if (sortState.column === "company_name") {
        cmp = a.company_name.localeCompare(b.company_name, "no");
      } else {
        cmp = lastActivityTime(a) - lastActivityTime(b);
      }
      if (sortState.direction === "desc") cmp = -cmp;
      if (cmp !== 0) return cmp;
      return a.company_name.localeCompare(b.company_name, "no"); // uavhengig tie-break, alltid A->Å
    });

    els.tbody.innerHTML = filtered.map((c) => {
      const typeKey = lastActivityTypeKey(c);
      return `
      <tr data-id="${escapeHtml(c.id)}">
        <td class="company-cell">${escapeHtml(c.company_name)}</td>
        <td>${escapeHtml((primaryContactNames[c.id] || {}).name)}</td>
        <td>${escapeHtml(formatPhone(c.phone))}</td>
        <td><span class="status-badge status-${escapeHtml(typeKey)}">${escapeHtml(CONTACT_TYPE_LABELS[typeKey] || typeKey)}</span></td>
        <td class="meta-cell">${formatDateOnly(lastActivityIso(c))}</td>
        <td class="meta-cell">${escapeHtml(lastActivityEditorName(c))}</td>
      </tr>
    `;
    }).join("");
  }

  function updateSortArrows() {
    document.querySelectorAll(".contacts-table th.sortable").forEach((th) => {
      const arrow = th.querySelector(".sort-arrow");
      if (th.dataset.sort === sortState.column) {
        arrow.textContent = sortState.direction === "asc" ? "▲" : "▼";
      } else {
        arrow.textContent = "";
      }
    });
  }

  document.querySelectorAll(".contacts-table th.sortable").forEach((th) => {
    th.addEventListener("click", () => {
      const column = th.dataset.sort;
      if (sortState.column === column) {
        sortState.direction = sortState.direction === "asc" ? "desc" : "asc";
      } else {
        sortState.column = column;
        sortState.direction = column === "company_name" ? "asc" : "desc";
      }
      updateSortArrows();
      renderContacts();
    });
  });

  updateSortArrows();

  els.searchInput.addEventListener("input", renderContacts);
  els.statusFilter.addEventListener("change", renderContacts);

  els.tbody.addEventListener("click", (e) => {
    const row = e.target.closest("tr[data-id]");
    if (!row) return;
    const contact = allContacts.find((c) => c.id === row.dataset.id);
    if (contact) openModal(contact);
  });

  // ---------- Modal: view / edit contact ----------

  let currentContact = null;

  els.newContactBtn.addEventListener("click", () => openModal(null));
  els.modalClose.addEventListener("click", closeModal);
  els.modalCancel.addEventListener("click", () => {
    if (currentContact) {
      fillContact(currentContact);
      setMode("view");
    } else {
      closeModal();
    }
  });
  els.modalEditBtn.addEventListener("click", () => setMode("edit"));
  els.modal.addEventListener("click", (e) => {
    if (e.target === els.modal) closeModal();
  });

  function setMode(mode) {
    modalMode = mode;
    const isEdit = mode === "edit";
    els.viewSummary.hidden = isEdit;
    els.contactForm.hidden = !isEdit;
    els.modalEditBtn.hidden = isEdit || !els.contactId.value;
    els.peopleHint.hidden = !isEdit;
    els.personAddForm.hidden = !isEdit;
    els.activityForm.hidden = !isEdit;
    if (isEdit && !els.activityDate.value) {
      els.activityDate.value = todayStr();
    }
    renderPeople();
    renderActivities();
    renderSpecialties();
  }

  function fillContact(contact) {
    currentContact = contact;
    els.modalTitle.textContent = contact.company_name;
    els.contactId.value = contact.id;
    els.fCompany.value = contact.company_name || "";
    els.fPhone.value = contact.phone || "";
    els.fEmail.value = contact.email || "";
    els.fWebsite.value = contact.website || "";
    els.fAddress.value = contact.address || "";
    els.fCountry.value = contact.country || "";

    els.vPhone.textContent = formatPhone(contact.phone) || "—";
    els.vEmail.textContent = contact.email || "—";
    if (contact.website) {
      els.vWebsite.innerHTML = `<a href="${escapeHtml(websiteHref(contact.website))}" target="_blank" rel="noopener">${escapeHtml(contact.website)}</a>`;
    } else {
      els.vWebsite.textContent = "—";
    }
    els.vAddress.textContent = contact.address || "—";
    els.vCountry.textContent = contact.country || "—";
    const typeKey = lastActivityTypeKey(contact);
    els.vStatus.innerHTML = `<span class="status-badge status-${escapeHtml(typeKey)}">${escapeHtml(CONTACT_TYPE_LABELS[typeKey] || typeKey)}</span>`;
  }

  async function loadContactSpecialties(contactId) {
    const { data, error } = await supabase.from("contact_specialties").select("specialty_id").eq("contact_id", contactId);
    currentSpecialtyIds = new Set(error ? [] : (data || []).map((r) => r.specialty_id));
    renderSpecialties();
  }

  function renderSpecialties() {
    const names = allSpecialties.filter((s) => currentSpecialtyIds.has(s.id)).map((s) => s.name);
    els.vSpecialties.innerHTML = names.length
      ? names.map((n) => `<span class="specialty-tag">${escapeHtml(n)}</span>`).join("")
      : "—";

    els.fSpecialties.innerHTML = allSpecialties.map((s) => `
      <label class="checkbox-label">
        <input type="checkbox" class="spec-checkbox" value="${escapeHtml(s.id)}" ${currentSpecialtyIds.has(s.id) ? "checked" : ""}>
        ${escapeHtml(s.name)}
      </label>
    `).join("");
  }

  function openModal(contact) {
    els.formError.hidden = true;
    els.contactForm.reset();
    els.personAddForm.reset();
    els.activityForm.reset();
    if (contact) {
      fillContact(contact);
      els.deleteBtn.hidden = false;
      els.peopleSection.hidden = false;
      els.activitySection.hidden = false;
      loadPeople(contact.id);
      loadActivities(contact.id);
      loadContactSpecialties(contact.id);
      setMode("view");
    } else {
      currentContact = null;
      els.modalTitle.textContent = "Ny firma";
      els.contactId.value = "";
      els.fCountry.value = "";
      els.deleteBtn.hidden = true;
      els.peopleSection.hidden = true;
      els.peopleList.innerHTML = "";
      els.activitySection.hidden = true;
      els.activityTbody.innerHTML = "";
      currentPeople = [];
      currentActivities = [];
      currentSpecialtyIds = new Set();
      renderSpecialties();
      setMode("edit");
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
      country: els.fCountry.value.trim() || null,
    };
    const selectedSpecialtyIds = Array.from(els.fSpecialties.querySelectorAll(".spec-checkbox:checked")).map((cb) => cb.value);

    const isUpdate = !!els.contactId.value;
    let error;
    let savedContactId = els.contactId.value;

    if (isUpdate) {
      ({ error } = await supabase.from("contacts").update(payload).eq("id", savedContactId));
    } else {
      const { data, error: insertError } = await supabase.from("contacts").insert(payload).select("id").single();
      error = insertError;
      if (data) savedContactId = data.id;
    }

    if (error) {
      els.formError.textContent = "Feil ved lagring: " + error.message;
      els.formError.hidden = false;
      return;
    }

    if (savedContactId) {
      const toAdd = selectedSpecialtyIds.filter((id) => !currentSpecialtyIds.has(id));
      const toRemove = Array.from(currentSpecialtyIds).filter((id) => !selectedSpecialtyIds.includes(id));
      if (toAdd.length) {
        await supabase.from("contact_specialties").insert(toAdd.map((sid) => ({ contact_id: savedContactId, specialty_id: sid })));
      }
      if (toRemove.length) {
        await supabase.from("contact_specialties").delete().eq("contact_id", savedContactId).in("specialty_id", toRemove);
      }
    }

    await loadContacts();

    if (isUpdate) {
      const fresh = allContacts.find((c) => c.id === els.contactId.value);
      if (fresh) fillContact(fresh);
      await loadContactSpecialties(savedContactId);
      setMode("view");
    } else {
      closeModal();
    }
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

  function populateActivityPersonSelect() {
    const current = els.activityPerson.value;
    els.activityPerson.innerHTML = '<option value="">Med hvem (valgfritt)</option>' +
      currentPeople.map((p) => `<option value="${escapeHtml(p.id)}">${escapeHtml(p.full_name)}</option>`).join("");
    els.activityPerson.value = current;
  }

  async function loadPeople(contactId) {
    els.peopleList.innerHTML = "<li>Laster…</li>";
    const { data, error } = await supabase
      .from("contact_people")
      .select("*, updated_by_profile:profiles!updated_by(first_name, email)")
      .eq("contact_id", contactId)
      .order("is_primary", { ascending: false })
      .order("full_name");

    if (error) {
      els.peopleList.innerHTML = `<li>Feil: ${escapeHtml(error.message)}</li>`;
      return;
    }
    currentPeople = data || [];
    populateActivityPersonSelect();
    renderPeople();
  }

  function renderPeople() {
    if (currentPeople.length === 0) {
      els.peopleList.innerHTML = "<li>Ingen kontaktpersoner ennå.</li>";
      return;
    }

    if (modalMode !== "edit") {
      els.peopleList.innerHTML = currentPeople.map((p) => `
        <li class="person-item-view">
          <div class="person-view-name">${escapeHtml(p.full_name)}${p.is_primary ? ' <span class="primary-badge">Hovedkontakt</span>' : ""}</div>
          ${p.role ? `<div class="person-view-role">${escapeHtml(p.role)}</div>` : ""}
          <div class="meta-cell">${escapeHtml(formatPhone(p.phone))} ${p.phone && p.email ? "·" : ""} ${escapeHtml(p.email)}</div>
        </li>
      `).join("");
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
            <span class="meta-cell">${[editorName(p.updated_by_profile), formatDateTime(p.updated_at)].filter(Boolean).map(escapeHtml).join(" · ")}</span>
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

  // ---------- Activity log (Historikk) ----------

  const ATTACHMENT_BUCKET = "activity-attachments";

  let currentActivities = [];
  let currentAttachmentsByActivity = {}; // activity_id -> [{id, file_name, storage_path}, ...]

  async function loadActivities(contactId) {
    els.activityTbody.innerHTML = '<tr><td colspan="6">Laster…</td></tr>';
    const { data, error } = await supabase
      .from("contact_activities")
      .select("*, created_by_profile:profiles!created_by(first_name, email), person:contact_people!person_id(full_name)")
      .eq("contact_id", contactId)
      .order("occurred_at", { ascending: false })
      .order("created_at", { ascending: false });

    if (error) {
      els.activityTbody.innerHTML = `<tr><td colspan="6">Feil: ${escapeHtml(error.message)}</td></tr>`;
      return;
    }
    currentActivities = data || [];
    await loadAttachments(currentActivities.map((a) => a.id));
    renderActivities();
  }

  async function loadAttachments(activityIds) {
    currentAttachmentsByActivity = {};
    if (!activityIds.length) return;
    const { data, error } = await supabase
      .from("contact_activity_attachments")
      .select("id, activity_id, file_name, storage_path")
      .in("activity_id", activityIds)
      .order("created_at");
    if (error) return;
    (data || []).forEach((att) => {
      (currentAttachmentsByActivity[att.activity_id] = currentAttachmentsByActivity[att.activity_id] || []).push(att);
    });
  }

  function renderActivities() {
    if (currentActivities.length === 0) {
      els.activityTbody.innerHTML = '<tr><td colspan="6" class="empty-row">Ingen historikk ennå.</td></tr>';
      return;
    }
    els.activityTbody.innerHTML = currentActivities.map((a) => {
      const attachments = currentAttachmentsByActivity[a.id] || [];
      const attachmentsHtml = attachments.length
        ? attachments.map((att) => `<a href="#" class="attachment-link" data-path="${escapeHtml(att.storage_path)}">${escapeHtml(att.file_name)}</a>`).join("<br>")
        : "—";
      return `
      <tr>
        <td>${formatDate(a.occurred_at)}</td>
        <td>${escapeHtml(editorName(a.created_by_profile))}</td>
        <td>${escapeHtml((a.person || {}).full_name)}</td>
        <td>${escapeHtml(CONTACT_TYPE_LABELS[a.contact_type] || a.contact_type)}</td>
        <td>${escapeHtml(a.note)}</td>
        <td>${attachmentsHtml}</td>
      </tr>
    `;
    }).join("");
  }

  els.activityTbody.addEventListener("click", async (e) => {
    const link = e.target.closest(".attachment-link");
    if (!link) return;
    e.preventDefault();
    const { data, error } = await supabase.storage.from(ATTACHMENT_BUCKET).createSignedUrl(link.dataset.path, 60);
    if (error) {
      alert("Feil ved henting av vedlegg: " + error.message);
      return;
    }
    window.open(data.signedUrl, "_blank", "noopener");
  });

  els.activityForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const contactId = els.contactId.value;
    const note = els.activityNote.value.trim();
    if (!contactId || !note) return;

    const { data: inserted, error } = await supabase
      .from("contact_activities")
      .insert({
        contact_id: contactId,
        occurred_at: els.activityDate.value || todayStr(),
        person_id: els.activityPerson.value || null,
        contact_type: els.activityType.value,
        note,
      })
      .select("id")
      .single();
    if (error) {
      alert("Feil ved lagring av notat: " + error.message);
      return;
    }

    const files = Array.from(els.activityAttachmentInput.files || []);
    for (const file of files) {
      const path = `${inserted.id}/${crypto.randomUUID()}-${file.name}`;
      const { error: uploadError } = await supabase.storage.from(ATTACHMENT_BUCKET).upload(path, file);
      if (uploadError) {
        alert(`Feil ved opplasting av vedlegg «${file.name}»: ${uploadError.message}`);
        continue;
      }
      await supabase.from("contact_activity_attachments").insert({
        activity_id: inserted.id,
        file_name: file.name,
        storage_path: path,
        content_type: file.type || null,
        size_bytes: file.size,
      });
    }

    els.activityNote.value = "";
    els.activityDate.value = todayStr();
    els.activityPerson.value = "";
    els.activityAttachmentInput.value = "";
    loadActivities(contactId);
    loadContacts().then(() => {
      const fresh = allContacts.find((c) => c.id === contactId);
      if (fresh) currentContact = fresh;
    });
  });

  checkSession();
})();
