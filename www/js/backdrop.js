// www/js/backdrop.js
(function () {
  function biasFor(el, isLight) {
    const r = el.getBoundingClientRect();
    const bx = isLight ? -0.12 * r.width :  0.10 * r.width;
    const by = isLight ?  0.10 * r.height : -0.08 * r.height;
    el.style.setProperty('--posX', Math.round(bx));
    el.style.setProperty('--posY', Math.round(by));
  }

  function updateVars(el, clientX, clientY) {
    const r = el.getBoundingClientRect();
    const x = Math.round(clientX - (r.left + r.width  / 2));
    const y = Math.round(clientY - (r.top  + r.height / 2));
    el.style.setProperty('--posX', x);
    el.style.setProperty('--posY', y);
  }

  function init() {
    const targets = Array.from(document.querySelectorAll('.nff-backdrop'));
    if (!targets.length) return;
    const isLight = (document.documentElement.getAttribute('data-bs-theme') === 'light');
    targets.forEach(el => biasFor(el, isLight));

    const onMove = (e) => {
      targets.forEach(el => updateVars(el, e.clientX, e.clientY));
    };
    document.addEventListener('pointermove', onMove, { passive: true });

    const onResize = () => targets.forEach(el => biasFor(el, isLight));
    window.addEventListener('resize', onResize);
  }

  // Make init globally accessible
  window.initBackdrop = init;

  if (document.readyState !== 'loading') init();
  else document.addEventListener('DOMContentLoaded', init);

  window.addEventListener('nff:theme-applied', () => {
    init();
  });
})();

// Re-initialize when dynamic content loads
if (window.Shiny) {
  $(document).on('shiny:value shiny:visualchange', function(event) {
    if (event.target.id === 'leagues-league_tabs' || 
        event.target.id.includes('data_table')) {
      if (window.initBackdrop) window.initBackdrop();
    }
  });
}