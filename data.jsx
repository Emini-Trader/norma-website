// Shared data and constants

// 8 services — name + slogan (user-supplied) + description (written to fit)
const SERVICES = [
  {
    n: "01", slug: "bygg-anlegg", icon: "road",
    name: "Bygg og anlegg",
    slogan: ["Riktig plass", "i hvert stikk"],
    desc: "Utstikking og innmåling for bygg og anlegg, slik at hvert punkt havner presist der det skal.",
  },
  {
    n: "02", slug: "grunnlagsnett", icon: "net",
    name: "Grunnlagsnett",
    slogan: ["Nøyaktig fra", "første til siste punkt"],
    desc: "Etablering og kontroll av grunnlagsnett, knyttet opp mot det offisielle landsnettet.",
  },
  {
    n: "03", slug: "terrengmodell", icon: "contour",
    name: "Terrengmodell",
    slogan: ["Vi former", "terrenget digitalt"],
    desc: "Digital terrengmodeller for prosjektering, masseberegning og internkontroll.",
  },
  {
    n: "04", slug: "setningsmaling", icon: "settle",
    name: "Setningsmåling",
    slogan: ["Vi ser det", "før det skjer"],
    desc: "Periodisk monitorering av setninger som varsler bevegelse før den blir et problem.",
  },
  {
    n: "05", slug: "laserskanning", icon: "laser",
    name: "Laserskanning",
    slogan: ["Se alt", "fanget i 3D"],
    desc: "Laserskanning og fotogrammetri som fanger hele anlegget som en målbar 3D-modell.",
  },
  {
    n: "06", slug: "malebrev", icon: "doc",
    name: "Målebrev",
    slogan: ["Du tjener mens", "vi beregner"],
    desc: "Komplette sluttdokumentasjon, ferdig bearbeidet og klart for innsending og rapportering.",
  },
  {
    n: "07", slug: "spormaling", icon: "rail",
    name: "Spormåling",
    slogan: ["Med presisjon", "på rett spor"],
    desc: "Innmåling og kontroll av jernbanespor med beliggenhet helt ned til millimeternivå.",
  },
  {
    n: "08", slug: "batymetri", icon: "boat",
    name: "Batymetri",
    slogan: ["Vi kartlegger", "det usynlige"],
    desc: "Oppmåling av sjøbunn, havn og vassdrag med ekkolodd og presis GNSS-posisjonering.",
  },
];

// Company history — condensed, for the Tjenester page intro (HISTORIE)
const HISTORY = [
  "Vår historie strekker seg tilbake til midten av 1990-tallet, da muligheten åpnet seg for å kommersialisere geodetisk og kartografisk virksomhet. Nye statlige regler krevde utdanning i tillegg til seks års yrkespraksis, dokumenterte kurs og bestått statseksamen — et sertifikat som ble tatt i 1992, og som dannet grunnlaget for det første selskapet.",
  "De påfølgende årene brakte stadig større og mer krevende oppdrag, fra renseanlegget i Gubin under internasjonalt tilsyn til prosjekter som krystalliserte en tydelig og pålitelig profil i markedet. I 2001 førte veien til Norge, gjennom arbeid på Su4 / Norsk Hydro-anlegget i Sunndalsøra.",
  "Etter mange år hos blant andre AF Spesialprosjekt, Reinertsen, Veidekke og Terratec — og prosjekter som Snøhvit, Fornebu, Norges Varemesse og Lysaker stasjon — ble Norma Geosystems etablert. Vår forståelse av geodesi går tilbake til klassiske målemetoder, manuelle trigonometriske beregninger og håndtegnede kart. Uansett dagens teknologi tar vi derfor på oss krevende måleoppgaver med moderne utstyr for innmåling og databehandling.",
];

