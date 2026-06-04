// Equipment, Testimonials, Contact, Footer, Cookie banner

function Equipment() {
  return (
    <section id="utstyr" className="section gray" data-screen-label="06 Utstyr">
      <div className="wrap">
        <div className="sec-head fade-in">
          <div>
            <div className="eyebrow">Utstyr & sertifisering</div>
            <h2 className="sec-title">
              Profesjonelt utstyr, <span className="accent">rektifisert</span> jevnlig.
            </h2>
          </div>
          <p className="sec-lede">Vi investerer i instrumenter som tåler norsk terreng og norsk vær. Alle våre Trimble og Leica enheter rektifiseres minst én gang i året.

          </p>
        </div>

        <div className="equip-wrap">
          <div className="equip-list">
            {EQUIPMENT.map((e, i) =>
            <div key={i} className="equip-row">
                <div className="brand">{e.brand}{e.qty && <span className="qty">{e.qty}</span>}</div>
                <div className="model">{e.model}<span className="etype">{e.type}</span></div>
                <div className="spec">{e.spec}</div>
              </div>
            )}
          </div>

          <div className="cert-card">
            <h4>Sertifisering & godkjenning</h4>
            <ul className="cert-list">
              {CERTS.map((c, i) =>
              <li key={i}><span className="tick">[✓]</span><span>{c}</span></li>
              )}
            </ul>
          </div>
        </div>
      </div>
    </section>);

}

function Contact() {
  const [sent, setSent] = useState(false);
  const [form, setForm] = useState({
    navn: "", firma: "", telefon: "", prosjekttype: "Bygg", melding: ""
  });

  const set = (k) => (e) => setForm({ ...form, [k]: e.target.value });

  const submit = (e) => {
    e.preventDefault();
    setSent(true);
    setTimeout(() => setSent(false), 5000);
  };

  return (
    <section id="kontakt" className="section contact" data-screen-label="08 Kontakt">
      <div className="wrap">
        <div className="sec-head fade-in">
          <div>
            <div className="eyebrow">Kontakt</div>
            <h2 className="sec-title">
              Har du et prosjekt? <span className="accent">Ring oss.</span>
            </h2>
          </div>
          <p className="sec-lede">
            Vi svarer raskest på telefon. Du kan også sende noen linjer her — vi ringer deg tilbake innen samme arbeidsdag.
          </p>
        </div>

        <div className="contact-wrap">
          <form onSubmit={submit}>
            {sent &&
            <div className="form-sent">
                ● Takk! Vi tar kontakt innen 24 timer. — Norma
              </div>
            }

            <div className="form-row">
              <div className="field">
                <label htmlFor="f-navn">Navn</label>
                <input id="f-navn" required value={form.navn} onChange={set("navn")} placeholder="Fornavn Etternavn" />
              </div>
              <div className="field">
                <label htmlFor="f-firma">Firma</label>
                <input id="f-firma" required value={form.firma} onChange={set("firma")} placeholder="Selskapsnavn AS" />
              </div>
            </div>

            <div className="form-row">
              <div className="field">
                <label htmlFor="f-tlf">Telefon</label>
                <input id="f-tlf" required type="tel" value={form.telefon} onChange={set("telefon")} placeholder="+47 000 00 000" />
              </div>
              <div className="field">
                <label htmlFor="f-type">Prosjekttype</label>
                <select id="f-type" value={form.prosjekttype} onChange={set("prosjekttype")}>
                  <option>Bygg</option>
                  <option>Vei / anlegg</option>
                  <option>Industri</option>
                  <option>Tomt / eiendom</option>
                  <option>3D-skanning</option>
                  <option>Annet</option>
                </select>
              </div>
            </div>

            <div className="field" style={{ marginBottom: 24 }}>
              <label htmlFor="f-msg">Melding</label>
              <textarea id="f-msg" value={form.melding} onChange={set("melding")} placeholder="Kort om prosjektet — sted, omfang, ønsket leveranse..." />
            </div>

            <div className="form-foot">
              <p className="consent">
                Ved å sende godtar du at vi lagrer kontaktinfoen din inntil saken er avsluttet. Vi deler aldri data med tredjepart.
              </p>
              <button type="submit" className="btn btn-primary">Send forespørsel <span className="arr">→</span></button>
            </div>
          </form>

          <aside className="contact-info">
            <div className="info-block">
              <div className="lbl">Telefon</div>
              <div className="val"><a href="tel:+4799074040">+47 99 07 40 40</a></div>
            </div>
            <div className="info-block">
              <div className="lbl">E-post</div>
              <div className="val"><a href="mailto:post@norma-gs.no">post@norma-gs.no</a></div>
            </div>
            <div className="info-block">
              <div className="lbl">Besøksadresse</div>
              <div className="val">Forseths veg 6<br />3520 Jevnaker</div>
            </div>
            <div className="info-block">
              <div className="lbl">Org.nr</div>
              <div className="val mono" style={{ fontSize: 16 }}>NO 825 831 622 MVA</div>
            </div>

            <div className="minimap" aria-hidden="true">
              <div className="minimap-grid"></div>
              <div className="minimap-pin">
                <span className="dot"></span>
                <span>JEVNAKER · E 576 820 N 6 685 240</span>
              </div>
            </div>
          </aside>
        </div>
      </div>
    </section>);

}

