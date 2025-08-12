document.addEventListener("DOMContentLoaded", () => {
    initCountdown("2025-08-15T09:00:00-04:00"); // Set countdown target date
    initNavbarBehavior();
    console.log("NuclearFF Frontend Launched 🚀");
});

/**
 * Initializes a countdown timer and updates the UI.
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
            countdownContainer.innerHTML = "LAUNCHED";
            clearInterval(interval);
            return;
        }

        const days = Math.floor(distance / (1000 * 60 * 60 * 24));
        const hours = Math.floor((distance / (1000 * 60 * 60)) % 24);
        const minutes = Math.floor((distance / (1000 * 60)) % 60);
        const seconds = Math.floor((distance / 1000) % 60);

        countdownContainer.innerHTML = `
            ${days}d ${pad(hours)}h ${pad(minutes)}m ${pad(seconds)}s
        `;
    };

    const pad = (num) => String(num).padStart(2, '0');
    updateCountdown();
    const interval = setInterval(updateCountdown, 1000);
}

/**
 * Minimizes navbar padding on scroll.
 */
function initNavbarBehavior() {
    const navbar = document.querySelector(".navbar-custom");
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

/**
 * Handle dynamic Shiny updates (if needed)
 * You can use Shiny.addCustomMessageHandler here
 */
if (window.Shiny) {
    // Example: listen for Shiny messages to update text
    Shiny.addCustomMessageHandler("updateCountdownLabel", (message) => {
        const el = document.querySelector(".countdown-text");
        if (el) el.textContent = message.text;
    });
}

/* Button Highlighting */
// League button handler
Shiny.addCustomMessageHandler('updateLeagueButtons', function(league) {
  // Remove active class from all buttons
  document.querySelectorAll('.league-nav-btn').forEach(btn => {
    btn.classList.remove('active');
  });
  
  // Add active class to selected button
  if (league === 'redraft') {
    document.getElementById('btn_redraft')?.classList.add('active');
  } else if (league === 'dynasty') {
    document.getElementById('btn_dynasty')?.classList.add('active');
  } else if (league === 'guillotine') {
    document.getElementById('btn_guillotine')?.classList.add('active');
  }
});

// Initialize first button as active
Shiny.addCustomMessageHandler('addLeagueButtonHandler', function(msg) {
  setTimeout(() => {
    document.getElementById('btn_redraft')?.classList.add('active');
  }, 100);
});