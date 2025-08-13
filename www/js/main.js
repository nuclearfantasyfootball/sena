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
