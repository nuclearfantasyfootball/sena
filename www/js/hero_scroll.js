// ========================= NUCLEARFF HERO STYLESHEET ======================
// -------------------------- Author: Nolan MacDonald ------------------------

// Global variables
let sections, images, headings, outerWrappers, innerWrappers;
let currentIndex = -1;
let wrap, animating = false;

function initScrollSections() {
  // Check if GSAP is loaded
  if (typeof gsap === 'undefined') {
    console.error('GSAP not loaded');
    setTimeout(initScrollSections, 500);
    return;
  }

  // Register Observer plugin
  if (gsap.registerPlugin && typeof Observer !== 'undefined') {
    gsap.registerPlugin(Observer);
  }

  // Only initialize on home page
  const homeContainer = document.querySelector('.scroll-container');
  if (!homeContainer) return;

  // Prevent double initialization
  if (window.scrollSectionsInitialized) return;
  window.scrollSectionsInitialized = true;

  // Query elements
  sections = homeContainer.querySelectorAll("section");
  images = homeContainer.querySelectorAll(".bg");
  headings = gsap.utils.toArray(homeContainer.querySelectorAll(".section-heading"));
  outerWrappers = gsap.utils.toArray(homeContainer.querySelectorAll(".outer"));
  innerWrappers = gsap.utils.toArray(homeContainer.querySelectorAll(".inner"));

  if (!sections.length) {
    console.error('No sections found');
    return;
  }

  // Setup wrap function
  wrap = gsap.utils.wrap(0, sections.length);

  // Initial setup
  gsap.set(outerWrappers, { yPercent: 100 });
  gsap.set(innerWrappers, { yPercent: -100 });

  // Section navigation function
  window.gotoSection = function(index, direction) {
    if (animating) return;
    
    index = wrap(index);
    animating = true;
    
    let fromTop = direction === -1,
        dFactor = fromTop ? -1 : 1,
        tl = gsap.timeline({
          defaults: { duration: 1.25, ease: "power1.inOut" },
          onComplete: () => animating = false
        });

    // Hide current section
    if (currentIndex >= 0) {
      gsap.set(sections[currentIndex], { zIndex: 0 });
      tl.to(images[currentIndex], { yPercent: -15 * dFactor })
        .set(sections[currentIndex], { autoAlpha: 0 });
    }

    // Show new section
    gsap.set(sections[index], { autoAlpha: 1, zIndex: 1 });
    
    tl.fromTo([outerWrappers[index], innerWrappers[index]], { 
        yPercent: i => i ? -100 * dFactor : 100 * dFactor
      }, { 
        yPercent: 0 
      }, 0)
      .fromTo(images[index], { yPercent: 15 * dFactor }, { yPercent: 0 }, 0);

    // Animate text (simple fade in for now)
    if (headings[index]) {
      tl.fromTo(headings[index], {
        autoAlpha: 0,
        y: 50 * dFactor
      }, {
        autoAlpha: 1,
        y: 0,
        duration: 1,
        ease: "power2.out"
      }, 0.2);
    }

    currentIndex = index;
  };

  // Create Observer for scroll/swipe
  if (typeof Observer !== 'undefined') {
    Observer.create({
      type: "wheel,touch,pointer",
      wheelSpeed: -1,
      onDown: () => !animating && gotoSection(currentIndex - 1, -1),
      onUp: () => !animating && gotoSection(currentIndex + 1, 1),
      tolerance: 10,
      preventDefault: true
    });
  } else {
    // Fallback: use wheel events
    homeContainer.addEventListener('wheel', (e) => {
      if (animating) return;
      if (e.deltaY > 0) {
        gotoSection(currentIndex + 1, 1);
      } else {
        gotoSection(currentIndex - 1, -1);
      }
      e.preventDefault();
    });
  }

  // Start with first section
  gotoSection(0, 1);
  
  console.log('Scroll sections initialized');
  // Removed setupCTANavigation() call - no longer needed
}

// Initialize when ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initScrollSections);
} else {
  setTimeout(initScrollSections, 100);
}

// Reinitialize when switching tabs (Shiny integration)
if (window.Shiny) {
  Shiny.addCustomMessageHandler('tabChanged', function(message) {
    if (message === 'home') {
      window.scrollSectionsInitialized = false;
      setTimeout(() => {
        initScrollSections();
      }, 100);
    }
  });
}