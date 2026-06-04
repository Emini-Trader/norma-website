// Single-color outline icons for the 8 services

const Icon = ({ children, className = "" }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
    {children}
  </svg>
);

// 01 — road (perspective with centre line)
const IconRoad = () => (
  <Icon>
    <path d="M8 21 L10.5 3" />
    <path d="M16 21 L13.5 3" />
    <path d="M12 4.5v2.5" />
    <path d="M12 10.5v3" />
    <path d="M12 17v3.5" />
  </Icon>
);

// 02 — irregular triangulated control network (polygon mesh) with marked points
const IconNet = () => {
  const pts = {
    a: [4, 8.5], b: [11, 4.5], c: [18.5, 7],
    d: [20.5, 14.5], e: [14.5, 12], f: [8, 11],
    g: [5.5, 16.5], h: [13, 19.5], i: [19, 18.5],
  };
  const edges = [
    "a,b", "b,c", "a,f", "b,f", "b,e", "c,e", "c,d", "e,d",
    "a,g", "f,g", "f,e", "f,h", "g,h", "e,h", "e,i", "d,i", "h,i",
  ];
  return (
    <Icon>
      {edges.map((pair, k) => {
        const [p, q] = pair.split(",");
        return <line key={k} x1={pts[p][0]} y1={pts[p][1]} x2={pts[q][0]} y2={pts[q][1]} />;
      })}
      {Object.values(pts).map(([x, y], k) => (
        <circle key={"n" + k} cx={x} cy={y} r="1.05" fill="currentColor" stroke="none" />
      ))}
    </Icon>
  );
};

// 03 — topographic contour lines (organic nested loops, like a contour map)
const IconContour = () => (
  <Icon>
    <path d="M2.5 14.5 C2 10 6 5.5 11 5 C16.5 4.5 21.5 7.5 21.5 12 C21.5 17 16 20.5 10.5 19.5 C6 18.7 3 17 2.5 14.5 Z" />
    <path d="M6 14 C5.7 11 8.3 8.3 11.6 8.1 C15.2 7.9 18.3 9.8 18.2 12.4 C18.1 15.6 14.8 17.6 11.3 16.9 C8.4 16.3 6.2 15.5 6 14 Z" />
    <path d="M9.4 13.6 C9.2 11.9 10.7 10.7 12.5 10.8 C14.3 10.9 15.3 12 15 13.4 C14.7 14.9 12.9 15.4 11.4 14.9 C10.3 14.5 9.5 14.3 9.4 13.6 Z" />
    <circle cx="12.4" cy="12.7" r="0.5" fill="currentColor" stroke="none" />
  </Icon>
);

// 04 — railway track
const IconRail = () => (
  <Icon>
    <path d="M9 3 L9 21" />
    <path d="M15 3 L15 21" />
    <path d="M6.5 6.5h11" />
    <path d="M6.5 11h11" />
    <path d="M6.5 15.5h11" />
    <path d="M6.5 20h11" />
  </Icon>
);

// 05 — laser burst: horizontal through-beam + dense radiating spokes of alternating length
const IconLaser = () => {
  const cx = 12, cy = 12, inner = 3.2;
  const rays = [];
  for (let a = 0; a < 360; a += 15) {
    if (a === 0 || a === 180) continue; // horizontal handled as through-beam
    let outer;
    if (a === 90 || a === 270) outer = 9.8;
    else if (a % 30 === 0) outer = 8.0;
    else outer = 6.2;
    const rad = a * Math.PI / 180;
    rays.push([
      cx + inner * Math.cos(rad), cy + inner * Math.sin(rad),
      cx + outer * Math.cos(rad), cy + outer * Math.sin(rad),
    ]);
  }
  return (
    <Icon>
      <line x1="1" y1="12" x2="23" y2="12" />
      {rays.map(([x1, y1, x2, y2], k) => (
        <line key={k} x1={x1.toFixed(2)} y1={y1.toFixed(2)} x2={x2.toFixed(2)} y2={y2.toFixed(2)} />
      ))}
      <circle cx="12" cy="12" r="2.1" fill="currentColor" stroke="none" />
    </Icon>
  );
};

// 06 — report / document with folded corner
const IconDoc = () => (
  <Icon>
    <path d="M7 3h7l4 4v14H7z" />
    <path d="M14 3v4h4" />
    <path d="M9.5 12h6" />
    <path d="M9.5 15h6" />
    <path d="M9.5 18h4" />
  </Icon>
);

// 07 — settlement monitoring: fluctuating polyline with measured points
const IconSettle = () => (
  <Icon>
    <path d="M3 12 L7.5 8.5 L11.5 14 L15.5 7.5 L21 12.5" />
    {[[3,12],[7.5,8.5],[11.5,14],[15.5,7.5],[21,12.5]].map(([x,y],i)=>(
      <circle key={i} cx={x} cy={y} r="1.2" fill="currentColor" stroke="none" />
    ))}
  </Icon>
);

// 08 — survey boat with GPS antenna + sonar
const IconBoat = () => (
  <Icon>
    <path d="M4 13h16l-2.2 4H6.2z" />
    <path d="M12 13V6" />
    <circle cx="12" cy="4.8" r="1.2" />
    <path d="M8.5 20c2 1.6 5 1.6 7 0" />
    <path d="M10.3 22.4c.9.7 2.5.7 3.4 0" />
  </Icon>
);

const SVC_ICONS = {
  road: IconRoad,
  net: IconNet,
  contour: IconContour,
  rail: IconRail,
  laser: IconLaser,
  doc: IconDoc,
  settle: IconSettle,
  boat: IconBoat,
};

Object.assign(window, { SVC_ICONS });
