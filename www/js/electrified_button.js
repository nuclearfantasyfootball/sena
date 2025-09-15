// =================== ELECTRIFIED BUTTON ANIMATIONS ===================
// GSAP-powered electrical effects for buttons

/**
 * Initialize an electrified button with GSAP animations
 * @param {string} buttonId - The ID of the button to electrify
 * @param {boolean} autoPlay - Whether to auto-play animation on load
 */
function initElectrifiedButton(buttonId, autoPlay = false) {
  // Check if GSAP is loaded
  if (typeof gsap === 'undefined') {
    console.error('GSAP not loaded - electrified button requires GSAP');
    setTimeout(() => initElectrifiedButton(buttonId, autoPlay), 500);
    return;
  }

  // Register DrawSVG plugin if available
  if (gsap.registerPlugin && typeof DrawSVGPlugin !== 'undefined') {
    gsap.registerPlugin(DrawSVGPlugin);
  }

  // Get button elements
  const button = document.getElementById(buttonId);
  const container = document.getElementById(`${buttonId}_container`);
  const scribbles = document.getElementById(`${buttonId}_scribbles`);
  const lightning = document.getElementById(`${buttonId}_lightning`);
  
  if (!button || !container || !scribbles || !lightning) {
    console.warn(`Electrified button elements not found for ID: ${buttonId}`);
    return;
  }

  // Create rough ease for electrical effect
  const rough = gsap.parseEase("rough({strength: 3, points: 30, taper: 'none', randomize: true})");

  // Create timeline for lightning animation
  const tl = gsap.timeline({
    defaults: { duration: 2, ease: "sine.out" },
    paused: true
  });

  // Get all strike elements
  const strikes = gsap.utils.toArray(container.querySelectorAll('.electrified-strike'));
  const borderGradient = container.querySelector('.electrified-border-gradient');
  
  // Get filter elements for this specific button
  const filter1 = document.querySelector(`#${buttonId}_filter1 feDisplacementMap`);
  const filter2 = document.querySelector(`#${buttonId}_filter2 feDisplacementMap`);
  const filter4 = document.querySelector(`#${buttonId}_filter4 feDisplacementMap`);

  // Build animation timeline
  tl.to(lightning, { opacity: 1, duration: 0.1 })
    .to(borderGradient, { opacity: 1 }, 0);

  // Add displacement animations if filters exist
  if (filter1) tl.to(filter1, { attr: { scale: "10" }, ease: rough }, 0);
  if (filter2) tl.to(filter2, { attr: { scale: "30" }, ease: rough }, 0);
  if (filter4) tl.to(filter4, { attr: { scale: "40" }, ease: rough }, 0);

  // Animate strikes with DrawSVG if available, otherwise use opacity
  if (typeof DrawSVGPlugin !== 'undefined') {
    // DrawSVG animations for smooth line drawing
    if (strikes[0]) tl.fromTo(strikes[0], { drawSVG: "100% 90%" }, { drawSVG: "0% 10%" }, 0);
    if (strikes[1]) tl.fromTo(strikes[1], { drawSVG: "0% 20%" }, { drawSVG: "100% 100%" }, 0);
    if (strikes[2]) tl.fromTo(strikes[2], { drawSVG: "0% 10%" }, { drawSVG: "135% 140%" }, 0);
    if (strikes[3]) tl.fromTo(strikes[3], { drawSVG: "120% 140%" }, { drawSVG: "35% 40%" }, 0);
    if (strikes[4]) tl.fromTo(strikes[4], { drawSVG: "20% 40%" }, { drawSVG: "135% 140%" }, 0);
  } else {
    // Fallback animations using stroke-dasharray
    strikes.forEach((strike, i) => {
      const length = strike.getTotalLength ? strike.getTotalLength() : 300;
      gsap.set(strike, { 
        strokeDasharray: length,
        strokeDashoffset: length 
      });
      
      tl.to(strike, {
        strokeDashoffset: 0,
        duration: 1.5,
        ease: "power2.inOut",
        stagger: 0.1
      }, 0);
    });
  }

  // Fade out lightning
  tl.to(lightning, { opacity: 0, duration: 0.3 }, "-=0.4");

  // Mouse enter handler
  const handleMouseEnter = () => {
    gsap.to(scribbles, { opacity: 1, duration: 0.3, ease: "sine.out" });
    tl.play(0);
  };

  // Mouse leave handler
  const handleMouseLeave = () => {
    gsap.to(scribbles, { opacity: 0, duration: 0.6, ease: "sine.out" });
    tl.reverse();
  };

  // Touch support for mobile
  const handleTouchStart = (e) => {
    e.preventDefault();
    handleMouseEnter();
    
    // Auto-reverse after delay on mobile
    setTimeout(() => {
      handleMouseLeave();
    }, 2000);
  };

  // Add event listeners
  button.addEventListener("mouseenter", handleMouseEnter);
  button.addEventListener("mouseleave", handleMouseLeave);
  button.addEventListener("touchstart", handleTouchStart, { passive: false });
  
  // Focus events for accessibility
  button.addEventListener("focus", handleMouseEnter);
  button.addEventListener("blur", handleMouseLeave);

  // AUTO-PLAY ON LOAD if specified
  if (autoPlay) {
    // Wait a moment for page to settle, then play animation
    setTimeout(() => {
      gsap.to(scribbles, { opacity: 1, duration: 0.3, ease: "sine.out" });
      tl.play(0);
      
      // Auto-reverse after animation completes
      setTimeout(() => {
        gsap.to(scribbles, { opacity: 0, duration: 0.6, ease: "sine.out" });
        tl.reverse();
      }, 2500); // Adjust timing as needed (2.5 seconds total)
    }, 800); // Small delay after page load for dramatic effect
  }

  console.log(`Electrified button initialized: ${buttonId}${autoPlay ? ' (with auto-play)' : ''}`);
}

// Shiny integration with auto-play support
if (window.Shiny) {
  Shiny.addCustomMessageHandler('initElectrifiedButton', function(data) {
    // Extract parameters
    const buttonId = data.id || data;
    const autoPlay = data.autoPlay || false;
    
    // Wait for DOM ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => initElectrifiedButton(buttonId, autoPlay));
    } else {
      // Small delay to ensure elements are rendered
      setTimeout(() => initElectrifiedButton(buttonId, autoPlay), 100);
    }
  });
}

// Alternative: Auto-play for buttons with specific class (no R changes needed)
document.addEventListener('DOMContentLoaded', function() {
  // Delay to ensure GSAP and button initialization
  setTimeout(() => {
    // Find all buttons that should auto-play
    const autoPlayButtons = document.querySelectorAll('.electrified-btn-autoplay');
    
    autoPlayButtons.forEach(button => {
      const buttonId = button.id;
      if (buttonId) {
        const scribbles = document.getElementById(`${buttonId}_scribbles`);
        
        if (scribbles) {
          // Trigger animation by simulating mouse enter
          const event = new MouseEvent('mouseenter');
          button.dispatchEvent(event);
          
          // Auto-reverse after animation
          setTimeout(() => {
            const leaveEvent = new MouseEvent('mouseleave');
            button.dispatchEvent(leaveEvent);
          }, 2500);
        }
      }
    });
  }, 1500); // Wait for everything to initialize
});

// Export for manual initialization
window.initElectrifiedButton = initElectrifiedButton;