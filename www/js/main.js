// =================== NUCLEARFF MAIN JAVASCRIPT ===================
// Consolidated JavaScript from app.R and existing main.js

document.addEventListener("DOMContentLoaded", () => {
    initTheme();
    initCountdown("2025-08-15T09:00:00-04:00");
    initNavbarBehavior();
    initShinyHandlers();
    initNavbarAutoCollapse();
    console.log("NuclearFF Frontend Launched");
});

// =================== Navbar Auto-Collapse ===================
/**
 * Auto-collapse navbar on mobile when nav items are clicked
 */
function initNavbarAutoCollapse() {
    // Enhanced element detection with multiple attempts
    const setupAutoCollapse = () => {
        console.log('Setting up navbar auto-collapse...');
        
        // Try multiple selector strategies
        let navLinks = document.querySelectorAll('.navbar-nav .nav-link, .nav-link[data-bs-toggle="tab"], [data-value][data-bs-toggle="tab"]');
        let navbarToggler = document.querySelector('.navbar-toggler, [data-bs-toggle="collapse"]');
        let navbarCollapse = document.querySelector('.navbar-collapse, .collapse');
        
        // Alternative selectors if first attempt fails
        if (!navLinks.length) {
            navLinks = document.querySelectorAll('a[data-value]'); // Shiny nav items
        }
        
        console.log('Found elements:', {
            navLinks: navLinks.length,
            togglerExists: !!navbarToggler,
            collapseExists: !!navbarCollapse,
            allNavElements: document.querySelectorAll('[data-value]').length
        });
        
        if (!navLinks.length || !navbarToggler || !navbarCollapse) {
            console.log('Not all required elements found, retrying...');
            setTimeout(setupAutoCollapse, 1000);
            return;
        }
        
        // Use Bootstrap's Collapse API if available
        let bsCollapse = null;
        if (window.bootstrap && window.bootstrap.Collapse) {
            try {
                bsCollapse = new window.bootstrap.Collapse(navbarCollapse, { toggle: false });
                console.log('Bootstrap Collapse API initialized');
            } catch (e) {
                console.log('Bootstrap Collapse API not available:', e);
            }
        }
        
        // Function to handle navbar collapse
        const handleNavbarCollapse = (elementName) => {
            // Check if we're in mobile mode
            const isMobile = window.getComputedStyle(navbarToggler).display !== 'none';
            const isExpanded = navbarCollapse.classList.contains('show') || 
                            navbarCollapse.classList.contains('showing');
            
            console.log(`${elementName} clicked - Mobile check:`, {
                isMobile: isMobile,
                isExpanded: isExpanded,
                togglerDisplay: window.getComputedStyle(navbarToggler).display,
                collapseClasses: navbarCollapse.className,
                windowWidth: window.innerWidth
            });
            
            if (isMobile && isExpanded) {
                console.log(`Attempting to collapse navbar after ${elementName} click...`);
                
                // Try Bootstrap API first
                if (bsCollapse) {
                    try {
                        bsCollapse.hide();
                        console.log('Collapsed using Bootstrap API');
                        return;
                    } catch (e) {
                        console.log('Bootstrap API failed:', e);
                    }
                }
                
                // Fallback: trigger click on toggler
                setTimeout(() => {
                    console.log('Fallback: clicking toggler');
                    navbarToggler.click();
                }, 150);
                
                // Alternative fallback: manually remove classes
                setTimeout(() => {
                    if (navbarCollapse.classList.contains('show')) {
                        console.log('Manual collapse fallback');
                        navbarCollapse.classList.remove('show');
                        navbarCollapse.classList.add('collapse');
                    }
                }, 300);
            }
        };

        // Add event listeners to nav links
        navLinks.forEach((link, index) => {
            link.addEventListener('click', function(event) {
                console.log(`Nav link ${index} clicked:`, link.textContent || link.getAttribute('data-value'));
                handleNavbarCollapse('nav link');
            });
        });

        // Add event listener to theme toggle button
        const setupThemeToggleCollapse = () => {
            const themeToggle = document.querySelector('#toggle_theme, .nav-icon-btn');
            if (themeToggle) {
                themeToggle.addEventListener('click', function(event) {
                    console.log('Theme toggle clicked');
                    handleNavbarCollapse('theme toggle');
                });
                console.log('Theme toggle auto-collapse enabled');
            } else {
                // Theme toggle might not be rendered yet, try again
                setTimeout(setupThemeToggleCollapse, 500);
            }
        };
        
        setupThemeToggleCollapse();
        
        console.log('Auto-collapse navbar initialized successfully with', navLinks.length, 'nav links');
    };
    
    // Multiple initialization attempts
    setupAutoCollapse();
    
    // Try again after DOM is fully loaded
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', setupAutoCollapse);
    }
    
    // Try again after Shiny is ready
    if (window.Shiny) {
        Shiny.addCustomMessageHandler('setupNavbarCollapse', setupAutoCollapse);
        
        // Also try when Shiny is fully initialized
        $(document).on('shiny:connected', setupAutoCollapse);
    }
    
    // Final attempt after everything should be loaded
    setTimeout(setupAutoCollapse, 2000);
}

