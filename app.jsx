// Main app

function useHashJump() {
  useEffect(() => {
    // React renders after load, so a #hash in the URL (e.g. arriving from
    // tjenester.html via "Be om tilbud") has no target yet. Resolve it here.
    const NAV_OFFSET = 84;
    const jumpTo = (hash) => {
      if (!hash || hash === "#" || hash === "#top") return;
      const el = document.getElementById(hash.replace(/^#/, ""));
      if (!el) return;
      const y = el.getBoundingClientRect().top + window.pageYOffset - NAV_OFFSET;
      window.scrollTo({ top: y, behavior: "auto" });
    };
    const raf = requestAnimationFrame(() => jumpTo(window.location.hash));
    const onLoad = () => jumpTo(window.location.hash);
    if (document.readyState === "complete") setTimeout(onLoad, 60);
    else window.addEventListener("load", onLoad);
    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("load", onLoad);
    };
  }, []);
}

function App() {
  useFadeIn();
  useHashJump();
  return (
    <div>
      <Nav />
      <Hero />
      <LogoBar />
      <Services />
      <Projects />
      <Process />
      <Equipment />
      <Contact />
      <Footer />
      <CookieBanner />
    </div>
  );
}

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(<App />);
