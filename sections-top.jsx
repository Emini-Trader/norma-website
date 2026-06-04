// Nav, Hero, Logo marquee, Services

const { useState, useEffect, useRef, useMemo } = React;

function useFadeIn() {
  useEffect(() => {
    const els = document.querySelectorAll(".fade-in");
    const io = new IntersectionObserver((entries) => {
      entries.forEach((e) => {if (e.isIntersecting) e.target.classList.add("in");});
    }, { threshold: 0.12 });
    els.forEach((el) => io.observe(el));
    return () => io.disconnect();
  }, []);
}

function Nav() {
  return (
    <nav className="nav" data-screen-label="Nav">
      <div className="wrap nav-row">
        <a href="#top" className="nav-logo">
          <img src="assets/norma-logo.png" alt="Norma Geosystems" />
        </a>
        <div className="nav-links">
          <a href="#tjenester">Tjenester</a>
          <a href="#prosjekter">Prosjekter</a>
          <a href="#prosess">Slik jobber vi</a>
          <a href="#utstyr">Utstyr</a>
          <a href="#kontakt">Kontakt</a>
        </div>
        <a href="#kontakt" className="nav-cta">Be om tilbud</a>
      </div>
    </nav>);

}

function FeltstasjonLive() {
  // Live readout for the active field station — Gjønnes, UTM32 / EUREF89
  const [t, setT] = useState(0);
  useEffect(() => {
    const id = setInterval(() => setT((x) => x + 1), 1400);
    return () => clearInterval(id);
  }, []);
  const driftN = (Math.sin(t * 0.7) * 0.3).toFixed(1);
  const hdop = (0.6 + Math.abs(Math.sin(t * 0.5)) * 0.2).toFixed(2);
  // tiny live jitter on easting/northing mm
  const eMm = (32 + Math.sin(t * 0.9) * 4).toFixed(0);
  const nMm = (873 + Math.cos(t * 0.6) * 5).toFixed(0);
  const time = new Date(Date.now()).toLocaleTimeString("nb-NO", { hour: "2-digit", minute: "2-digit", second: "2-digit" });

  return (
    <div className="feltstasjon">
      <span className="fs-corner tl"></span><span className="fs-corner tr"></span>
      <span className="fs-corner bl"></span><span className="fs-corner br"></span>

      <div className="fs-head">
        <span className="ttl">Feltstasjon · Gjønnes</span>
        <span className="live"><span className="dot"></span>LIVE</span>
      </div>

      <div className="fs-row"><span className="k">ØST (E)</span><span className="v">589 142.{eMm}</span><span className="u">m</span></div>
      <div className="fs-row"><span className="k">NORD (N)</span><span className="v">6 644 {nMm}</span><span className="u">m</span></div>
      <div className="fs-row"><span className="k">HØYDE</span><span className="v">96.412</span><span className="u">m / NN2000</span></div>
      <div className="fs-row"><span className="k">SONE</span><span className="v">UTM 32</span><span className="u">EUREF89</span></div>
      <div className="fs-row"><span className="k">RTK FIX</span><span className="v" style={{ color: "#F4BB29" }}>● FIXED</span><span className="u">int.amb.</span></div>
      <div className="fs-row"><span className="k">HDOP</span><span className="v">{hdop}</span><span className="u">σ</span></div>
      <div className="fs-row"><span className="k">DRIFT</span><span className="v">{driftN > 0 ? "+" : ""}{driftN}</span><span className="u">mm / 10min</span></div>
      <div className="fs-row"><span className="k">SAT</span><span className="v">22 / 31</span><span className="u">GPS+GAL+GLO</span></div>

      <div className="fs-foot">
        <span>{time} · OBS 014</span>
        <span className="fs-bar">SIGNAL<span className="bars"><i></i><i></i><i></i><i></i></span></span>
      </div>
    </div>);

}

function Hero() {
  return (
    <header id="top" className="hero" data-screen-label="01 Hero">
      <div className="hero-topo"></div>
      <div className="hero-corner"></div>
      <div className="wrap hero-inner">
        <div>
          <span className="badge">For entreprenører og utbyggere</span>
          <h1>NÅR <span className="accent">PRESISJON</span> TELLER</h1>
          <p className="hero-sub">
            Vi leverer presis stikning, innmåling og 3D-modellgrunnlag til norske byggeprosjekter. Riktig grunnlag fra første dag — uten omveier, uten kreativ tolkning.
          </p>
          <div className="hero-ctas">
            <a href="#prosjekter" className="btn btn-primary">Se prosjekter <span className="arr">→</span></a>
            <a href="#kontakt" className="btn btn-ghost-dark">Ta kontakt</a>
          </div>
          <div className="hero-stats">
            <div className="stat">
              <div className="num">±5<span style={{ fontSize: 22, marginLeft: 4 }}>mm</span></div>
              <div className="lbl">Nøyaktighet</div>
            </div>
            <div className="stat">
              <div className="num">xx+<span style={{ fontSize: 22, marginLeft: 4 }}></span></div>
              <div className="lbl">FORNØYE KUNDER</div>
            </div>
            <div className="stat">
              <div className="num">xx+</div>
              <div className="lbl">Prosjekter</div>
            </div>
          </div>
        </div>
        <FeltstasjonLive />
      </div>
    </header>);

}

function LogoBar() {
  // continuous right→left marquee; list duplicated for seamless loop
  const row = [...CLIENTS, ...CLIENTS];
  return (
    <section className="logobar" data-screen-label="02 Kunder">
      <div className="wrap">
        <div className="logobar-label">Vi har jobbet med</div>
      </div>
      <div className="marquee">
        <div className="marquee-track">
          {row.map((c, i) =>
          <a key={i} className="client-logo" href={c.url} target="_blank" rel="noopener noreferrer" title={c.name} aria-label={c.name}>
              <img src={`assets/clients/${c.slug}.png`} alt={c.name} />
            </a>
          )}
        </div>
      </div>
    </section>);

}

function Services() {
  return (
    <section id="tjenester" className="section" data-screen-label="03 Tjenester">
      <div className="wrap">
        <div className="sec-head fade-in">
          <div>
            <div className="eyebrow">Tjenester</div>
            <h2 className="sec-title">
              <span className="accent">8</span> leveranser som dekker hele byggeprosessen.
            </h2>
          </div>
          <p className="sec-lede">Fra første stikk til ferdig dokumentasjon.
            <a className="lede-link" href="tjenester.html">Les mer om våre kompetanser <span className="arr">→</span></a>
          </p>
        </div>

        <div className="svc-grid">
          {SERVICES.map((s) => {
            const Ico = SVC_ICONS[s.icon];
            return (
              <a key={s.slug} className="svc" href={`tjenester.html#${s.slug}`}>
                <div className="svc-num">{s.n} / 08</div>
                <div className="svc-icon"><Ico /></div>
                <h3 className="svc-title">{s.name}</h3>
                <div className="svc-slogan">{s.slogan[0]}<br />{s.slogan[1]}</div>
                <p className="svc-desc">{s.desc}</p>
                <span className="svc-link">Les mer <span className="arr">→</span></span>
              </a>);

          })}
        </div>
      </div>
    </section>);

}

Object.assign(window, { Nav, Hero, LogoBar, Services, useFadeIn });