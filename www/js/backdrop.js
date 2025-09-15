// www/js/backdrop.js  (replace contents with this scoped version)
(function () {
  function biasFor(el, isLight) {
    const r = el.getBoundingClientRect();
    // your original bias, scaled per-element
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

    // passive move handler on the document so it works even if mouse is over text
    const onMove = (e) => {
      targets.forEach(el => updateVars(el, e.clientX, e.clientY));
    };
    document.addEventListener('pointermove', onMove, { passive: true });

    // re-bias when the viewport changes a lot (e.g., orientation/resize)
    const onResize = () => targets.forEach(el => biasFor(el, isLight));
    window.addEventListener('resize', onResize);
  }

  if (document.readyState !== 'loading') init();
  else document.addEventListener('DOMContentLoaded', init);

  // Optional: listen for theme re-application to re-bias
  window.addEventListener('nff:theme-applied', () => {
    // re-init to re-bias on theme change
    init();
  });
})();