// Per-service detail content for the Tjenester page (intro expanded + scope bullets)
const SERVICE_DETAILS = {
  "bygg-anlegg": {
    intro: "Vi gjennomfører landmåling på prosjekter innenfor bygg- og anleggsvirksomhet. Bred erfaring fra ulike typer prosjekter gir oss mulighet til å komme med trygge og gjennomtenkte løsninger — fra første fastmerke til ferdig avviksrapport.",
    bullets: [
      "Etablering, innmåling og utjevning av fastmerker",
      "Klargjøring av stikningsdata (landmåling)",
      "Klargjøring av stikningsdata (maskinstyring)",
      "Produksjonsstikking",
      "Geometrisk kontroll og avviksrapportering",
    ],
  },
  "grunnlagsnett": {
    intro: "Fastmerker og grunnlagsnett er grunnsteinen i all aktivitet knyttet til innmåling. Vår lange erfaring gir bistand allerede i planleggingsfasen, med rådgivning om hvordan et homogent grunnlagsnett skal bygges opp. Vi legger stor vekt på kvalitet i etablering, innmåling, beregning og dokumentasjon.",
    bullets: [
      "Rådgivning under planleggingsfasen",
      "Etablering av fastmerker",
      "Innmåling og beregning av grunnlagsnett",
      "Kontroll av eksisterende grunnlagsnett",
    ],
  },
  "terrengmodell": {
    intro: "Vi gjennomfører innmåling av eksisterende terreng og situasjon for prosjektering og kontrollformål. En god og detaljert terrengmodell er et viktig fundament i prosjekteringsfasen, og gjør planleggingen både presis og effektiv.",
    bullets: [
      "Innmåling av eksisterende situasjon",
      "Innmåling og levering av terrengmodell",
      "Etablering av hjelpepunkter",
      "Digitalisering av basiskilder",
      "Innmåling, profilering og 3D-modellering",
      "DTM-kartlegging",
    ],
  },
  "spormaling": {
    intro: "Vi utfører presis innmåling og kontroll av jernbanespor, der geometri og beliggenhet dokumenteres helt ned til millimeternivå. Med egenutviklet måleutstyr tilpasset sporets geometri leverer vi pålitelige data for nybygg, vedlikehold og kontroll av eksisterende infrastruktur.",
    bullets: [
      "Etablering, innmåling og utjevning av fastmerker",
      "Konstruksjon og utvikling av måleutstyr",
      "Innmåling av spor",
      "Prosessering og rapportering",
    ],
  },
  "laserskanning": {
    intro: "Med laserskanning fanger vi hele anlegget som en målbar, tredimensjonal punktsky. Teknologien gir et komplett og nøyaktig bilde av eksisterende forhold, og danner grunnlag for prosjektering, kontroll og dokumentasjon — uten gjentatte turer tilbake i felt.",
    bullets: [
      "Etablering, innmåling og utjevning av fastmerker",
      "Kalibrering av skanningssystemer",
      "Skanning og 3D-modellering",
      "Prosessering, visualisering og rapportering",
    ],
  },
  "malebrev": {
    intro: "Vi utarbeider komplette målebrev og sluttdokumentasjon, ferdig bearbeidet og klart til innsending. Fra rådata til offisiell leveranse sørger vi for at modeller, beregninger og rapporter oppfyller kravene fra offentlige registre som FKB og NVDB.",
    bullets: [
      "3D-modellering og DTM-kartlegging",
      "Beregning, visualisering og rapportering",
      "Leveranse til FKB og NVDB",
    ],
  },
  "setningsmaling": {
    intro: "Gjennom periodisk setnings- og deformasjonsovervåking ser vi bevegelse før den utvikler seg til et problem. Vi etablerer et stabilt målegrunnlag, kalibrerer overvåkingssystemene og dokumenterer utviklingen over tid, slik at tiltak kan settes inn i tide.",
    bullets: [
      "Innledende analyse",
      "Etablering, innmåling og utjevning av fastmerker",
      "Kalibrering av monitoreringssystemer",
      "Innmåling, prosessering og rapportering",
    ],
  },
  "batymetri": {
    intro: "Sjøbunnskartlegging er også en viktig del av Norma. Vår erfaring gjør det mulig å tilby innmåling med ekkolodd av elver, innsjøer og sjøbunn. Vi leverer frittstående modeller, eller i kombinasjon med andre data fra landmåling og laserskanning.",
    bullets: [
      "Innmåling med ekkolodd og GPS av elver, innsjøer, mariner og sjøbunn",
      "Bearbeiding av terrengmodeller",
      "Tverrsnittsrapportering",
      "Visualisering av mudring, dumping og utfylling",
    ],
  },
};

// Reference clients — logos recolored to brand palette, with homepage links.
const CLIENTS = [
  { name: "AF Gruppen", slug: "af-gruppen", url: "https://afgruppen.no" },
  { name: "Veidekke", slug: "veidekke", url: "https://veidekke.no" },
  { name: "Skanska", slug: "skanska", url: "https://www.skanska.no" },
  { name: "NCC", slug: "ncc", url: "https://www.ncc.no" },
  { name: "Peab", slug: "peab", url: "https://peab.no" },
  { name: "Implenia Norge", slug: "implenia", url: "https://implenia.com" },
  { name: "Mesta", slug: "mesta", url: "https://mesta.no" },
  { name: "OHLA Norge", slug: "ohla", url: "https://ohla-group.com" },
  { name: "Isachsen Anlegg", slug: "isachsen", url: "https://isachsen.no" },
  { name: "LNS", slug: "lns", url: "https://www.lns.no" },
  { name: "HAB Construction", slug: "hab", url: "https://www.hab.no" },
  { name: "Marthinsen & Duvholt", slug: "marthinsen-duvholt", url: "https://www.md.no" },
  { name: "Anlegg Øst Entreprenør", slug: "anlegg-ost", url: "https://anleggost.no" },
  { name: "Vassbakk & Støl", slug: "vassbakk-stol", url: "https://www.vsas.no" },
];

// Reference cities baked into the supplied contour — normalized to the map image
// (viewBox 0..100 wide, 0..124.03 tall). UTM32 / EUREF89.
const CITIES = [
  { name: "Tromsø",     pos: { x: 59.4, y: 18.1 }, side: "left"  },
  { name: "Trondheim",  pos: { x: 28.1, y: 74.8 }, side: "right" },
  { name: "Bergen",     pos: { x: 3.6,  y: 100.2 }, side: "right" },
  { name: "Oslo",       pos: { x: 28.0, y: 106.7 }, side: "right" },
];

