// Tjenester subpage — reuses SERVICES, SERVICE_DETAILS, HISTORY, SVC_ICONS from data.jsx/icons.jsx

const { useEffect: useEffectTJ, useState: useStateTJ } = React;

function TjNav() {
  const [open, setOpen] = useStateTJ(false);
  useEffectTJ(() => {
    const onResize = () => { if (window.innerWidth > 860) setOpen(false); };
    window.addEventListener("resize", onResize);
    return () => window.removeEventListener("resize", onResize);
  }, []);
  const links = [
    { href: "index.html#tjenester", label: "Hjem" },
    { href: "tjenester.html", label: "Tjenester", active: true },
    { href: "index.html#prosjekter", label: "Prosjekter" },
    { href: "index.html#prosess", label: "Slik jobber vi" },
    { href: "index.html#utstyr", label: "Utstyr" },
    { href: "index.html#kontakt", label: "Kontakt" },
  ];
  return (
    <nav className="nav" data-screen-label="Nav">
      <div className="wrap nav-row">
        <a href="index.html#top" className="nav-logo">
          <img src="assets/norma-logo.png" alt="Norma Geosystems" width="221" height="44" decoding="async" />
        </a>
        <div className="nav-links">
          {links.map((l) => (
            <a key={l.label} href={l.href} style={l.active ? { color: "var(--yellow-deep)" } : undefined}>{l.label}</a>
          ))}
        </div>
        <a href="index.html#kontakt" className="nav-cta nav-cta-desktop">Be om tilbud</a>
        <button
          id="nav-toggle"
          className={"nav-toggle" + (open ? " open" : "")}
          aria-label={open ? "Lukk meny" : "Åpne meny"}
          aria-expanded={open}
          aria-controls="mobile-menu"
          onClick={() => setOpen((v) => !v)}
        >
          <span></span><span></span><span></span>
        </button>
      </div>
      <div className={"mobile-menu" + (open ? " open" : "")} id="mobile-menu">
        {links.map((l) => (
          <a key={l.label} href={l.href}
             style={l.active ? { color: "var(--yellow-deep)" } : undefined}
             onClick={() => setOpen(false)}>{l.label}</a>
        ))}
        <a href="index.html#kontakt" className="mm-cta" onClick={() => setOpen(false)}>Be om tilbud</a>
      </div>
    </nav>);
}

function TjHero() {
  return (
    <header className="tj-hero" data-screen-label="Tjenester · Hero">
      <div className="hero-topo"></div>
      <div className="wrap">
        <div className="tj-hero-inner">
          <div className="eyebrow" style={{ color: "var(--yellow)" }}>Tjenester</div>
          <h1>Fagområder som dekker <span className="accent">hele</span> byggeprosessen.</h1>
          <p className="tj-lede">
            Fra første fastmerke til ferdig dokumentasjon — vi leverer presis landmåling,
            3D-modellgrunnlag og kontroll til norske bygg-, anleggs- og infrastrukturprosjekter.
          </p>
          <nav className="tj-jump" aria-label="Hopp til tjeneste">
            {SERVICES.map((s) => (
              <a key={s.slug} href={`#${s.slug}`}>{s.name}</a>
            ))}
          </nav>
        </div>
      </div>
    </header>);
}

function TjHistory() {
  return (
    <section className="tj-history" data-screen-label="Historie">
      <div className="wrap tj-history-grid">
        <div>
          <div className="eyebrow">Historie</div>
          <h2>Fra håndtegnede kart til <span className="accent">digital presisjon</span>.</h2>
        </div>
        <div className="tj-history-body">
          {HISTORY.map((p, i) => <p key={i}>{p}</p>)}
        </div>
      </div>
    </section>);
}

