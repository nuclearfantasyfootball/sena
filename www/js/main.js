// =================== NUCLEARFF MAIN JAVASCRIPT ===================

/** Shared constants */
const LS_KEY = 'nff-theme';

/** 
 * Get initial theme from localStorage or system preference
 */
function getInitialTheme() {
  try {
    const stored = localStorage.getItem(LS_KEY);
    if (stored === 'light' || stored === 'dark') {
      return stored;
    }
  } catch (e) {
    console.warn('localStorage not available:', e);
  }
  
  // Check system preference if no stored value
  if (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches) {
    return 'light';
  }
  
  return 'dark';
}

/** 
 * Apply theme class globally with additional DataTables refresh
 */
function applyThemeClass(mode) {
  const validMode = mode === 'light' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-bs-theme', validMode);
  
  // Also maintain legacy classes for compatibility
  document.documentElement.classList.toggle('nff-light', validMode === 'light');
  document.documentElement.classList.toggle('nff-dark', validMode === 'dark');

  // Emit custom event so gradient backgrounds can respond/re-bias
  window.dispatchEvent(new Event('nff:theme-applied'));
  
  // Force DataTables to refresh styling if present
  setTimeout(() => {
    if (window.jQuery && window.jQuery.fn.DataTable) {
      window.jQuery('table.dataTable').each(function() {
        const table = window.jQuery(this).DataTable();
        if (table) {
          try {
            table.draw(false);
          } catch (e) {
            console.log('DataTable refresh skipped:', e);
          }
        }
      });
    }
  }, 50);
}

/** 
 * Snap theme change (no gray tween) 
 */
function toggleTheme(nextTheme) {
  const root = document.documentElement;
  const currentTheme = root.getAttribute('data-bs-theme') || 'dark';
  const newTheme = nextTheme || (currentTheme === 'light' ? 'dark' : 'light');

  // Kill transitions for one paint so colors snap
  root.classList.add('nff-no-transitions');

  // Apply theme
  applyThemeClass(newTheme);

  // Persist
  try { 
    localStorage.setItem(LS_KEY, newTheme); 
  } catch (e) {
    console.warn('Could not save theme:', e);
  }

  // Re-enable transitions on next frame
  requestAnimationFrame(() => {
    root.classList.remove('nff-no-transitions');
  });
  
  return newTheme;
}

document.addEventListener("DOMContentLoaded", () => {
  initTheme();
  initCountdown("2025-08-15T09:00:00-04:00");
  initShinyHandlers();
  initNavbarAutoCollapse();
  setNavHeightVar();
  
  window.addEventListener('resize', setNavHeightVar);
  
  document.querySelectorAll('.navbar-collapse').forEach(el => {
    el.addEventListener('shown.bs.collapse', setNavHeightVar);
    el.addEventListener('hidden.bs.collapse', setNavHeightVar);
  });
  
  console.log("NuclearFF Frontend Launched");
});

// =================== Navbar Auto-Collapse ===================
function initNavbarAutoCollapse() {
  const setupAutoCollapse = () => {
    let navLinks = document.querySelectorAll('.navbar-nav .nav-link, .nav-link[data-bs-toggle="tab"], [data-value][data-bs-toggle="tab"]');
    let navbarToggler = document.querySelector('.navbar-toggler, [data-bs-toggle="collapse"]');
    let navbarCollapse = document.querySelector('.navbar-collapse, .collapse');

    if (!navLinks.length) navLinks = document.querySelectorAll('a[data-value]');

    if (!navLinks.length || !navbarToggler || !navbarCollapse) {
      setTimeout(setupAutoCollapse, 1000);
      return;
    }

    let bsCollapse = null;
    if (window.bootstrap && window.bootstrap.Collapse) {
      try { 
        bsCollapse = new window.bootstrap.Collapse(navbarCollapse, { toggle: false }); 
      } catch (e) {
        console.warn('Could not init collapse:', e);
      }
    }

    const handleNavbarCollapse = () => {
      const isMobile = window.getComputedStyle(navbarToggler).display !== 'none';
      const isExpanded = navbarCollapse.classList.contains('show') || navbarCollapse.classList.contains('showing');
      if (isMobile && isExpanded) {
        if (bsCollapse) {
          try { 
            bsCollapse.hide(); 
            return; 
          } catch (e) {
            console.warn('Could not hide navbar:', e);
          }
        }
        setTimeout(() => navbarToggler.click(), 150);
        setTimeout(() => {
          if (navbarCollapse.classList.contains('show')) {
            navbarCollapse.classList.remove('show');
            navbarCollapse.classList.add('collapse');
          }
        }, 300);
      }
    };

    navLinks.forEach(link => {
      link.addEventListener('click', () => handleNavbarCollapse());
    });

    const setupThemeToggleCollapse = () => {
      const themeToggle = document.querySelector('#toggle_theme, .nav-icon-btn');
      if (themeToggle) {
        themeToggle.addEventListener('click', () => handleNavbarCollapse());
      } else {
        setTimeout(setupThemeToggleCollapse, 500);
      }
    };
    setupThemeToggleCollapse();
  };

  setupAutoCollapse();
  
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupAutoCollapse);
  }
  
  if (window.Shiny) {
    Shiny.addCustomMessageHandler('setupNavbarCollapse', setupAutoCollapse);
    if (window.jQuery) {
      jQuery(document).on('shiny:connected', setupAutoCollapse);
    }
  }
  
  setTimeout(setupAutoCollapse, 2000);
}

