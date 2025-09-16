# =================== NUCLEARFF SHINY APPLICATION ===================
# NuclearFF UI/Server Shiny Application
# Author: Nolan MacDonald

# Load required packages
library(shiny)
library(bslib)
library(DT)
library(htmltools)
library(bsicons)
library(commonmark)
library(sass)

DEV_MODE <- TRUE

# Source all R files, all functions/modules available globally
source_dir <- function(path) {
  files <- list.files(path, pattern = "\\.R$", full.names = TRUE)
  lapply(files, source)
  invisible(TRUE)
}

source_dir("R")

# Initialize environment
init_app_environment()
check_required_packages()

# Get configuration
config <- app_config()

# Build UI ──────────────────────────────────────────────────────────────────
build_ui <- function() {
  tagList(
    # Head includes
    build_head_tags(config),

    # Main navigation
    page_navbar(
      title = build_navbar_brand(config),
      window_title = "Nuclear Fantasy Football",

      # Home panel ---------------------------------------------------
      nav_panel(
        "Home",
        value = "home",
        home_page_ui("home")
      ),

      # Leagues panel ---------------------------------------------------
      nav_panel(
        "Leagues",
        value = "leagues",
        leagues_page_ui("leagues")
      ),

      # FAQ panel with integrated article display -------------------
      nav_panel(
        "FAQ",
        value = "faq",
        faq_page_ui("faq")
      ),

      # Tools panel---------------------------------------------------
      nav_panel(
        "Tools",
        value = "tools",
        data_tools_ui("data_tools")
      ),

      # Navbar spacing before adding social links
      nav_spacer(),

      # Right-aligned navigation
      nav_item(
        tags$div(
          class = "d-flex align-items-center",
          navigation_ui("nav", type = "header"),
          uiOutput("theme_toggle", inline = TRUE) # Theme toggle
        )
      ),
      id = "topnav",
      selected = "home",
      theme = config$themes$dark,
      navbar_options = navbar_options(position = "fixed-top")
    )
  )
}

