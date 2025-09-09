# =================== NUCLEARFF SHINY APPLICATION ===================
# NuclearFF UI/Server Shiny Application
# Author: Nolan MacDonald
# Description: Multi-page fantasy football application with dark/light themes

# Packages ──────────────────────────────────────────────────────────────────
library(shiny)
library(bslib)
library(DT)
library(htmltools)
library(bsicons)
library(commonmark)

# Helper Functions ──────────────────────────────────────────────────────────
# Render markdown files with error handling
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

# Animated infinity SVG for stats display
nff_infinity_svg <- function(size = 80) {
  height <- round(size * 0.325)
  HTML(sprintf('
    <span class="nff-inf" style="display:inline-block;width:%dpx;height:%dpx;">
      <svg viewBox="0 0 200 80" width="100%%" height="100%%" aria-hidden="true" focusable="false">
        <style>
          @keyframes nff-inf-anim {
            12.5%%  { stroke-dasharray: 42 300;  stroke-dashoffset: -33; }
            43.75%% { stroke-dasharray: 105 300; stroke-dashoffset: -105; }
            100%%   { stroke-dasharray: 3 300;   stroke-dashoffset: -297; }
          }
          .bg {
            fill: none; stroke: currentColor; stroke-width: 4; opacity: .2;
          }
          .outline {
            fill: none; stroke: currentColor; stroke-width: 4;
            stroke-linecap: round; stroke-linejoin: round;
            stroke-dasharray: 3 300;
            animation: nff-inf-anim 3000ms linear infinite;
          }
        </style>
        <path class="bg" pathLength="300"
          d="M100 40
             C 80 10, 40 10, 40 40
             C 40 70, 80 70, 100 40
             C 120 10, 160 10, 160 40
             C 160 70, 120 70, 100 40" />
        <path class="outline" pathLength="300"
          d="M100 40
             C 80 10, 40 10, 40 40
             C 40 70, 80 70, 100 40
             C 120 10, 160 10, 160 40
             C 160 70, 120 70, 100 40" />
      </svg>
    </span>', size, height))
}

# Configuration ─────────────────────────────────────────────────────────────
options(
  shiny.minified = TRUE,
  bslib.precompiled = TRUE,
  bslib.color_contrast_warnings = FALSE
)

# Themes ────────────────────────────────────────────────────────────────────
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

# UI ────────────────────────────────────────────────────────────────────────
ui <- tagList(
  # Head includes: External CSS/JS files
  tags$head(
    # Run before first paint to avoid gray flash
    tags$script(HTML("(function () {
      var pref = (function(){ try { return localStorage.getItem('nff-theme'); } catch(e){ return null; } })() || 'dark';
      var root = document.documentElement;
      root.setAttribute('data-bs-theme', pref);
      root.classList.add(pref === 'light' ? 'nff-light' : 'nff-dark');
    })();")),
    tags$link(rel = "preload", href = "images/nuclearff-launch-smoke.png", as = "image"),
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
    tags$link(rel = "preconnect", href = "https://fonts.gstatic.com", crossorigin = NA),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap"),
    # Link to Google Fonts Montserrat
    tags$link(
      rel = "stylesheet",
      href = "https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&display=swap"
    ),
    tags$link(rel = "stylesheet", href = "css/style.css"),
    tags$script(src = "js/main.js", defer = NA)
  ),
  tags$style(HTML("
      /* Apply Montserrat to navbar */
      .navbar, .navbar-default, .navbar-static-top {
        font-family: 'Montserrat', sans-serif;
        font-weight: 400;
        text-transform: uppercase;
      }

      /* Apply to navbar brand/title */
      .navbar-brand {
        font-family: 'Montserrat', sans-serif;
        font-weight: 400;
      }

      /* Apply to navbar menu items */
      .navbar-nav > li > a {
        font-family: 'Montserrat', sans-serif;
        font-weight: 400;
      }

      /* Optional: Apply Montserrat to entire app */
      body {
        font-family: 'Montserrat', sans-serif;
        font-weight: 400;
      }

      /* Apply to all headers */
      h1, h2, h3, h4, h5, h6 {
        font-family: 'Montserrat', sans-serif;
        font-weight: 800;
      }

      /* Apply to tabs if you have them */
      .nav-tabs > li > a {
        font-family: 'Montserrat', sans-serif;
        font-weight: 400;
      }
    ")),

  # Main navigation
  page_navbar(
    title = tags$a(
      id = "brandHome",
      class = "navbar-brand d-flex align-items-center",
      href = "#",
      `aria-label` = "Go to Home",
      tags$img(
        src = "https://raw.githubusercontent.com/NuclearAnalyticsLab/nuclearff/refs/heads/main/inst/logos/png/nuclearff-2color.png",
        height = 40,
        alt = "Nuclear Fantasy Football"
      )
    ),

    # Home (Launch) ──
    nav_panel(
      "Home",
      value = "home",
      tags$section(
        class = "hero-section hero-minimal",
        tags$div(class = "hero-overlay"),
        tags$div(
          class = "hero-center",
          tags$img(
            src = "https://raw.githubusercontent.com/NuclearAnalyticsLab/nuclearff/refs/heads/main/inst/logos/png/nuclearff-2color.png",
            class = "hero-logo",
            alt = "Nuclear Fantasy Football"
          ),
          tags$div(
            class = "hero-title",
            tags$div(class = "hero-title-main text-focus-in", "NUCLEAR"),
            tags$div(class = "hero-title-sub text-focus-in", "FANTASY FOOTBALL")
          ),
          tags$button(
            id = "cta_view_app",
            type = "button",
            class = "league-nav-btn hero-cta",
            `aria-label` = "Explore the app",
            "EXPLORE"
          )
        )
      )
    ),

    # Leagues Page ──
    nav_panel(
      "Leagues",
      value = "leagues",
      layout_sidebar(
        sidebar = sidebar(
          width = 200,
          class = "leagues-sidebar",
          tags$div(
            class = "league-format-header",
            tags$button(
              class = "league-format-toggle",
              type = "button",
              `data-bs-toggle` = "collapse",
              `data-bs-target` = "#leagueFormatsCollapse",
              `aria-controls` = "leagueFormatsCollapse",
              `aria-expanded` = "true",
              bs_icon("chevron-right", class = "toggle-icon"),
              tags$span(class = "toggle-text", "LEAGUES")
            )
          ),
          tags$div(
            class = "collapse show",
            id = "leagueFormatsCollapse",
            tags$div(
              class = "league-buttons-container",
              actionButton("btn_redraft",
                tags$span(bs_icon("arrow-repeat"), "Redraft"),
                class = "league-nav-btn"
              ),
              actionButton("btn_dynasty",
                tags$span(bs_icon("trophy"), "Dynasty"),
                class = "league-nav-btn"
              ),
              actionButton("btn_chopped",
                tags$span(bs_icon("scissors"), "Chopped"),
                class = "league-nav-btn"
              ),
              actionButton("btn_survivor",
                tags$span(bs_icon("fire"), "Survivor"),
                class = "league-nav-btn"
              )
            )
          )
        ),
        tags$div(
          class = "league-content-section",
          uiOutput("league_content")
        )
      )
    ),

    # Tools ──
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
    nav_spacer(),

    # Right-aligned social links and theme toggle
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
        uiOutput("theme_toggle", inline = TRUE)
      )
    ),
    id = "topnav",
    selected = "home",
    theme = dark_theme,
    navbar_options = navbar_options(position = "fixed-top")
  )
)

# Server ────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {
  # Theme Management ──
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
  observeEvent(input$initTheme, ignoreInit = TRUE, {
    val <- if (identical(input$initTheme, "light")) "light" else "dark"
    theme_state(val)
    if (val == "light") session$setCurrentTheme(light_theme) else session$setCurrentTheme(dark_theme)
    session$sendCustomMessage("applyThemeClass", val)
  })

  # Toggle theme
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

  # DataTables Demo ────────────────────────────────────────────────────────────
  output$tbl <- renderDT({
    datatable(
      iris,
      extensions = c("Buttons"),
      options = list(
        pageLength = 10,
        dom = "Bfrtip",
        buttons = c("copy", "csv", "excel", "pdf", "print"),
        scrollX = TRUE,
        responsive = TRUE,
        order = list(list(0, "asc")),
        columnDefs = list(
          list(targets = "_all", className = "dt-center")
        )
      ),
      rownames = FALSE,
      class = "stripe hover order-column nowrap",
      style = "bootstrap5"
    )
  })

  # Leagues Page Logic ──
  selected_league <- reactiveVal("redraft")

  observeEvent(input$btn_redraft, {
    selected_league("redraft")
    session$sendCustomMessage("updateLeagueButtons", "redraft")
  })

  observeEvent(input$btn_dynasty, {
    selected_league("dynasty")
    session$sendCustomMessage("updateLeagueButtons", "dynasty")
  })

  observeEvent(input$btn_chopped, {
    selected_league("chopped")
    session$sendCustomMessage("updateLeagueButtons", "chopped")
  })

  observeEvent(input$btn_survivor, {
    selected_league("survivor")
    session$sendCustomMessage("updateLeagueButtons", "survivor")
  })

  # Dynamic league content generator
  output$league_content <- renderUI({
    create_league_content(selected_league())
  })

  # Initialize league buttons
  session$onFlushed(function() {
    session$sendCustomMessage("addLeagueButtonHandler", TRUE)
  }, once = TRUE)
}

# League Content Generator Function ──
create_league_content <- function(league) {
  if (league == "redraft") {
    create_redraft_content()
  } else if (league == "dynasty") {
    create_dynasty_content()
  } else if (league == "chopped") {
    create_chopped_content()
  } else {
    create_survivor_content()
  }
}

league_hero_row <- function(logo_src, word) {
  tags$div(
    class = "league-hero-row",
    tags$img(
      src = logo_src,
      alt = paste(word, "logo"),
      class = "hero-logo"
    ),
    tags$span(toupper(word), class = "hero-text")
  )
}

create_redraft_content <- function() {
  tags$div(
    league_hero_row("logos/nuclearff-logo.png", "Redraft"),
    create_stat_cards(
      list("12" = "Active Leagues", "156" = "Total Teams", "$50" = "Avg Buy-in", "89%" = "Return Rate")
    ),
    tags$hr(class = "my-4"),
    create_league_accordion("redraft"),
    create_league_list("redraft", list(
      list(
        name = "Nuclear Football",
        url = "https://sleeper.com/leagues/1240509989819273216",
        logo = "logos/redraft-logo.png",
        status = "FULL",
        details = "10 TEAM | PPR | 3 FLEX"
      )
    ))
  )
}

# Dynasty League Content ──
create_dynasty_content <- function() {
  tags$div(
    league_hero_row("logos/nuclearff-logo.png", "Dynasty"),
    create_stat_cards(
      list("8" = "Active Dynasties", "3.2" = "Avg Years Running", "$75" = "Avg Buy-in", "94%" = "Retention Rate")
    ),
    tags$hr(class = "my-4"),
    create_league_accordion("dynasty"),
    create_league_list("dynasty", list(
      list(
        name = "NUCLEARFF DYNASTY",
        url = "https://sleeper.com/leagues/1190192546172342272",
        logo = "logos/dynasty-logo.png",
        status = "FULL",
        details = "12 TEAM | PPR | SUPERFLEX"
      )
    ))
  )
}

create_chopped_content <- function() {
  tags$div(
    league_hero_row("logos/nuclearff-logo.png", "Chopped"),
    create_stat_cards(
      list("3" = "Active Leagues", "16" = "Teams per League", "Week 9" = "Avg Elimination")
    ),
    tags$hr(class = "my-4"),
    create_league_accordion("chopped"),
    create_league_list("chopped", list(
      list(
        name = "NUCLEARFF GUILLOTINE $10",
        url = "https://sleeper.com/leagues/1240503074590568448",
        logo = "logos/guillotine-logo.png",
        status = "FULL",
        details = "$10 ENTRY | 16 TEAM | PPR | 6PT PASS TD"
      ),
      list(
        name = "NUCLEARFF CHOPPED $10 02",
        url = "https://sleeper.com/leagues/1260089054490275840",
        logo = "logos/guillotine-logo.png",
        status = "FULL",
        details = "$10 ENTRY | 16 TEAM | PPR | 6PT PASS TD"
      ),
      list(
        name = "NUCLEARFF CHOPPED $25",
        url = "https://sleeper.com/leagues/1240503074590568448",
        logo = "logos/guillotine-logo.png",
        status = "FULL",
        details = "$25 ENTRY | 16 TEAM | PPR | 6PT PASS TD"
      )
    ))
  )
}

create_survivor_content <- function() {
  tags$div(
    league_hero_row("logos/nuclearff-logo.png", "Survivor"),
    create_stat_cards(list("W" = "Winning is survival", "infinite" = "Teams")),
    tags$hr(class = "my-4"),
    create_league_accordion("survivor"),
    create_league_list("survivor", list(
      list(
        name = "|NUCLEARFF Survivor (Pick 'Em) 2025",
        url = "https://sleeper.com/leagues/1256760468719030272",
        logo = "logos/survivor-logo.png",
        status = "OPEN",
        status_class = "success",
        details = "$10 ENTRY | PICK 'EM"
      )
    ))
  )
}

# Helper Functions for League Content ──
create_stat_cards <- function(stats) {
  tags$div(
    class = "league-stats-grid",
    lapply(names(stats), function(name) {
      label <- stats[[name]]
      value_node <- if (tolower(name) %in% c("infinite", "infinity", "∞")) {
        tags$div(class = "stat-value", nff_infinity_svg(size = 180))
      } else {
        tags$div(class = "stat-value", name)
      }
      tags$div(
        class = "stat-card",
        value_node,
        tags$div(class = "stat-label", label)
      )
    })
  )
}

create_league_accordion <- function(type) {
  card(
    card_header(tags$h5("League Configuration", class = "mb-0")),
    card_body(
      accordion(
        id = paste0(type, "_accordion"),
        class = "league-accordion",
        accordion_panel(
          "OVERVIEW",
          icon = bs_icon("chevron-double-right"),
          md_file(sprintf("www/md/%s/%s_overview.md", type, type))
        ),
        accordion_panel(
          "Roster",
          icon = bs_icon("person-fill-gear"),
          md_file(sprintf("www/md/%s/%s_roster.md", type, type))
        ),
        accordion_panel(
          "Draft",
          icon = bs_icon("table"),
          md_file(sprintf("www/md/%s/%s_draft.md", type, type))
        ),
        accordion_panel(
          "Scoring",
          icon = bs_icon("clipboard2-data"),
          md_file(sprintf("www/md/%s/%s_scoring.md", type, type))
        ),
        accordion_panel(
          "Transactions",
          icon = bs_icon("wallet2"),
          md_file(sprintf("www/md/%s/%s_transactions.md", type, type))
        )
      )
    ),
    class = "mb-4"
  )
}

create_league_list <- function(type, leagues) {
  title <- switch(type,
    "redraft" = "NUCLEARFF REDRAFT LEAGUES",
    "dynasty" = "NUCLEARFF DYNASTY LEAGUES",
    "guillotine" = "NUCLEARFF CHOPPED/GUILLOTINE LEAGUES",
    "chopped" = "NUCLEARFF CHOPPED/GUILLOTINE LEAGUES",
    "survivor" = "NUCLEARFF SURVIVOR LEAGUES"
  )

  card(
    card_header(title),
    card_body(
      tags$div(
        class = "list-group",
        lapply(leagues, function(league) {
          # Handle status_class with simple if-else
          status_class <- if (!is.null(league$status_class)) {
            league$status_class
          } else {
            switch(league$status,
              "FULL"    = "danger",
              "STARTUP" = "success",
              "ORPHAN"  = "warning",
              "info"
            )
          }

          is_full <- identical(league$status, "FULL")

          tags$a(
            href = league$url,
            class = paste(
              "list-group-item list-group-item-action league-item",
              if (is_full) "is-full" else ""
            ),
            `data-bs-toggle` = if (is_full) "tooltip" else NULL,
            `data-bs-title` = if (is_full) "This league is full" else NULL,
            `data-bs-placement` = if (is_full) "top" else NULL,
            `data-bs-container` = if (is_full) "body" else NULL,
            `aria-disabled` = if (is_full) "true" else NULL,
            tabindex = if (is_full) "0" else NULL,
            tags$img(src = league$logo, alt = league$name, class = "league-logo"),
            tags$div(
              class = "league-copy w-100",
              tags$div(
                class = "d-flex justify-content-between align-items-center",
                tags$h6(league$name, class = "league-title mb-0"),
                tags$small(tags$span(class = paste("badge", paste0("bg-", status_class)), league$status))
              ),
              tags$p(league$details, class = "league-sub mb-0")
            )
          )
        })
      )
    )
  )
}

# App ──
shinyApp(ui, server)