// =================== Theme Management ===================
/**
 * Initialize theme from localStorage and apply to DOM
 */
function initTheme() {
    // Apply theme class based on localStorage or default to dark
    function applyThemeClass(val) {
        const root = document.documentElement;
        root.classList.remove('nff-light', 'nff-dark');
        root.classList.add(val === 'light' ? 'nff-light' : 'nff-dark');
    }
    
    try {
        const pref = localStorage.getItem('nff-theme') || 'dark';
        applyThemeClass(pref);
        
        // Send initial theme to Shiny if available
        if (window.Shiny && Shiny.setInputValue) {
            Shiny.setInputValue('initTheme', pref, {priority: 'event'});
        }
    } catch (e) {
        console.warn('localStorage not available:', e);
        applyThemeClass('dark');
    }
}

// =================== Countdown Timer ===================
/**
 * Initializes a countdown timer and updates the UI
 * @param {string} targetDate - ISO date string
 */
function initCountdown(targetDate) {
    const countdownContainer = document.querySelector(".countdown-text");
    if (!countdownContainer) return;

    const target = new Date(targetDate).getTime();

    const updateCountdown = () => {
        const now = new Date().getTime();
        const distance = target - now;

        if (distance < 0) {
            countdownContainer.innerHTML = "LAUNCHED!";
            clearInterval(interval);
            return;
        }

        const days = Math.floor(distance / (1000 * 60 * 60 * 24));
        const hours = Math.floor((distance / (1000 * 60 * 60)) % 24);
        const minutes = Math.floor((distance / (1000 * 60)) % 60);
        const seconds = Math.floor((distance / 1000) % 60);

        countdownContainer.innerHTML = `${days}D ${pad(hours)}H ${pad(minutes)}M ${pad(seconds)}S`;
    };

    const pad = (num) => String(num).padStart(2, '0');
    updateCountdown();
    const interval = setInterval(updateCountdown, 1000);
}

// =================== Navbar Behavior ===================
/**
 * Enhances navbar with scroll effects
 */
function initNavbarBehavior() {
    const navbar = document.querySelector(".navbar-custom, .navbar");
    if (!navbar) return;

    window.addEventListener("scroll", () => {
        if (window.scrollY > 10) {
            navbar.style.backgroundColor = "rgba(0, 0, 0, 0.95)";
            navbar.style.boxShadow = "0 2px 5px rgba(0, 0, 0, 0.2)";
        } else {
            navbar.style.backgroundColor = "rgba(0, 0, 0, 0.8)";
            navbar.style.boxShadow = "none";
        }
    });
}

// =================== Shiny Integration ===================
/**
 * Initialize all Shiny custom message handlers
 */
