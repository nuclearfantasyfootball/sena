# NuclearFF Full Application

# ── Packages ───────────────────────────────────────────────────────────────────
library(shiny)
library(bslib)
library(DT)
library(htmltools)
library(bsicons)

# Silence bslib contrast warnings
# Production helpful
options(
  shiny.minified = TRUE, # use minified JS
  bslib.precompiled = TRUE, # cache/precompile themes (faster reloads)
  bslib.color_contrast_warnings = FALSE # suppress WCAG contrast warnings for brand colors
)

# ── Themes (light/dark) ───────────────────────────────────────────────────────
# Default brand color keeps your magenta accent
light_theme <- bs_theme(
  version = 5,
  bg = "#ffffff",
  fg = "#212529",
  primary = "#0fa0ce"
)

dark_theme <- bs_theme(
  version = 5,
  bg = "#0e0e0e",
  fg = "#e9ecef",
  primary = "#ce0fa0"
)

# ── UI ────────────────────────────────────────────────────────────────────────
ui <- tagList(
  # Head includes: CSS/JS from www/, preload bg image, and small tweaks
  tags$head(
    tags$link(rel = "preload", href = "images/football-stadium-bg.jpg", as = "image"),
    tags$link(rel = "stylesheet", href = "css/style.css"),
    # Make the default Bootstrap navbar resemble .navbar-custom in style.css
    tags$style(HTML("
      /* Global layout fixes */
      html, body { margin: 0; overflow-x: hidden; }
      body { padding-top: 56px; } /* space for fixed navbar */

      /* Navbar look & feel */
      .navbar {
        background: rgba(0, 0, 0, 0.8);
        backdrop-filter: blur(10px);
        padding: 2px 5px !important;
        min-height: 56px;
      }

      /* Vertically center brand logo with nav links */
      .navbar .container-fluid {
        display: flex !important;
        align-items: center !important;
      }
      .navbar .navbar-brand {
        display: flex !important;
        align-items: center !important;
        padding-top: 0 !important;
        padding-bottom: 0 !important;
        margin-right: .5rem; /* tighter gap between logo and Home */
      }
      .navbar .navbar-brand img {
        height: 40px;
        display: block;
      }
      .navbar-nav { gap: 0; }
      .navbar-nav .nav-link {
        display: flex;
        align-items: center;
        height: 56px;
        color: #fff;
      }
      /* Active tab color per theme */
      .nff-dark .navbar .nav-link.active,
      .nff-dark .navbar .navbar-nav .nav-link.active,
      .nff-dark .navbar .nav-link.show {
        color: #ce0fa0 !important;
      }

      .nff-light .navbar .nav-link.active,
      .nff-light .navbar .navbar-nav .nav-link.active,
      .nff-light .navbar .nav-link.show {
        color: #0fa0ce !important;
      }

      /* Icon button to the right (theme toggle) */
      .nav-icon-btn {
        display: flex;
        align-items: center;
        font-size: 1.15rem;
        padding: 0 .25rem;
        color: #fff !important;
        text-decoration: none;
      }
      /* Hover state for icon button */
      .nff-dark .navbar .nav-icon-btn:hover { color: #ce0fa0 !important; }
      .nff-light .navbar .nav-icon-btn:hover { color: #0fa0ce !important; }


      /* Home tab: remove side gutters so background can be edge-to-edge */
      .tab-pane#home > .container,
      .tab-pane#home > .container-fluid {
        max-width: 100% !important;
        width: 100% !important;
        padding-left: 0 !important;
        padding-right: 0 !important;
      }

      /* Ensure hero background truly covers full viewport width */
      .hero-section {
        width: 100vw;
        margin-left: calc(50% - 50vw);
        margin-right: calc(50% - 50vw);
        min-height: calc(100vh - 56px);
        background-size: cover;
        background-position: center center;
        background-repeat: no-repeat;
      }

      /* Theme-synced hero overlay */
      .hero-overlay {
        position: relative;
        background: radial-gradient(80% 60% at 50% 40%, rgba(0,0,0,.15), rgba(0,0,0,.55));
      }
      .nff-light .hero-overlay {
        background: radial-gradient(80% 60% at 50% 40%, rgba(255,255,255,.10), rgba(0,0,0,.35));
      }
      .nff-dark .hero-overlay {
        background: radial-gradient(80% 60% at 50% 40%, rgba(0,0,0,.20), rgba(0,0,0,.60));
      }

      /* Small screens: tighten hero typography */
      @media (max-width: 400px) {
        .hero-section { min-height: 100vh; height: auto; }
        .hero-title-nuclear-minimal {
          font-size: 2.2rem !important;
          font-weight: 700 !important;
          letter-spacing: 0;
        }
      }
    ")),
    tags$script(src = "js/main.js", defer = NA),
    # Remember theme preference across reloads
    tags$script(HTML("
      (function(){
        function applyThemeClass(val){
          var root = document.documentElement;
          root.classList.remove('nff-light','nff-dark');
          root.classList.add(val === 'light' ? 'nff-light' : 'nff-dark');
        }
        document.addEventListener('DOMContentLoaded', function () {
          try {
            var pref = localStorage.getItem('nff-theme') || 'dark';
            applyThemeClass(pref);
            if (window.Shiny) Shiny.setInputValue('initTheme', pref, {priority: 'event'});
          } catch (e) {}
        });
        if (window.Shiny) {
          Shiny.addCustomMessageHandler('storeTheme', function (val) {
            try { localStorage.setItem('nff-theme', val); } catch (e) {}
          });
          Shiny.addCustomMessageHandler('applyThemeClass', function (val) {
            applyThemeClass(val);
          });
        }
      })();
    "))
  ),

  # Navbar layout with left logo, middle tabs, right social icons + theme toggle
  page_navbar(
    title = tags$a(
      class = "navbar-brand d-flex align-items-center",
      href = "#home",
      tags$img(
        src = "https://raw.githubusercontent.com/NuclearAnalyticsLab/nuclearff/refs/heads/main/inst/logos/png/nuclearff-2color.png",
        height = 40,
        alt = "Nuclear Fantasy Football"
      )
    ),

    # ── Home (Launch) ──
    nav_panel(
      "Home",
      value = "home",
      # Hero section markup mirrors index.html so existing CSS anims apply
      tags$section(
        class = "hero-section",
        tags$div(class = "hero-overlay"),
        tags$div(
          class = "hero-content fade-in",
          tags$h1(
            class = "hero-title-nuclear-minimal",
            tags$span(class = "word nuclear", "NUCLEAR"),
            tags$span(class = "word ff", "FF")
          ),
          tags$p(class = "hero-subtitle", "Nuclear Fantasy Football - Coming Soon"),
          tags$div(
            class = "countdown-display",
            tags$h2(style = "margin-bottom: 1rem;", "LAUNCH SEQUENCE"),
            tags$div(
              class = "countdown-text",
              textOutput("countdown", inline = TRUE)
            ),
            tags$p(style = "margin-top: 1rem; opacity: 0.8;", "Aug. 15, 2025 (9:00 AM ET)")
          )
        )
      )
    ),

    # ── Data (placeholder using DT DataTables demo style) ──
    nav_panel(
      "Data",
      value = "data",
      layout_column_wrap(
        widths = 1,
        card(
          card_header("Iris DataTable (Demo)"),
          DTOutput("tbl", width = "100%")
        )
      )
    ),

    # Push following items to right side
    nav_spacer(),

    # Right‑aligned social links (reuse classes from style.css for hover fx)
    nav_item(
      tags$div(
        class = "social-links d-flex align-items-center",
        tags$a(
          href = "https://x.com/nuclearffnolan", target = "_blank",
          title = "X / Twitter",
          bs_icon("twitter-x")
        ),
        tags$a(
          href = "https://discord.gg/9sJQ4yYkkF", target = "_blank",
          title = "Discord",
          bs_icon("discord")
        ),
        tags$a(
          href = "https://github.com/nuclearfantasyfootball", target = "_blank",
          title = "GitHub",
          bs_icon("github")
        ),
        # ── Theme toggle button (to the right of GitHub) ──
        uiOutput("theme_toggle", inline = TRUE)
      )
    ),
    id = "topnav",
    selected = "home",
    position = "fixed-top",
    theme = dark_theme # default
  )
)

# ── Server ────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {
  # Countdown timer (kept from single‑page app)
  output$countdown <- renderText({
    invalidateLater(1000, session)

    target_date <- as.POSIXct("2025-08-15 09:00:00", tz = "America/New_York")
    now <- as.POSIXct(Sys.time(), tz = "America/New_York")

    time_remaining <- difftime(target_date, now, units = "secs")
    if (as.numeric(time_remaining) <= 0) {
      return("LAUNCHED!")
    }

    total_seconds <- as.numeric(time_remaining)
    days <- floor(total_seconds / (24 * 3600))
    hours <- floor((total_seconds %% (24 * 3600)) / 3600)
    minutes <- floor((total_seconds %% 3600) / 60)
    seconds <- floor(total_seconds %% 60)

    paste0(days, "D ", hours, "H ", minutes, "M ", seconds, "S")
  })

  # DataTables demo (example to replace
  output$tbl <- renderDT({
    datatable(
      iris,
      extensions = c("Buttons"),
      options = list(
        pageLength = 10,
        dom = "Bfrtip",
        buttons = c("copy", "csv", "excel", "pdf", "print"),
        scrollX = TRUE
      ),
      rownames = FALSE,
      class = "stripe hover order-column"
    )
  })

  # ── Theme switching logic ──
  theme_state <- reactiveVal("dark")

  # Theme toggle icon UI (moon in dark mode, sun in light mode)
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

  # Initialize from localStorage (input$initTheme is sent by inline JS)
  observeEvent(input$initTheme, ignoreInit = TRUE, {
    val <- if (identical(input$initTheme, "light")) "light" else "dark"
    theme_state(val)
    if (val == "light") session$setCurrentTheme(light_theme) else session$setCurrentTheme(dark_theme)
    session$sendCustomMessage("applyThemeClass", val)
  })

  # Toggle when the navbar icon is clicked
  observeEvent(input$toggle_theme, ignoreInit = TRUE, {
    new_val <- if (theme_state() == "dark") "light" else "dark"
    theme_state(new_val)
    if (new_val == "light") {
      session$setCurrentTheme(light_theme)
    } else {
      session$setCurrentTheme(dark_theme)
    }
    session$sendCustomMessage("storeTheme", new_val)
    session$sendCustomMessage("applyThemeClass", new_val)
  })

  # Extra mobile CSS tweaks for small screens
  observe({
    insertUI(
      selector = "head",
      where = "beforeEnd",
      ui = tags$style(HTML("
        @media (max-width: 400px) {
          .hero-section { min-height: 100vh; height: auto; }
          .hero-title-nuclear-minimal { font-size: 2.2rem !important; font-weight: 700 !important; letter-spacing: 0; }
        }
      "))
    )
  })
}

# ── App ───────────────────────────────────────────────────────────────────────
shinyApp(ui, server)