// =================== Theme Management ===================
function initTheme() {
  const theme = getInitialTheme();
  applyThemeClass(theme);
  
  if (window.Shiny && typeof Shiny.setInputValue === 'function') {
    if (window.Shiny.shinyapp) {
      Shiny.setInputValue('initTheme', theme, { priority: 'event' });
    } else if (window.jQuery) {
      jQuery(document).on('shiny:connected', function() {
        Shiny.setInputValue('initTheme', theme, { priority: 'event' });
      });
    }
  }
  
  // Listen for system theme changes
  if (window.matchMedia) {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: light)');
    if (mediaQuery.addEventListener) {
      mediaQuery.addEventListener('change', (e) => {
        try {
          const stored = localStorage.getItem(LS_KEY);
          if (!stored) {
            const newTheme = e.matches ? 'light' : 'dark';
            applyThemeClass(newTheme);
          }
        } catch (err) {
          const newTheme = e.matches ? 'light' : 'dark';
          applyThemeClass(newTheme);
        }
      });
    }
  }
}

// =================== Countdown Timer ===================
function initCountdown(targetDate) {
  const countdownContainer = document.querySelector(".countdown-text");
  if (!countdownContainer) return;

  const target = new Date(targetDate).getTime();
  const pad = (num) => String(num).padStart(2, '0');

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

    countdownContainer.innerHTML = days + 'D ' + pad(hours) + 'H ' + pad(minutes) + 'M ' + pad(seconds) + 'S';
  };

  updateCountdown();
  const interval = setInterval(updateCountdown, 1000);
}

// =================== Shiny Integration ===================
function initShinyHandlers() {
  if (!window.Shiny) return;
  
  Shiny.addCustomMessageHandler("storeTheme", (val) => {
    try { 
      localStorage.setItem(LS_KEY, val); 
    } catch (e) {
      console.warn('Could not store theme:', e);
    }
  });
  
  Shiny.addCustomMessageHandler("applyThemeClass", (val) => {
    applyThemeClass(val);
  });
  
  Shiny.addCustomMessageHandler("toggleTheme", (val) => {
    if (val === 'light' || val === 'dark') {
      toggleTheme(val);
    } else {
      const cur = document.documentElement.getAttribute('data-bs-theme') || 'dark';
      toggleTheme(cur === 'light' ? 'dark' : 'light');
    }
  });

  // League button update handler
  Shiny.addCustomMessageHandler('updateLeagueButtons', function (league) {
    document.querySelectorAll('.league-nav-btn').forEach(btn => btn.classList.remove('active'));
    const buttonMap = { 
      redraft: 'btn_redraft', 
      dynasty: 'btn_dynasty', 
      chopped: 'btn_chopped',
      survivor: 'btn_survivor' 
    };
    const id = buttonMap[league];
    const btn = document.getElementById(id);
    if (btn) btn.classList.add('active');
  });

  // Initialize first league button as active
  Shiny.addCustomMessageHandler('addLeagueButtonHandler', function () {
    setTimeout(() => {
      const btn = document.getElementById('btn_redraft');
      if (btn) btn.classList.add('active');
    }, 100);
  });

  // Optional: Update countdown label dynamically
  Shiny.addCustomMessageHandler('updateCountdownLabel', function (message) {
    const el = document.querySelector('.countdown-text');
    if (el) el.textContent = message.text;
  });
}

// =================== Utility ===================
function setNavHeightVar() {
  const navbar = document.querySelector('.navbar');
  if (!navbar) return;
  const h = navbar.offsetHeight || 56;
  document.documentElement.style.setProperty('--nff-nav-h', h + 'px');
}