function initShinyHandlers() {
    if (!window.Shiny) return;

    // Theme storage handler
    Shiny.addCustomMessageHandler('storeTheme', function(val) {
        try {
            localStorage.setItem('nff-theme', val);
        } catch (e) {
            console.warn('Could not store theme preference:', e);
        }
    });

    // Theme application handler
    Shiny.addCustomMessageHandler('applyThemeClass', function(val) {
        const root = document.documentElement;
        root.classList.remove('nff-light', 'nff-dark');
        root.classList.add(val === 'light' ? 'nff-light' : 'nff-dark');
    });

    // League button update handler
    Shiny.addCustomMessageHandler('updateLeagueButtons', function(league) {
        // Remove active class from all buttons
        document.querySelectorAll('.league-nav-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        
        // Add active class to selected button
        const buttonMap = {
            'redraft': 'btn_redraft',
            'dynasty': 'btn_dynasty',
            'guillotine': 'btn_guillotine'
        };
        
        if (buttonMap[league]) {
            const btn = document.getElementById(buttonMap[league]);
            if (btn) btn.classList.add('active');
        }
    });

    // Initialize first league button as active
    Shiny.addCustomMessageHandler('addLeagueButtonHandler', function(msg) {
        setTimeout(() => {
            const redraftBtn = document.getElementById('btn_redraft');
            if (redraftBtn) redraftBtn.classList.add('active');
        }, 100);
    });

    // Optional: Update countdown label dynamically
    Shiny.addCustomMessageHandler('updateCountdownLabel', function(message) {
        const el = document.querySelector('.countdown-text');
        if (el) el.textContent = message.text;
    });
}

// =================== Utility Functions ===================
/**
 * Helper function to safely add event listeners
 */
function safeAddEventListener(selector, event, handler) {
    const element = document.querySelector(selector);
    if (element) {
        element.addEventListener(event, handler);
    }
}

/**
 * Helper function to toggle classes
 */
function toggleClass(selector, className) {
    const element = document.querySelector(selector);
    if (element) {
        element.classList.toggle(className);
    }
}

function setNavHeightVar() {
  const navbar = document.querySelector('.navbar');
  if (!navbar) return;
  const h = navbar.offsetHeight || 56;
  document.documentElement.style.setProperty('--nff-nav-h', `${h}px`);
}

document.addEventListener("DOMContentLoaded", () => {
  setNavHeightVar();
  window.addEventListener('resize', setNavHeightVar);

  // Recompute when the navbar collapses/expands (mobile)
  document.querySelectorAll('.navbar-collapse').forEach(el => {
    el.addEventListener('shown.bs.collapse', setNavHeightVar);
    el.addEventListener('hidden.bs.collapse', setNavHeightVar);
  });
});


// --- Auto-jump from Home -> Leagues on first downward scroll/swipe ---
(function () {
  // Config: tweak sensitivity
  const MIN_WHEEL_DELTA = 15;   // how "downward" a wheel must be to count
  const HERO_SCROLL_PCT = 0.25; // or jump after 25% of hero scrolled

  let jumpedThisVisit = false;
  let touchStartY = null;

  function isHomeActive() {
    const active = document.querySelector('.navbar .nav-link.active');
    return active && active.dataset && active.dataset.value === 'home';
  }

  function heroScrolledEnough() {
    const hero = document.querySelector('.hero-section');
    if (!hero) return false;
    const h = Math.max(hero.clientHeight, hero.offsetHeight, 1);
    return window.scrollY >= h * HERO_SCROLL_PCT;
  }

  function navSelectLeagues() {
    if (jumpedThisVisit) return;
    jumpedThisVisit = true;

    // Prefer bslib API if present
    if (window.bslib && typeof window.bslib.navSelect === 'function') {
      window.bslib.navSelect('topnav', 'leagues');
    } else {
      // Fallback: click the nav link
      const link =
        document.querySelector('.navbar .nav-link[data-value="leagues"]') ||
        document.querySelector('[data-bs-target="#leagues"]') ||
        document.querySelector('[data-value="leagues"]');
      if (link) link.click();
      // Mirror the input value for server observers (harmless if not needed)
      if (window.Shiny) {
        window.Shiny.setInputValue('topnav', 'leagues', { priority: 'event' });
      }
    }

    // Optional: snap back to top so Leagues opens at its start
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function shouldTrigger() {
    return isHomeActive() && !jumpedThisVisit;
  }

  // Mouse/trackpad wheel
  window.addEventListener(
    'wheel',
    (e) => {
      if (!shouldTrigger()) return;
      if (e.deltaY >= MIN_WHEEL_DELTA || heroScrolledEnough()) {
        navSelectLeagues();
      }
    },
    { passive: true }
  );

  // Keyboard helpers
  window.addEventListener('keydown', (e) => {
    if (!shouldTrigger()) return;
    const keys = ['PageDown', ' ', 'ArrowDown'];
    if (keys.includes(e.key)) {
      navSelectLeagues();
    }
  });

  // Touch (mobile swipe up)
  window.addEventListener(
    'touchstart',
    (e) => {
      touchStartY = e.touches && e.touches[0] ? e.touches[0].clientY : null;
    },
    { passive: true }
  );
  window.addEventListener(
    'touchend',
    (e) => {
      if (!shouldTrigger() || touchStartY == null) return;
      const endY = (e.changedTouches && e.changedTouches[0]) ? e.changedTouches[0].clientY : touchStartY;
      const delta = touchStartY - endY; // positive means swipe up
      if (delta > 30) navSelectLeagues();
      touchStartY = null;
    },
    { passive: true }
  );

  // If the user navigates back to Home manually, allow it to trigger again
  const resetOnNavChange = () => {
    const active = document.querySelector('.navbar .nav-link.active');
    const val = active && active.dataset ? active.dataset.value : null;
    jumpedThisVisit = val !== 'home' ? jumpedThisVisit : false;
  };
  document.addEventListener('click', (e) => {
    // crude: after any navbar click, reset flag appropriately
    if (e.target && e.target.closest && e.target.closest('.navbar')) {
      setTimeout(resetOnNavChange, 0);
    }
  });
})();

// --- Leagues -> Home on upward scroll at top (with smooth scroll) ---
(function () {
  const MIN_WHEEL_DELTA_UP = 20;  // how much upward wheel to count
  const TOP_EDGE_PX = 6;          // treat <= this many px from top as "at top"
  const SWIPE_DOWN_PX = 30;       // touch threshold
  let touchStartY = null;
  let cooldown = false;

  const isActive = (val) => {
    const a = document.querySelector('.navbar .nav-link.active');
    const v = a?.dataset?.value || a?.getAttribute?.('data-value');
    return v === val;
  };

  // If your Leagues area ever becomes its own scroll container, this still works.
  const atTop = () => {
    const scroller = document.querySelector('.league-content-section');
    const y = scroller && scroller.scrollHeight > scroller.clientHeight
      ? scroller.scrollTop
      : window.scrollY;
    return y <= TOP_EDGE_PX;
  };

  const navSelect = (tabValue) => {
    if (window.bslib?.navSelect) {
      window.bslib.navSelect('topnav', tabValue);
    } else {
      document.querySelector(`.navbar .nav-link[data-value="${tabValue}"]`)?.click();
      window.Shiny?.setInputValue('topnav', tabValue, { priority: 'event' });
    }
  };

  const goHome = () => {
    if (cooldown) return;
    cooldown = true;
    navSelect('home');
    // smooth scroll to top for nice feel
    window.scrollTo({ top: 0, behavior: 'smooth' });
    setTimeout(() => (cooldown = false), 400); // prevent flapping
  };

  // Wheel/trackpad: strong upward push at the very top => Home
  window.addEventListener('wheel', (e) => {
    if (isActive('leagues') && atTop() && e.deltaY < -MIN_WHEEL_DELTA_UP) goHome();
  }, { passive: true });

  // Keyboard: PageUp / ArrowUp at top => Home
  window.addEventListener('keydown', (e) => {
    if (!isActive('leagues') || !atTop()) return;
    if (e.key === 'PageUp' || e.key === 'ArrowUp' || e.key === 'Home') goHome();
  });

  // Touch: swipe down at top => Home
  window.addEventListener('touchstart', (e) => {
    touchStartY = e.touches?.[0]?.clientY ?? null;
  }, { passive: true });

  window.addEventListener('touchend', (e) => {
    if (!isActive('leagues') || !atTop() || touchStartY == null) return;
    const endY = e.changedTouches?.[0]?.clientY ?? touchStartY;
    if (endY - touchStartY > SWIPE_DOWN_PX) goHome();
    touchStartY = null;
  }, { passive: true });
})();

document.addEventListener("DOMContentLoaded", () => {
  const brand = document.getElementById("brandHome");
  if (!brand) return;

  brand.addEventListener("click", (e) => {
    e.preventDefault();

    // Prefer bslib’s API
    if (window.bslib && typeof window.bslib.navSelect === "function") {
      window.bslib.navSelect("topnav", "home");
    } else {
      // Fallbacks
      document.querySelector('.navbar .nav-link[data-value="home"]')?.click();
      window.Shiny?.setInputValue("topnav", "home", { priority: "event" });
    }

    // Nice UX: go to top smoothly
    window.scrollTo({ top: 0, behavior: "smooth" });
  });
});

// Block clicks on FULL leagues and show a tooltip instead
document.addEventListener('click', function (e) {
  const a = e.target.closest('a.league-item.is-full');
  if (!a) return;
  e.preventDefault();
  e.stopPropagation();

  const Tip = window.bootstrap?.Tooltip;
  if (Tip) {
    const tip = Tip.getOrCreateInstance(a, {
      trigger: 'manual',
      title: a.getAttribute('data-bs-title') || 'This league is full',
      placement: a.getAttribute('data-bs-placement') || 'top-end', // right edge
      container: a,                      // 👈 attach to the anchor, not <body>
      customClass: 'nff-tt',
      offset: [0, 10],
      boundary: 'viewport',
      popperConfig: (def) => ({          // 👈 make positioning immune to transforms
        ...def,
        strategy: 'fixed'
      })
    });
    tip.show();
    setTimeout(() => tip.hide(), 1400);
  }
}, { passive: false });

// Keyboard activation should match
document.addEventListener('keydown', function (e) {
  const a = document.activeElement?.closest?.('a.league-item.is-full');
  if (!a) return;
  if (e.key === 'Enter' || e.key === ' ') {
    e.preventDefault();
    const Tip = window.bootstrap?.Tooltip;
    if (Tip) {
      const tip = Tip.getOrCreateInstance(a, {
        trigger: 'manual',
        title: a.getAttribute('data-bs-title') || 'This league is full',
        placement: 'top-end',
        container: a,
        customClass: 'nff-tt',
        offset: [0, 10],
        boundary: 'viewport',
        popperConfig: (def) => ({ ...def, strategy: 'fixed' })
      });
      tip.show();
      setTimeout(() => tip.hide(), 1400);
    }
  }
});



// Also block middle-click and keyboard activation
document.addEventListener('auxclick', function (e) {
  const a = e.target.closest('a.league-item.is-full');
  if (!a) return;
  e.preventDefault();
  e.stopPropagation();
});

document.addEventListener('keydown', function (e) {
  const a = document.activeElement?.closest?.('a.league-item.is-full');
  if (!a) return;
  if (e.key === 'Enter' || e.key === ' ') {
    e.preventDefault();
    const Tip = window.bootstrap?.Tooltip;
    if (Tip) {
      const tip = Tip.getOrCreateInstance(a, {
        trigger: 'manual',
        title: a.getAttribute('data-bs-title') || 'This league is full',
        placement: 'top-end',
        container: a,
        customClass: 'nff-tt',
        offset: [0, 10],
        boundary: 'viewport',
        popperConfig: (def) => ({ ...def, strategy: 'fixed' })
      });
      tip.show();
      setTimeout(() => tip.hide(), 1400);
    }
  }
});

// Floating Back-to-top (works on all pages/tabs)
(function(){
  const btn = document.getElementById('scrollTopBtn');
  if (!btn) return;

  const SHOW_AT = 200;   // px down before showing
  function update() {
    const y = window.scrollY || document.documentElement.scrollTop || 0;
    if (y > SHOW_AT) btn.classList.add('show'); else btn.classList.remove('show');
  }
  window.addEventListener('scroll', update, { passive: true });
  document.addEventListener('DOMContentLoaded', update);

  btn.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });
})();