# Build head tags - Import libraries and resources
build_head_tags <- function(config) {
  tags$head(
    # Theme initialization (keep existing)
    tags$script(HTML("(function () {
      var pref = (function(){ try { return localStorage.getItem('nff-theme'); } catch(e){ return null; } })() || 'dark';
      var root = document.documentElement;
      root.setAttribute('data-bs-theme', pref);
      root.classList.add(pref === 'light' ? 'nff-light' : 'nff-dark');
    })();")),

    # GSAP Libraries - Use CDN with SplitText plugin
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/Observer.min.js"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/ScrollTrigger.min.js"),

    # Google Analytics
    tags$script(src = "https://www.googletagmanager.com/gtag/js?id=G-ZW75NFDLXL", async = NA),
    tags$script(HTML("
      window.dataLayer = window.dataLayer || [];
      function gtag(){ dataLayer.push(arguments); }
      gtag('js', new Date());
      gtag('config', 'G-ZW75NFDLXL', { 'anonymize_ip': true });
    ")),

    # Resources
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
    tags$link(rel = "preconnect", href = "https://fonts.gstatic.com", crossorigin = NA),
    tags$link(rel = "stylesheet", href = config$external_resources$fonts$montserrat),
    tags$link(rel = "stylesheet", href = "css/style.css"),
    tags$link(rel = "stylesheet", href = "css/hero_scroll.css"),
    tags$link(rel = "stylesheet", href = "css/backdrop.css"), # Backgrounds
    tags$link(rel = "stylesheet", href = "css/glass_effects.css"), # Liquid glass
    tags$link(rel = "stylesheet", href = "css/electrified_button.css"),
    tags$link(rel = "stylesheet", href = "css/scroll_indicator.css"), # Scroll animation
    tags$link(rel = "stylesheet", href = "css/development.css"), # Development
    tags$link(rel = "stylesheet", href = "css/text_animation.css"), # Text animation

    # SASS compiled styles
    tags$style(
      sass::sass(
        input = sass::sass_file("www/scss/text_styles.scss")
      )
    ),

    # JavaScript
    tags$script(src = "js/main.js", defer = NA),
    tags$script(src = "js/hero_scroll.js", defer = NA),
    tags$script(src = "js/backdrop.js", defer = NA), # Background effects
    tags$script(src = "js/glass_effects.js", defer = NA), # Liquid glass effects
    tags$script(src = "js/electrified_button.js", defer = NA),

    # Custom message handlers
    tags$script(HTML("
    Shiny.addCustomMessageHandler('nff:navChanged', function(tab) {
      // Tag document state for CSS if you want it
      document.documentElement.setAttribute('data-active-tab', tab);

      // Hide the full-viewport Home scroller on non-Home tabs so it doesn't block scroll
      const sc = document.querySelector('.scroll-container');
      if (!sc) return;
      const off = (tab !== 'home');

      // When off-Home: completely remove it from layout and hit-testing
      sc.setAttribute('aria-hidden', off ? 'true' : 'false');
      if (off) {
        sc.style.display = 'none';
      } else {
        sc.style.display = '';
      }
    });

    // Smooth scroll to top for article navigation
    Shiny.addCustomMessageHandler('scrollToTop', function(message) {
      window.scrollTo({
        top: 0,
        behavior: 'smooth'
      });
    });
  ")),

    # GA track page_view on tab change
    tags$script(HTML("
      Shiny.addCustomMessageHandler('nff:navChanged', function(tab) {
        // GA page view for SPA navigation
        if (window.gtag) {
          var pagePath = '/' + tab;
          var pageLoc  = window.location.origin + window.location.pathname + '#' + tab;
          gtag('event','page_view', {
            page_title: 'NuclearFF - ' + tab,
            page_path: pagePath,
            page_location: pageLoc
          });
        }
      });
    "))
  )
}

# Build navbar brand
build_navbar_brand <- function(config) {
  tags$a(
    id = "brandHome",
    class = "navbar-brand d-flex align-items-center",
    href = "#",
    `aria-label` = "Go to Home",
    tags$img(
      src = config$external_resources$logo_url,
      height = 40,
      alt = "Nuclear Fantasy Football"
    )
  )
}

# Server ────────────────────────────────────────────────────────────────────
build_server <- function() {
  function(input, output, session) {
    # Initialize JavaScript handlers
    init_js_handlers(session)

    # Theme Management (NOT modularized)
    theme_state <- reactiveVal("dark")

    output$theme_toggle <- renderUI({
      icon_name <- if (identical(theme_state(), "dark")) "moon-stars" else "sun"
      actionLink(
        "toggle_theme",
        label = bs_icon(icon_name),
        class = "nav-icon-btn ms-1",
        title = "Toggle light/dark mode",
        style = "color: inherit;"
      )
    })

    # Initialize theme from localStorage
    observeEvent(input$initTheme,
      {
        val <- if (identical(input$initTheme, "light")) "light" else "dark"
        theme_state(val)
        theme <- if (val == "light") config$themes$light else config$themes$dark
        session$setCurrentTheme(theme)
        session$sendCustomMessage("applyThemeClass", val)
      },
      ignoreInit = TRUE
    )

    # Handle theme toggle
    observeEvent(input$toggle_theme,
      {
        new_val <- if (theme_state() == "dark") "light" else "dark"
        theme_state(new_val)
        theme <- if (new_val == "light") config$themes$light else config$themes$dark
        session$setCurrentTheme(theme)
        session$sendCustomMessage("storeTheme", new_val)
        session$sendCustomMessage("applyThemeClass", new_val)
      },
      ignoreInit = TRUE
    )

    # Record which tab is active so JS can enable/disable the home scroller
    observeEvent(input$topnav, {
      session$sendCustomMessage("nff:navChanged", input$topnav)
    })

    # Module: Home page
    home_state <- home_page_server("home", parent_session = session)

    # Module: Leagues page
    selected_league <- leagues_page_server("leagues")

    # Module: FAQ page with integrated article display
    faq_state <- faq_page_server("faq", parent_session = session)

    # Module: Data tools
    data_state <- data_tools_server("data_tools", data = reactive(iris))

    # Send tab change events to JS for scroll handling
    observeEvent(input$topnav,
      {
        session$sendCustomMessage("tabChanged", input$topnav)
      },
      ignoreInit = FALSE
    ) # Don't ignore init to set initial state

    # Global observers
    observe({
      logEvent("page_view", page = input$topnav)
    })

    # Handle session end
    session$onSessionEnded(function() {
      logEvent("session_ended")
    })
  }
}

# Run Application ───────────────────────────────────────────────────────────
shinyApp(
  ui = build_ui(),
  server = build_server()
)