// Illustrative project references — UTM32 (EUREF89) eastings/northings
const PROJECTS = [
  {
    id: "p01", title: "Sentrumskvartalet K3", region: "Bergen", year: "2025", cat: "Bygg",
    desc: "Utstikking og as-built for kontorbygg på 14 200 m². Daglig kontrollmåling av søyleposisjoner mot BIM-modell.",
    E: "297 640", N: "6 700 510", pos: { x: 9, y: 99 },
  },
  {
    id: "p02", title: "Fv. 60 Stordal–Volda", region: "Møre og Romsdal", year: "2025", cat: "Vei",
    desc: "Stikning av veitrasé over 6,2 km med tre tunnelpåhugg. Levert KOF-filer til entreprenørens maskinstyring.",
    E: "366 210", N: "6 900 080", pos: { x: 16, y: 83 },
  },
  {
    id: "p03", title: "Hamn Industripark", region: "Tromsø", year: "2024", cat: "Industri",
    desc: "Volumberegning av massedeponi og kvartalsvis dronefotogrammetri. Terrengmodell levert i LandXML.",
    E: "716 040", N: "7 725 300", pos: { x: 57, y: 21 },
  },
  {
    id: "p04", title: "Stasjonsbyen", region: "Lillestrøm", year: "2024", cat: "Bygg",
    desc: "Eiendomsmåling og situasjonsplan for boligfelt med 280 enheter. Innmåling av infrastruktur før overlevering.",
    E: "615 420", N: "6 646 110", pos: { x: 32, y: 105 },
  },
  {
    id: "p05", title: "Fv. 714 Hitra–Frøya", region: "Trøndelag", year: "2024", cat: "Vei",
    desc: "Laserskanning av eksisterende vegfundament før reasfaltering. Punktsky integrert mot fagmodell.",
    E: "491 820", N: "7 058 040", pos: { x: 33, y: 73 },
  },
];

// Equipment — verified accuracies from manufacturer datasheets
const EQUIPMENT = [
  { brand: "Trimble", model: "S7", qty: "", type: "Totalstasjon", spec: "Vinkel 1″ · 1 mm + 2 ppm" },
  { brand: "Trimble", model: "SX12", qty: "", type: "Skannende totalstasjon", spec: "1″ · 3D-punkt 2,5 mm @ 100 m" },
  { brand: "Trimble", model: "R12i", qty: "", type: "GNSS-mottaker (RTK)", spec: "RTK 8 mm + 1 ppm · IMU-tilt" },
  { brand: "Leica", model: "M60", qty: "", type: "Skannende totalstasjon", spec: "spes. bekreftes" },
];

const CERTS = [
  "Sentral godkjenning — tiltaksklasse 2",
  "StartBank — godkjent leverandør",
  "Arbeider etter SVV-standard (Statens vegvesen)",
  "Arbeider etter Bane NOR sine krav",
];

const TESTIMONIALS = [
  {
    body: "Norma leverer punktlig og forklarer hva som faktisk er målt. Vi har spart minst to uker per byggetrinn fordi as-built kommer i riktig format første gangen.",
    name: "Marit Solheim", role: "Prosjektleder · entreprenør",
  },
  {
    body: "Punktskyene deres integreres rett inn i Tekla. Ingen omveier, ingen klipping og liming — bare bruk.",
    name: "Henrik Røste", role: "BIM-koordinator · utbygger",
  },
  {
    body: "På tunnelpåhugget hadde vi 0,4 mm avvik over 30 meter. Det er sånn jobb vi vil ha.",
    name: "Tor Inge Vatne", role: "Anleggsleder · vegprosjekt",
  },
];

const PROCESS = [
  { n: "01", title: "Befaring", desc: "Vi gjennomfører befaring på stedet, gjennomgår eksisterende grunnlag og definerer hvilke leveranser prosjektet krever.", out: { lbl: "Resultat", val: "Tilbud + plan" } },
  { n: "02", title: "Måling i felt", desc: "Terreng profilering, utstikking og kontrollmåling utføres med utstyr som oppfyller de høyeste standarder for nøyaktighet.", out: { lbl: "Toleranse", val: "±5 mm" } },
  { n: "03", title: "Bearbeiding", desc: "Rådata kvalitetssikres og knyttes til prosjektmodellen. All beregning gjennomgår grundig, uavhengig internkontroll.", out: { lbl: "Kontroll", val: "Grundig og uavhengig" } },
  { n: "04", title: "Leveranse", desc: "Du mottar filene i avtalt format, komplett med måleprotokoll, kontrollpunktslogg og en kortfattet teknisk rapport.", out: { lbl: "Format", val: "DWG · IFC · KOF · SOSI" } },
];

Object.assign(window, { SERVICES, HISTORY, SERVICE_DETAILS, CLIENTS, CITIES, PROJECTS, EQUIPMENT, CERTS, TESTIMONIALS, PROCESS });