// Auto-collapse mobile navbar after selecting a page
document.addEventListener('DOMContentLoaded', () => {
  const navbar = document.querySelector('.navbar');
  const collapseEl = navbar?.querySelector('.navbar-collapse');
  if (!collapseEl || !window.bootstrap) return;

  const collapseApi = bootstrap.Collapse.getOrCreateInstance(collapseEl, { toggle: false });

  const collapseIfOpen = () => {
    if (collapseEl.classList.contains('show')) collapseApi.hide();
  };

  // 1) User taps a nav link or dropdown item inside the collapsed menu
  collapseEl.addEventListener('click', (e) => {
    const link = e.target.closest('.nav-link, .dropdown-item');
    if (!link || link.classList.contains('dropdown-toggle')) return;
    // let Bootstrap switch tabs first, then collapse
    setTimeout(collapseIfOpen, 100);
  }, { passive: true });

  // 2) Programmatic tab changes (e.g., bslib.navSelect, brand click, scroll jump)
  // Bootstrap fires this when a tab becomes active
  document.addEventListener('shown.bs.tab', collapseIfOpen);

  // 3) If you use Shiny to set the tab value, this covers it too
  document.addEventListener('shiny:inputchanged', (e) => {
    if (e.detail?.name === 'topnav') setTimeout(collapseIfOpen, 0);
  });

  // Optional: expose a helper so your own code can force-collapse after nav changes
  window.nffCollapseNavbar = collapseIfOpen;
});

