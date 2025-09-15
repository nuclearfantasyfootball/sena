// ========================= NUCLEARFF HERO STYLESHEET ======================
// -------------------------- Author: Nolan MacDonald ------------------------

// Global variables
let sections, images, headings, outerWrappers, innerWrappers;
let currentIndex = -1;
let wrap, animating = false;
let scrollObserver = null;
let initializationPromise = null;

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

// Main initialization function that returns a promise
function initScrollSections() {
  // Return existing promise if initialization is in progress
  if (initializationPromise) {
    return initializationPromise;
  }

  initializationPromise = new Promise((resolve, reject) => {
    // Check if GSAP is loaded
    if (typeof gsap === 'undefined') {
      console.error('GSAP not loaded');
      setTimeout(() => {
        initScrollSections().then(resolve).catch(reject);
      }, 500);
      return;
    }

    // Register Observer plugin
    if (gsap.registerPlugin && typeof Observer !== 'undefined') {
      gsap.registerPlugin(Observer);
    }

    // Only initialize on home page
    const homeContainer = document.querySelector('.scroll-container');
    if (!homeContainer) {
      reject('No home container found');
      return;
    }

    // Query elements
    sections = homeContainer.querySelectorAll("section");
    images = homeContainer.querySelectorAll(".bg");
    headings = gsap.utils.toArray(homeContainer.querySelectorAll(".section-heading"));
    outerWrappers = gsap.utils.toArray(homeContainer.querySelectorAll(".outer"));
    innerWrappers = gsap.utils.toArray(homeContainer.querySelectorAll(".inner"));

    if (!sections.length) {
      reject('No sections found');
      return;
    }

    // Setup wrap function
    wrap = gsap.utils.wrap(0, sections.length);

    // Initial setup - position wrappers off-screen - don't hide sections
    // FYI set autoAlpha on sections
    gsap.set(outerWrappers, { yPercent: 100 });
    gsap.set(innerWrappers, { yPercent: -100 });

    // Section navigation function  
    window.gotoSection = function(index, direction, skipAnimation = false) {
      if (animating && !skipAnimation) return Promise.resolve();
      
      return new Promise((resolve) => {
        index = wrap(index);
        
        if (skipAnimation && currentIndex === -1) {
          // Special case: initial setup without animation
          // Make sure first section is properly visible
          gsap.set(sections[index], { autoAlpha: 1, zIndex: 1 });
          gsap.set(outerWrappers[index], { yPercent: 0 });
          gsap.set(innerWrappers[index], { yPercent: 0 });
          gsap.set(images[index], { yPercent: 0 });
          
          if (headings[index]) {
            gsap.set(headings[index], { autoAlpha: 1, y: 0 });
          }
          
          // Hide all other sections
          sections.forEach((section, i) => {
            if (i !== index) {
              gsap.set(section, { autoAlpha: 0, zIndex: 0 });
            }
          });
          
          currentIndex = index;
          window.currentIndex = currentIndex;
          resolve();
          return;
        }
        
        if (skipAnimation) {
          // Quick jump between sections (not initial)
          if (currentIndex >= 0 && currentIndex !== index) {
            gsap.set(sections[currentIndex], { autoAlpha: 0, zIndex: 0 });
          }
          
          gsap.set(sections[index], { autoAlpha: 1, zIndex: 1 });
          gsap.set(outerWrappers[index], { yPercent: 0 });
          gsap.set(innerWrappers[index], { yPercent: 0 });
          gsap.set(images[index], { yPercent: 0 });
          
          if (headings[index]) {
            gsap.set(headings[index], { autoAlpha: 1, y: 0 });
          }
          
          currentIndex = index;
          window.currentIndex = currentIndex;
          resolve();
          return;
        }
        
        // Animated transition
        animating = true;
        
        // If no direction specified, determine it
        if (direction === undefined) {
          direction = index > currentIndex ? 1 : -1;
          if (currentIndex === sections.length - 1 && index === 0) direction = 1;
          if (currentIndex === 0 && index === sections.length - 1) direction = -1;
        }
        
        let fromTop = direction === -1,
            dFactor = fromTop ? -1 : 1,
            tl = gsap.timeline({
              defaults: { duration: 1.25, ease: "power1.inOut" },
              onComplete: () => {
                animating = false;
                resolve();
              }
            });

        // Hide current section if it exists (not on first run)
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
        window.currentIndex = currentIndex;
      });
    };

    // Create Observer for scroll/swipe
    function createScrollObserver() {
      if (scrollObserver) {
        scrollObserver.kill();
        scrollObserver = null;
      }
      
      if (typeof Observer !== 'undefined') {
        scrollObserver = Observer.create({
          target: homeContainer,
          type: "wheel,touch,pointer",
          wheelSpeed: -1,
          onDown: () => !animating && gotoSection(currentIndex - 1, -1),
          onUp: () => !animating && gotoSection(currentIndex + 1, 1),
          tolerance: 10,
          preventDefault: true
        });
      }
    }

    // Initialize to first section - use skipAnimation for initial setup
    window.gotoSection(0, 1, true).then(() => {
      createScrollObserver();
      window.scrollSectionsInitialized = true;
      console.log('Scroll sections initialized - section 0 visible');
      
      // Check if background image is actually visible
      const firstBg = document.querySelector('.scroll-container .first .bg');
      if (firstBg) {
        const bgStyle = window.getComputedStyle(firstBg);
        console.log('First section BG visibility:', {
          display: bgStyle.display,
          visibility: bgStyle.visibility,
          opacity: bgStyle.opacity,
          backgroundImage: bgStyle.backgroundImage.substring(0, 100) + '...'
        });
      }
      
      resolve();
    });
  });

  return initializationPromise;
}

// Disable hero scroll
function disableHeroScroll() {
  if (scrollObserver) {
    scrollObserver.kill();
    scrollObserver = null;
  }
  window.scrollSectionsInitialized = false;
  initializationPromise = null;
  currentIndex = -1; // Reset index when disabling
}

// Enable function - re-enable hero scroll
function enableHeroScroll() {
  window.scrollSectionsInitialized = false;
  initializationPromise = null;
  currentIndex = -1; // Reset index when re-enabling
  return initScrollSections();
}

// Shiny integration - handle tab changes
if (window.Shiny) {
  Shiny.addCustomMessageHandler('tabChanged', function(message) {
    if (message === 'home') {
      // Small delay to ensure DOM is ready
      setTimeout(() => {
        enableHeroScroll().then(() => {
          console.log('Hero scroll enabled, resetting to first section');
          window.resetToFirstSection();
        });
      }, 50);
    } else {
      disableHeroScroll();
    }
  });
}

// Initialize on DOM ready if on home page
document.addEventListener('DOMContentLoaded', () => {
  setTimeout(() => {
    const activeTab = document.querySelector('.navbar .nav-link.active[data-value]');
    if (activeTab && activeTab.getAttribute('data-value') === 'home') {
      initScrollSections();
    }
  }, 100);
});