// =================== Brand click handler ===================
document.addEventListener("DOMContentLoaded", () => {
  const brand = document.getElementById("brandHome");
  if (!brand) return;
  
  brand.addEventListener("click", (e) => {
    e.preventDefault();
    
    // Always navigate to home first, then handle section reset
    const currentTab = document.querySelector('.navbar .nav-link.active[data-value]');
    const isOnHome = currentTab && currentTab.getAttribute('data-value') === 'home';
    
    if (!isOnHome) {
      // Navigate to home tab first
      if (window.bslib && typeof window.bslib.navSelect === 'function') {
        window.bslib.navSelect("topnav", "home");
      } else {
        const homeLink = document.querySelector('.navbar .nav-link[data-value="home"]');
        if (homeLink) homeLink.click();
        if (window.Shiny && typeof Shiny.setInputValue === 'function') {
          Shiny.setInputValue("topnav", "home", { priority: "event" });
        }
      }
    }
    
    // Always attempt to reset to first section with proper delay
    setTimeout(() => {
      if (typeof window.gotoSection === 'function') {
        window.gotoSection(0, 1);
      } else if (window.currentIndex !== undefined) {
        // Fallback: trigger the scroll system directly
        const scrollContainer = document.querySelector('.scroll-container');
        if (scrollContainer) {
          // Re-initialize if needed
          if (typeof initScrollSections === 'function') {
            initScrollSections();
            setTimeout(() => {
              if (typeof window.gotoSection === 'function') {
                window.gotoSection(0, 1);
              }
            }, 200);
          }
        }
      }
    }, isOnHome ? 100 : 300); // Shorter delay if already on home
  });
});

// =================== Block clicks on FULL leagues ===================
document.addEventListener('click', function (e) {
  const a = e.target.closest('a.league-item.is-full');
  if (!a) return;
  e.preventDefault();
  e.stopPropagation();

  const Tip = window.bootstrap && window.bootstrap.Tooltip;
  if (Tip) {
    const tip = Tip.getOrCreateInstance(a, {
      trigger: 'manual',
      title: a.getAttribute('data-bs-title') || 'This league is full',
      placement: a.getAttribute('data-bs-placement') || 'top-end',
      container: a,
      customClass: 'nff-tt',
      offset: [0, 10],
      boundary: 'viewport',
      popperConfig: (def) => ({ ...def, strategy: 'fixed' })
    });
    tip.show();
    setTimeout(() => tip.hide(), 1400);
  }
}, false);

// Keyboard activation should match
document.addEventListener('keydown', function (e) {
  const a = document.activeElement && document.activeElement.closest && document.activeElement.closest('a.league-item.is-full');
  if (!a) return;
  if (e.key === 'Enter' || e.key === ' ') {
    e.preventDefault();
    const Tip = window.bootstrap && window.bootstrap.Tooltip;
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

// Auto-collapse mobile navbar after selecting a page
document.addEventListener('DOMContentLoaded', () => {
  const navbar = document.querySelector('.navbar');
  if (!navbar) return;
  const collapseEl = navbar.querySelector('.navbar-collapse');
  if (!collapseEl || !window.bootstrap) return;

  const collapseApi = bootstrap.Collapse.getOrCreateInstance(collapseEl, { toggle: false });
  const collapseIfOpen = () => { 
    if (collapseEl.classList.contains('show')) collapseApi.hide(); 
  };

  collapseEl.addEventListener('click', (e) => {
    const link = e.target.closest('.nav-link, .dropdown-item');
    if (!link || link.classList.contains('dropdown-toggle')) return;
    setTimeout(collapseIfOpen, 100);
  }, true);

  document.addEventListener('shown.bs.tab', collapseIfOpen);
  document.addEventListener('shiny:inputchanged', (e) => {
    if (e.detail && e.detail.name === 'topnav') setTimeout(collapseIfOpen, 0);
  });

  window.nffCollapseNavbar = collapseIfOpen;
});

// Dynamically manage scroll behavior
document.addEventListener("DOMContentLoaded", () => {
  // Enable scrolling on non-home tabs
  if (window.Shiny) {
    Shiny.addCustomMessageHandler('tabChanged', function(tab) {
      const body = document.body;
      const html = document.documentElement;
      const scrollContainer = document.querySelector('.scroll-container');
      
      // Set data attribute for CSS targeting
      document.documentElement.setAttribute('data-active-tab', tab);
      
      if (tab === 'home') {
        // Disable normal scrolling for home
        body.style.overflow = 'hidden';
        html.style.overflow = 'hidden';
        body.style.height = '100vh';
        
        // Show scroll container
        if (scrollContainer) {
          scrollContainer.style.display = 'block';
          scrollContainer.setAttribute('aria-hidden', 'false');
        }
      } else {
        // Enable normal scrolling for other pages
        body.style.overflow = 'auto';
        html.style.overflow = 'auto';
        body.style.height = 'auto';
        
        // Hide scroll container
        if (scrollContainer) {
          scrollContainer.style.display = 'none';
          scrollContainer.setAttribute('aria-hidden', 'true');
        }
      }
    });
  }
});

// =================== Exports ===================
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    initTheme: initTheme,
    initCountdown: initCountdown,
    initShinyHandlers: initShinyHandlers,
    initNavbarAutoCollapse: initNavbarAutoCollapse
  };
}