document.addEventListener("DOMContentLoaded", () => {
  const goLeagues = () => {
    if (window.bslib?.navSelect) {
      window.bslib.navSelect("topnav", "leagues");
    } else {
      document.querySelector('.navbar .nav-link[data-value="leagues"]')?.click();
      window.Shiny?.setInputValue("topnav", "leagues", { priority: "event" });
    }
    window.scrollTo({ top: 0, behavior: "smooth" });
    window.nffCollapseNavbar?.(); // if mobile menu is open, close it
  };

  document.getElementById("cta_view_app")?.addEventListener("click", goLeagues);
  document.getElementById("hero_scroll_down")?.addEventListener("click", goLeagues);
});

// Global scroll-down: scroll the primary scroller by ~1 viewport
document.addEventListener('DOMContentLoaded', () => {
  const btn = document.getElementById('scrollDownBtn');
  if (!btn) return;

  const getScrollers = () => {
    // Add any inner scrollers you use (e.g., leagues content section)
    const arr = [window];
    const leagues = document.querySelector('.league-content-section');
    if (leagues) arr.push(leagues);
    return arr;
  };

  const doScroll = () => {
    const delta = Math.round(window.innerHeight * 0.9);
    const scrollers = getScrollers();
    // If an inner scroller is currently scrollable and focused/hovered, prefer it
    const hovered = scrollers.find(s => {
      const el = (s === window) ? document.scrollingElement : s;
      return el && el.scrollHeight > el.clientHeight && el.matches?.(':hover');
    });

    const target = hovered || window;
    if (target === window) {
      window.scrollBy({ top: delta, behavior: 'smooth' });
    } else {
      target.scrollBy({ top: delta, behavior: 'smooth' });
    }
  };

  btn.addEventListener('click', doScroll);
});