function Footer() {
  return (
    <footer className="footer" data-screen-label="09 Footer">
      <div className="wrap">
        <div className="foot-grid">
          <div className="foot-logo">
            <img src="assets/norma-logo-light.png" alt="Norma Geosystems" />
            <p className="foot-tag">Landmåling og geomatikk for norske entreprenører. Oslo · siden 2008.</p>
          </div>
          <div className="foot-col">
            <h5>Tjenester</h5>
            <ul>
              {SERVICES.map((s) =>
              <li key={s.slug}><a href={`tjenester.html#${s.slug}`}>{s.name}</a></li>
              )}
            </ul>
          </div>
          <div className="foot-col">
            <h5>Selskap</h5>
            <ul>
              <li><a href="#prosjekter">Prosjekter</a></li>
              <li><a href="#prosess">Slik jobber vi</a></li>
              <li><a href="#utstyr">Utstyr</a></li>
              <li><a href="#kontakt">Kontakt</a></li>
              <li><a href="https://www.linkedin.com/company/norma-geosystems/" target="_blank" rel="noopener noreferrer">LinkedIn ↗</a></li>
            </ul>
          </div>
          <div className="foot-col">
            <h5>Juridisk</h5>
            <ul>
              <li><a href="juridisk/personvern.html">Personvernerklæring</a></li>
              <li><a href="juridisk/informasjonskapsler.html">Informasjonskapsler</a></li>
              <li><a href="juridisk/vilkar.html">Vilkår</a></li>
            </ul>
          </div>
        </div>
        <div className="foot-bottom">
          <span>© 2026 NORMA GEOSYSTEMS AS · NO 825 831 622 MVA</span>
          <span>POST@NORMA-GS.NO · +47 99 07 40 40</span>
        </div>
      </div>
    </footer>);

}

function CookieBanner() {
  const [show, setShow] = useState(false);
  useEffect(() => {
    if (!localStorage.getItem("norma-cookie")) {
      const t = setTimeout(() => setShow(true), 1200);
      return () => clearTimeout(t);
    }
  }, []);
  const dismiss = (val) => {
    localStorage.setItem("norma-cookie", val);
    setShow(false);
  };
  if (!show) return null;
  return (
    <div className="cookie" role="dialog" aria-label="Cookie notice">
      <div className="ck-head">● Informasjonskapsler</div>
      <p style={{ margin: 0 }}>
        Vi bruker nødvendige cookies for at nettstedet skal fungere. Statistikk samles kun anonymt og kun hvis du sier ja. Du kan endre valget når som helst.
      </p>
      <div className="ck-actions">
        <button className="ck-btn primary" onClick={() => dismiss("all")}>Godta alle</button>
        <button className="ck-btn ghost" onClick={() => dismiss("necessary")}>Kun nødvendige</button>
      </div>
    </div>);

}

Object.assign(window, { Equipment, Contact, Footer, CookieBanner });