// ========================= NUCLEARFF HERO STYLESHEET ======================
// -------------------------- Author: Nolan MacDonald ------------------------

// Global variables
let sections, images, headings, outerWrappers, innerWrappers;
let currentIndex = -1;
let wrap, animating = false;
let scrollObserver = null; // Track observer instance

window.resetToFirstSection = function() {
  if (typeof window.gotoSection === 'function') {
    window.gotoSection(0, 1);
  } else {
    // If scroll sections aren't initialized, do it now
    setTimeout(() => {
      if (typeof initScrollSections === 'function') {
        initScrollSections();
        setTimeout(() => {
          if (typeof window.gotoSection === 'function') {
            window.gotoSection(0, 1);
          }
        }, 150);
      }
    }, 100);
  }
};

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
    
    // If no direction specified, determine it based on current vs target index
    if (direction === undefined) {
        direction = index > currentIndex ? 1 : -1;
        // Handle wrap-around case
        if (currentIndex === sections.length - 1 && index === 0) direction = 1;
        if (currentIndex === 0 && index === sections.length - 1) direction = -1;
    }
    
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

    // Animate text
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
    
    // Store current index globally for access
    window.currentIndex = currentIndex;
  };

  // Reset to first section on home
  window.resetToFirstSection = function() {
    if (typeof gotoSection === 'function') {
      gotoSection(0, 1); // Go to first section (index 0) with forward direction
    }
  };

  // Reinitialize when switching tabs (Shiny integration)
  if (window.Shiny) {
    Shiny.addCustomMessageHandler('tabChanged', function(message) {
      if (message === 'home') {
        enableHeroScroll();
        // Ensure we start at first section when coming to home
        setTimeout(() => {
          if (typeof window.resetToFirstSection === 'function') {
            window.resetToFirstSection();
          }
        }, 200);
      } else {
        disableHeroScroll();
      }
    });
  }

  // Create Observer for scroll/swipe - ONLY when home tab is active
  function createScrollObserver() {
    if (scrollObserver) {
      scrollObserver.kill();
      scrollObserver = null;
    }
    
    if (typeof Observer !== 'undefined') {
      scrollObserver = Observer.create({
        target: homeContainer, // Target ONLY the home container
        type: "wheel,touch,pointer",
        wheelSpeed: -1,
        onDown: () => !animating && gotoSection(currentIndex - 1, -1),
        onUp: () => !animating && gotoSection(currentIndex + 1, 1),
        tolerance: 10,
        preventDefault: true
      });
    }
  }

  // Start with first section
  gotoSection(0, 1);
  createScrollObserver();
  
  console.log('Scroll sections initialized');
}

// Clean up function to disable hero scroll
function disableHeroScroll() {
  if (scrollObserver) {
    scrollObserver.kill();
    scrollObserver = null;
  }
  window.scrollSectionsInitialized = false;
}

// Enable function to re-enable hero scroll
function enableHeroScroll() {
  window.scrollSectionsInitialized = false;
  setTimeout(initScrollSections, 100);
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
      enableHeroScroll();
    } else {
      disableHeroScroll();
    }
  });
}