// Make "NUCLEAR" and "FANTASY FOOTBALL" the same width by adjusting font sizes
document.addEventListener('DOMContentLoaded', () => {
  const mainEl = document.querySelector('.hero-title-main');
  const subEl  = document.querySelector('.hero-title-sub');
  if (!mainEl || !subEl) return;

  const fit = () => {
    // reset to CSS sizes first so we measure cleanly on resize
    mainEl.style.fontSize = '';
    subEl.style.fontSize  = '';

    const mainW = mainEl.getBoundingClientRect().width;
    const subW  = subEl.getBoundingClientRect().width;
    if (!mainW || !subW) return;

    // target = wider of the two; scale the other line up/down to match
    const target = Math.max(mainW, subW);

    const scaleTo = (el, fromW) => {
      const base = parseFloat(getComputedStyle(el).fontSize);
      if (!base || !fromW) return;
      const newSize = base * (target / fromW);
      el.style.fontSize = `${newSize}px`;
    };

    if (mainW < target) scaleTo(mainEl, mainW);
    if (subW  < target) scaleTo(subEl,  subW);
  };

  const debounce = (fn, ms=120) => {
    let t; return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), ms); };
  };

  fit();
  // after fit(); in your DOMContentLoaded handler
  if (document.fonts?.ready) { document.fonts.ready.then(fit); }

  window.addEventListener('resize', debounce(fit, 120));
});


// =================== Export for potential module use ===================
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        initTheme,
        initCountdown,
        initNavbarBehavior,
        initShinyHandlers,
        initNavbarAutoCollapse
    };
}
