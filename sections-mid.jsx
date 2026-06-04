// Projects (contour map + list + filters) and Process

const MAP_W = 100;
const MAP_H = typeof NORWAY_MAP_H !== "undefined" ? NORWAY_MAP_H : 124.02;

// Latitude reference lines — fitted to the contour extent (top ≈ Nordkapp 71°N,
// bottom ≈ southern tip 58°N), placed at round even degrees.
const LAT_LINES = [
{ y: 10, l: "70°N" }, { y: 29, l: "68°N" }, { y: 48, l: "66°N" },
{ y: 66, l: "64°N" }, { y: 85, l: "62°N" }, { y: 104, l: "60°N" }, { y: 123, l: "58°N" }];

// Dot lattice — fills the whole background, 4 rows between each pair of parallels
const DOT_XS = (() => {const a = [];for (let x = -2; x <= 103; x += 5) a.push(x);return a;})();
const DOT_YS = (() => {
  const ys = LAT_LINES.map((d) => d.y);
  const rows = [];
  for (let i = 0; i < ys.length - 1; i++) {
    const a = ys[i],b = ys[i + 1];
    for (let k = 1; k <= 4; k++) rows.push(+(a + (b - a) * k / 5).toFixed(2));
  }
  const step = (ys[1] - ys[0]) / 5;
  for (let y = ys[0] - step; y > -4; y -= step) rows.push(+y.toFixed(2));
  for (let y = ys[ys.length - 1] + step; y < 128; y += step) rows.push(+y.toFixed(2));
  return rows;
})();

function NorwayMap({ projects, activeId, onPick }) {
  return (
    <div className="map-svg-wrap">
      <svg className="map-overlay" viewBox={`-3 -3 ${MAP_W + 6} ${MAP_H + 6}`} preserveAspectRatio="xMidYMid meet">
        <g className="map-lat">
          {LAT_LINES.map(({ y, l }) =>
          <g key={y}>
              <line x1="-3" y1={y} x2={MAP_W + 3} y2={y} />
              <text className="lat-label" x="-2" y={y - 1.4}>{l}</text>
            </g>
          )}
        </g>
        <g className="map-dots-g">
          {DOT_YS.map((y) => DOT_XS.map((x) =>
          <circle key={x + "-" + y} cx={x} cy={y} r="0.38" />
          ))}
        </g>

        <path className="norway-shape" d={NORWAY_D} />

        {/* Interactive project pins */}
        {projects.map((p) => {
          const active = p.id === activeId;
          return (
            <g key={p.id} className={"pin" + (active ? " active" : "")} transform={`translate(${p.pos.x},${p.pos.y})`} onClick={() => onPick(p.id)}>
              {active && <circle className="pin-ring" cx="0" cy="0" r="1.6" />}
              <circle className="pin-hit" cx="0" cy="0" r="4" />
              <circle className="pin-dot" cx="0" cy="0" r={active ? 1.9 : 1.4} />
            </g>);

        })}
      </svg>
    </div>);

}

function Projects() {
  const [filter, setFilter] = useState("Alle");
  const filters = ["Alle", "Bygg", "Vei", "Industri"];
  const list = useMemo(
    () => filter === "Alle" ? PROJECTS : PROJECTS.filter((p) => p.cat === filter),
    [filter]
  );
  const [activeId, setActiveId] = useState(list[0]?.id);

  useEffect(() => {
    if (!list.find((p) => p.id === activeId)) setActiveId(list[0]?.id);
  }, [filter, list, activeId]);

  const active = list.find((p) => p.id === activeId);

  return (
    <section id="prosjekter" className="section dark" data-screen-label="04 Prosjekter">
      <div className="wrap">
        <div className="sec-head fade-in">
          <div>
            <div className="eyebrow">Prosjekter</div>
            <h2 className="sec-title">
              <span className="accent">xx+</span> oppdrag. Vest, sør og helt nord.
            </h2>
          </div>
          <p className="sec-lede">
            Klikk en pinne på kartet eller bla i listen. Alle koordinater oppgis i UTM 32 / EUREF89.
          </p>
        </div>

        <div className="proj-wrap">
          <div className="map-card">
            <div className="map-head">
              <span>NORGE · EUREF89 / UTM 32</span>
              <span className="coord">{active ? `E ${active.E} · N ${active.N}` : "—"}</span>
            </div>
            <NorwayMap projects={list} activeId={activeId} onPick={setActiveId} />
          </div>

          <div>
            <div className="proj-controls">
              {filters.map((f) =>
              <button key={f} className={"filter" + (f === filter ? " active" : "")} onClick={() => setFilter(f)}>{f}</button>
              )}
              <span className="filter-count">{list.length.toString().padStart(2, "0")} / {PROJECTS.length.toString().padStart(2, "0")}</span>
            </div>

            <div className="proj-list">
              {list.map((p, i) =>
              <div key={p.id} className={"proj-card" + (p.id === activeId ? " active" : "")} onClick={() => setActiveId(p.id)}>
                  <div className="idx">{String(i + 1).padStart(2, "0")}</div>
                  <div>
                    <h4>{p.title}</h4>
                    <div className="meta">{p.region}<span className="sep">·</span>{p.year}<span className="sep">·</span>E {p.E}</div>
                  </div>
                  <div className="tag">{p.cat}</div>
                </div>
              )}
            </div>

            {active &&
            <div className="proj-detail">
                <h5>Oppdraget</h5>
                <p>{active.desc}</p>
              </div>
            }
          </div>
        </div>
      </div>
    </section>);

}

function Process() {
  return (
    <section id="prosess" className="section" data-screen-label="05 Prosess">
      <div className="wrap">
        <div className="sec-head fade-in">
          <div>
            <div className="eyebrow">Slik jobber vi</div>
            <h2 className="sec-title">
              Fire steg. <span className="accent">Ingen</span> overraskelser.
            </h2>
          </div>
          <p className="sec-lede">Hver fase har en konkret leveranse. Du vet alltid hvor i prosessen vi er og hva som kommer ut i andre enden.

          </p>
        </div>

        <div className="process-grid">
          {PROCESS.map((s) =>
          <div key={s.n} className="step">
              <div className="step-num">STEG {s.n}</div>
              <h4>{s.title}</h4>
              <p>{s.desc}</p>
              <div className="step-out">
                <span className="lbl">{s.out.lbl}</span><br />
                <strong>{s.out.val}</strong>
              </div>
            </div>
          )}
        </div>
      </div>
    </section>);

}

Object.assign(window, { Projects, Process });