function ServiceDetail({ s }) {
  const Ico = SVC_ICONS[s.icon];
  const d = SERVICE_DETAILS[s.slug];
  return (
    <section id={s.slug} className="svc-detail" data-screen-label={`Tjeneste · ${s.name}`}>
      <div className="wrap svc-detail-inner">
        <div className="svc-media">
          <picture>
            <source
              type="image/webp"
              srcSet={`assets/services/${s.slug}-720.webp 720w, assets/services/${s.slug}.webp 1440w`}
              sizes="(max-width: 920px) 90vw, 45vw" />
            <img src={`assets/services/${s.slug}.jpg`} alt={s.name} width="1440" height="960" loading="lazy" decoding="async" />
          </picture>
          <span className="svc-media-tag">{s.n} / 08</span>
        </div>
        <div className="svc-detail-content">
          <div className="svc-detail-num">
            <span className="ic"><Ico /></span>
            <span>{s.n} / 08</span>
            <span className="line"></span>
          </div>
          <h3>{s.name}</h3>
          <div className="svc-detail-slogan">{s.slogan[0]} {s.slogan[1]}</div>
          <p className="svc-detail-intro">{d.intro}</p>
          <div className="svc-scope">Driftsområde</div>
          <ul className="svc-bullets">
            {d.bullets.map((b, i) => <li key={i}>{b}</li>)}
          </ul>
        </div>
      </div>
    </section>);
}

function TjServices() {
  return (
    <div className="tj-services">
      {SERVICES.map((s) => <ServiceDetail key={s.slug} s={s} />)}
    </div>);
}

function TjCta() {
  return (
    <section className="tj-cta" data-screen-label="CTA">
      <div className="hero-topo"></div>
      <div className="wrap tj-cta-inner">
        <div>
          <h2>Har du et prosjekt? <span className="accent">Ta kontakt.</span></h2>
          <p>Vi svarer raskest på telefon og ringer deg tilbake innen samme arbeidsdag.</p>
        </div>
        <div className="hero-ctas">
          <a href="index.html#kontakt" className="btn btn-primary">Be om tilbud <span className="arr">→</span></a>
          <a href="tel:+4799074040" className="btn btn-ghost-dark">+47 99 07 40 40</a>
        </div>
      </div>
    </section>);
}

function TjFooter() {
  return (
    <footer className="footer" data-screen-label="Footer">
      <div className="wrap">
        <div className="foot-grid">
          <div className="foot-logo">
            <img src="assets/norma-logo-light.png" alt="Norma Geosystems" width="106" height="40" loading="lazy" decoding="async" />
            <p className="foot-tag">Landmåling og geomatikk for norske entreprenører. Oslo · siden 2008.</p>
          </div>
          <div className="foot-col">
            <h5>Tjenester</h5>
            <ul>
              {SERVICES.map((s) => <li key={s.slug}><a href={`#${s.slug}`}>{s.name}</a></li>)}
            </ul>
          </div>
          <div className="foot-col">
            <h5>Selskap</h5>
            <ul>
              <li><a href="index.html#prosjekter">Prosjekter</a></li>
              <li><a href="index.html#prosess">Slik jobber vi</a></li>
              <li><a href="index.html#utstyr">Utstyr</a></li>
              <li><a href="index.html#kontakt">Kontakt</a></li>
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

function TjApp() {
  useEffectTJ(() => {
    // The page is rendered by React after load, so a #hash in the URL has no
    // target element when the browser first tries to scroll. Resolve it here.
    const NAV_OFFSET = 84;
    const jumpTo = (hash) => {
      if (!hash) return;
      const el = document.getElementById(hash.replace(/^#/, ""));
      if (!el) return;
      const y = el.getBoundingClientRect().top + window.pageYOffset - NAV_OFFSET;
      window.scrollTo({ top: y, behavior: "auto" });
    };
    // wait a frame for layout (images use lazy aspect-ratio boxes, so layout is stable)
    const raf = requestAnimationFrame(() => jumpTo(window.location.hash));
    // second pass once everything (incl. fonts/images) has fully loaded
    const onLoad = () => jumpTo(window.location.hash);
    if (document.readyState === "complete") setTimeout(onLoad, 60);
    else window.addEventListener("load", onLoad);
    const onHash = () => jumpTo(window.location.hash);
    window.addEventListener("hashchange", onHash);
    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("load", onLoad);
      window.removeEventListener("hashchange", onHash);
    };
  }, []);

  return (
    <div>
      <TjNav />
      <TjHero />
      <TjHistory />
      <TjServices />
      <TjCta />
      <TjFooter />
    </div>);
}

ReactDOM.createRoot(document.getElementById("root")).render(<TjApp />);
