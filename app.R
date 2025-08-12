# NuclearFF Full Application with Enhanced Leagues Page

# ── Packages ───────────────────────────────────────────────────────────────────
library(shiny)
library(bslib)
library(DT)
library(htmltools)
library(bsicons)
library(commonmark) # install.packages("commonmark") if needed

md_file <- function(path) {
  if (!file.exists(path)) {
    return(tags$div(
      class = "text-danger small",
      sprintf("Markdown file not found: %s (wd: %s)", path, getwd())
    ))
  }
  txt <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  HTML(commonmark::markdown_html(txt))
}

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

      /* ── Leagues Page Styles ── */
      .leagues-sidebar {
        padding: 1rem;
      }

      /* Make league nav buttons center consistently */
      .league-nav-btn {
        width: 100%;
        /* remove the left align */
        /* text-align: left; */
        display: flex;
        justify-content: center;   /* horizontally center icon + text */
        align-items: center;       /* vertically center */
        font-weight: 500;
        margin-bottom: 0.5rem;
        transition: all 0.3s ease;
      }

      /* Inner span */
      .league-nav-btn span {
        display: inline-flex;
        align-items: center;
        justify-content: center;   /* center contents within span */
        gap: 0.5rem;
        width: 100%;               /* optional: makes centering robust */
      }

      /* Make sure icons don't collapse */
      .league-nav-btn svg {
        width: 1.1em;
        height: 1.1em;
        flex: 0 0 auto;
      }

      .nff-dark .league-nav-btn {
        background-color: rgba(206, 15, 160, 0.1);
        border-color: #ce0fa0;
        color: #ce0fa0;
      }

      .nff-dark .league-nav-btn:hover,
      .nff-dark .league-nav-btn.active {
        background-color: #ce0fa0;
        color: #fff;
      }

      .nff-light .league-nav-btn {
        background-color: rgba(15, 160, 206, 0.1);
        border-color: #0fa0ce;
        color: #0fa0ce;
      }

      .nff-light .league-nav-btn:hover,
      .nff-light .league-nav-btn.active {
        background-color: #0fa0ce;
        color: #fff;
      }

      .nff-dark .accordion-button {
        background-color: rgba(255, 255, 255, 0.05);
        color: #e9ecef;
      }

      .nff-dark .accordion-button:not(.collapsed) {
        background-color: rgba(206, 15, 160, 0.2);
        color: #ce0fa0;
      }

      .nff-light .accordion-button {
        background-color: rgba(0, 0, 0, 0.03);
        color: #212529;
      }

      .nff-light .accordion-button:not(.collapsed) {
        background-color: rgba(15, 160, 206, 0.2);
        color: #0fa0ce;
      }

      .league-content-section {
        padding: 1.5rem;
      }

      .league-stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
        gap: 1rem;
        margin-top: 1rem;
      }

      .stat-card {
        padding: 1rem;
        border-radius: 0.5rem;
        text-align: center;
        transition: transform 0.2s;
      }

      .stat-card:hover {
        transform: translateY(-2px);
      }

      .nff-dark .stat-card {
        background-color: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(206, 15, 160, 0.3);
      }

      .nff-light .stat-card {
        background-color: rgba(0, 0, 0, 0.02);
        border: 1px solid rgba(15, 160, 206, 0.3);
      }

      .stat-value {
        font-size: 2rem;
        font-weight: bold;
      }

      .nff-dark .stat-value {
        color: #ce0fa0;
      }

      .nff-light .stat-value {
        color: #0fa0ce;
      }

      .stat-label {
        font-size: 0.875rem;
        opacity: 0.8;
        margin-top: 0.25rem;
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

    # ── Leagues Page with Sidebar ──
    nav_panel(
      "Leagues",
      value = "leagues",
      layout_sidebar(
        sidebar = sidebar(
          width = 200,
          class = "leagues-sidebar",

          # League Type Navigation
          tags$h5("League Types", class = "mb-3"),
          tags$p("LEAGUE FORMAT", class = "text-muted small mb-2"),
          actionButton("btn_redraft",
            tags$span(bs_icon("arrow-repeat"), "Redraft"),
            class = "league-nav-btn"
          ),
          actionButton("btn_dynasty",
            tags$span(bs_icon("trophy"), "Dynasty"),
            class = "league-nav-btn"
          ),
          actionButton("btn_guillotine",
            tags$span(bs_icon("scissors"), "Guillotine"),
            class = "league-nav-btn"
          )
        ),

        # Main content area
        tags$div(
          class = "league-content-section",
          uiOutput("league_content")
        )
      )
    ),

    # ── Data (placeholder using DT DataTables demo style) ──
    nav_panel(
      "Tools",
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
    theme = dark_theme, # default
    navbar_options = navbar_options(position = "fixed-top")
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

  # DataTables demo (example to replace)
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

  # ── Leagues Page Logic ──
  selected_league <- reactiveVal("redraft")

  # Update button styles when clicked
  observeEvent(input$btn_redraft, {
    selected_league("redraft")
    session$sendCustomMessage("updateLeagueButtons", "redraft")
  })

  observeEvent(input$btn_dynasty, {
    selected_league("dynasty")
    session$sendCustomMessage("updateLeagueButtons", "dynasty")
  })

  observeEvent(input$btn_guillotine, {
    selected_league("guillotine")
    session$sendCustomMessage("updateLeagueButtons", "guillotine")
  })

  # Dynamic main content based on selected league
  output$league_content <- renderUI({
    league <- selected_league()

    # REDRAFT -------------------------------------------------------------
    if (league == "redraft") {
      tags$div(
        tags$h2(bs_icon("arrow-repeat"), "REDRAFT LEAGUES", class = "mb-4"),
        tags$p(
          class = "lead",
          "Traditional season-long fantasy football. Draft a new team each year and compete for the championship!"
        ),
        tags$div(
          class = "league-stats-grid",
          tags$div(
            class = "stat-card",
            tags$div(class = "stat-value", "12"),
            tags$div(class = "stat-label", "Active Leagues")
          ),
          tags$div(
            class = "stat-card",
            tags$div(class = "stat-value", "156"),
            tags$div(class = "stat-label", "Total Teams")
          ),
          tags$div(
            class = "stat-card",
            tags$div(class = "stat-value", "$50"),
            tags$div(class = "stat-label", "Avg Buy-in")
          ),
          tags$div(
            class = "stat-card",
            tags$div(class = "stat-value", "89%"),
            tags$div(class = "stat-label", "Return Rate")
          )
        ),
        tags$hr(class = "my-4"),
        card(
          card_header(tags$h5("League Configuration", class = "mb-0")),
          card_body(
            accordion(
              id = "redraft_accordion",
              class = "league-accordion",
              accordion_panel(
                "Overview",
                icon = bs_icon("chevron-double-right"),
                md_file("www/md/redraft/redraft_overview.md")
              ),
              accordion_panel(
                "Roster",
                icon = bs_icon("gear"),
                md_file("www/md/redraft/redraft_roster.md")
              ),
              accordion_panel(
                "Draft",
                icon = bs_icon("gear"),
                md_file("www/md/redraft/redraft_draft.md")
              ),
              accordion_panel(
                "Scoring",
                icon = bs_icon("gear"),
                md_file("www/md/redraft/redraft_scoring.md")
              ),
              accordion_panel(
                "Transactions",
                icon = bs_icon("gear"),
                md_file("www/md/redraft/redraft_transactions.md")
              )
            )
          ),
          class = "mb-4"
        ),
        card(
          card_header("NUCLEARFF REDRAFT LEAGUES"),
          card_body(
            # tags$p("NUCLEARFF REDRAFT LEAGUES:"),
            tags$div(
              class = "list-group",
              tags$a(
                href = "https://sleeper.com/leagues/1240509989819273216",
                class = "list-group-item list-group-item-action",
                tags$div(
                  class = "d-flex w-100 justify-content-between",
                  tags$h6("Nuclear Football", class = "mb-1"),
                  tags$small(tags$span(class = "badge bg-danger", "FULL"))
                ),
                tags$p("$100 Entry | 10 teams | PPR | Drafting Sep. 1st, 2025",
                  class = "mb-1"
                )
              )
            )
          )
        )
      )
      # DYNASTY -------------------------------------------------------------
    } else if (league == "dynasty") {
      tags$div(
        tags$h2(bs_icon("trophy"), "DYNASTY LEAGUES", class = "mb-4"),
        tags$p(
          class = "lead",
          "Build a franchise for years to come. Keep your players, trade draft picks, and create a lasting legacy!"
        ),
        tags$div(
          class = "league-stats-grid",
          tags$div(
            class = "stat-card",
            tags$div(class = "stat-value", "8"),
            tags$div(class = "stat-label", "Active Dynasties")
          ),
          tags$div(
            class = "stat-card",
            tags$div(class = "stat-value", "3.2"),
            tags$div(class = "stat-label", "Avg Years Running")
          ),
          tags$div(
            class = "stat-card",
            tags$div(class = "stat-value", "$75"),
            tags$div(class = "stat-label", "Avg Buy-in")
          ),
          tags$div(
            class = "stat-card",
            tags$div(class = "stat-value", "94%"),
            tags$div(class = "stat-label", "Retention Rate")
          )
        ),
        tags$hr(class = "my-4"),
        card(
          card_header(tags$h5("League Configuration", class = "mb-0")),
          card_body(
            accordion(
              id = "dynasty_accordion",
              class = "league-accordion",
              accordion_panel(
                "Overview",
                icon = bs_icon("chevron-double-right"),
                md_file("www/md/dynasty/dynasty_overview.md")
              ),
              accordion_panel(
                "Roster",
                icon = bs_icon("gear"),
                md_file("www/md/dynasty/dynasty_roster.md")
              ),
              accordion_panel(
                "Draft",
                icon = bs_icon("gear"),
                md_file("www/md/dynasty/dynasty_draft.md")
              ),
              accordion_panel(
                "Scoring",
                icon = bs_icon("gear"),
                md_file("www/md/dynasty/dynasty_scoring.md")
              ),
              accordion_panel(
                "Transactions",
                icon = bs_icon("gear"),
                md_file("www/md/dynasty/dynasty_transactions.md")
              )
            )
          ),
          class = "mb-4"
        ),
        card(
          card_header("NUCLEARFF DYNASTY LEAGUES"),
          card_body(
            tags$p("Take over an orphan team or join a startup:"),
            tags$div(
              class = "list-group",
              tags$a(
                href = "https://sleeper.com/leagues/1190192546172342272",
                class = "list-group-item list-group-item-action",
                tags$div(
                  class = "d-flex w-100 justify-content-between",
                  tags$h6("NUCLEARFF DYNASTY", class = "mb-1"),
                  tags$small(tags$span(class = "badge bg-danger", "FULL"))
                ),
                tags$p("$50 ENTRY | 12 TEAM | SUPERFLEX | TEP",
                  class = "mb-1"
                )
              ),
              tags$a(
                href = "https://sleeper.com/leagues/1190192546172342272",
                class = "list-group-item list-group-item-action",
                tags$div(
                  class = "d-flex w-100 justify-content-between",
                  tags$h6("NUCLEARFF DYNASTY 02", class = "mb-1"),
                  tags$small(tags$span(class = "badge bg-success", "STARTUP"))
                ),
                tags$p("$50 ENTRY | 12 TEAM | SUPERFLEX", class = "mb-1")
              ),
              tags$a(
                href = "https://sleeper.com/leagues/1190192546172342272",
                class = "list-group-item list-group-item-action",
                tags$div(
                  class = "d-flex w-100 justify-content-between",
                  tags$h6("NUCLEARFF DYNASTY 03", class = "mb-1"),
                  tags$small(tags$span(class = "badge bg-warning", "ORPHAN"))
                ),
                tags$p("$50 ENTRY | 12 TEAM | SUPERFLEX | TEP",
                  class = "mb-1"
                )
              )
            )
          )
        )
      )
      # GUILLOTINE -------------------------------------------------------------
    } else {
      tags$div(
        tags$h2(bs_icon("scissors"), "GUILLOTINE LEAGUES", class = "mb-4"),
        tags$p(
          class = "lead",
          "Survive or be eliminated! Each week, the lowest scoring team is cut and their players hit waivers."
        ),
        tags$div(
          class = "league-stats-grid",
          tags$div(
            class = "stat-card",
            tags$div(class = "stat-value", "4"),
            tags$div(class = "stat-label", "Active Leagues")
          ),
          tags$div(
            class = "stat-card",
            tags$div(class = "stat-value", "17"),
            tags$div(class = "stat-label", "Teams per League")
          ),
          tags$div(
            class = "stat-card",
            tags$div(class = "stat-value", "Week 9"),
            tags$div(class = "stat-label", "Avg Elimination")
          ),
          tags$div(
            class = "stat-card",
            tags$div(class = "stat-value", "$40"),
            tags$div(class = "stat-label", "Avg Buy-in")
          )
        ),
        tags$hr(class = "my-4"),
        card(
          card_header(tags$h5("League Configuration", class = "mb-0")),
          card_body(
            accordion(
              id = "guillotine_accordion",
              class = "league-accordion",
              accordion_panel(
                "Overview",
                icon = bs_icon("chevron-double-right"),
                md_file("www/md/guillotine/guillotine_overview.md")
              ),
              accordion_panel(
                "Roster",
                icon = bs_icon("gear"),
                md_file("www/md/guillotine/guillotine_roster.md")
              ),
              accordion_panel(
                "Draft",
                icon = bs_icon("gear"),
                md_file("www/md/guillotine/guillotine_draft.md")
              ),
              accordion_panel(
                "Scoring",
                icon = bs_icon("gear"),
                md_file("www/md/guillotine/guillotine_scoring.md")
              ),
              accordion_panel(
                "Transactions",
                icon = bs_icon("gear"),
                md_file("www/md/guillotine/guillotine_transactions.md")
              )
            )
          ),
          class = "mb-4"
        ),
        card(
          card_header("NUCLEARFF GUILLOTINE LEAGUES"),
          card_body(
            tags$p("Test your survival skills in these elimination leagues:"),
            tags$div(
              class = "list-group",
              # NUCLEARFF $10 GUILLOTINE
              tags$a(
                href = "https://sleeper.com/leagues/1241932113842798592",
                class = "list-group-item list-group-item-action",
                tags$div(
                  class = "d-flex w-100 justify-content-between",
                  tags$h6("NUCLEARFF $10 GUILLOTINE", class = "mb-1"),
                  tags$small(tags$span(class = "badge bg-danger", "FULL"))
                ),
                tags$p("$10 ENTRY | 16 TEAM | PPR | 6-PT PASS TD", class = "mb-1 text-muted")
              ),
              # NUCLEARFF $10 GUILLOTINE 02
              tags$a(
                href = "https://sleeper.com/leagues/1260089054490275840",
                class = "list-group-item list-group-item-action",
                tags$div(
                  class = "d-flex w-100 justify-content-between",
                  tags$h6("NUCLEARFF $10 GUILLOTINE 02", class = "mb-1"),
                  tags$small(tags$span(class = "badge bg-warning", "5 SPOTS LEFT"))
                ),
                tags$p("$10 ENTRY | 16 TEAM | PPR | 6-PT PASS TD", class = "mb-1 text-muted")
              ),
              # NUCLEARFF $10 GUILLOTINE 02
              tags$a(
                href = "https://sleeper.com/leagues/1241932113842798592",
                class = "list-group-item list-group-item-action",
                tags$div(
                  class = "d-flex w-100 justify-content-between",
                  tags$h6("NUCLEARFF $25 GUILLOTINE", class = "mb-1"),
                  tags$small(tags$span(class = "badge bg-danger", "FULL"))
                ),
                tags$p("$25 ENTRY | 16 TEAM | PPR | 6-PT PASS TD", class = "mb-1 text-muted")
              )
            )
          )
        )
      )
    }
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

  # Add JavaScript for button highlighting
  observe({
    session$sendCustomMessage("updateLeagueButtons", selected_league())
  })

  # Custom message handler for league button updates
  session$onFlushed(function() {
    session$sendCustomMessage("addLeagueButtonHandler", TRUE)
  }, once = TRUE)
}

# ── App ───────────────────────────────────────────────────────────────────────
shinyApp(ui, server)
