# NuclearFF Full Application with Enhanced Leagues Page

# ── Packages ───────────────────────────────────────────────────────────────────
library(shiny)
library(bslib)
library(DT)
library(htmltools)
library(bsicons)
library(commonmark)

# ── Helper Functions ──────────────────────────────────────────────────────────
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

# ── Configuration ─────────────────────────────────────────────────────────────
options(
  shiny.minified = TRUE,
  bslib.precompiled = TRUE,
  bslib.color_contrast_warnings = FALSE
)

# ── Themes ────────────────────────────────────────────────────────────────────
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
  # Head includes: External CSS/JS files
  tags$head(
    tags$link(rel = "preload", href = "images/football-stadium-bg.jpg", as = "image"),
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
    tags$link(rel = "preconnect", href = "https://fonts.gstatic.com", crossorigin = NA),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap"),
    tags$link(rel = "stylesheet", href = "css/style.css"),
    tags$script(src = "js/main.js", defer = NA)
  ),

  # Main navigation
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
          tags$p(class = "hero-subtitle", "Nuclear Fantasy Football"),
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

    # ── Leagues Page ──
    nav_panel(
      "Leagues",
      value = "leagues",
      layout_sidebar(
        sidebar = sidebar(
          width = 200,
          class = "leagues-sidebar",
          tags$h5("League Types", class = "mb-2"),
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
          ),
          actionButton("btn_survivor",
            tags$span(bs_icon("fire"), "Survivor"),
            class = "league-nav-btn"
          )
        ),
        tags$div(
          class = "league-content-section",
          uiOutput("league_content")
        )
      )
    ),

    # ── Tools ──
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

# ── Server ────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {
  # ── Countdown Timer ──
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

  # ── DataTables Demo ──
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

  observeEvent(input$btn_survivor, {
    selected_league("survivor")
    session$sendCustomMessage("updateLeagueButtons", "survivor")
  })

  # Dynamic league content generator
  output$league_content <- renderUI({
    create_league_content(selected_league())
  })

  # ── Theme Management ──
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

  # Initialize league buttons
  session$onFlushed(function() {
    session$sendCustomMessage("addLeagueButtonHandler", TRUE)
  }, once = TRUE)
}

# ── League Content Generator Function ──
create_league_content <- function(league) {
  if (league == "redraft") {
    create_redraft_content()
  } else if (league == "dynasty") {
    create_dynasty_content()
  } else if (league == "guillotine") {
    create_guillotine_content()
  } else {
    create_survivor_content()
  }
}

# ── Redraft League Content ──
create_redraft_content <- function() {
  tags$div(
    tags$h2(bs_icon("arrow-repeat"), "REDRAFT LEAGUES", class = "mb-4"),
    tags$p(
      class = "lead",
      "Traditional season-long fantasy football. Draft a new team each year and compete for the championship!"
    ),
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
        details = "$100 Entry | 10 teams | PPR | Drafting Sep. 1st, 2025"
      )
    ))
  )
}

# ── Dynasty League Content ──
create_dynasty_content <- function() {
  tags$div(
    tags$h2(bs_icon("trophy"), "DYNASTY LEAGUES", class = "mb-4"),
    tags$p(
      class = "lead",
      "Build a franchise for years to come. Keep your players, trade draft picks, and create a lasting legacy!"
    ),
    create_stat_cards(
      list("8" = "Active Dynasties", "3.2" = "Avg Years Running", "$75" = "Avg Buy-in", "94%" = "Retention Rate")
    ),
    tags$hr(class = "my-4"),
    create_league_accordion("dynasty"),
    create_league_list("dynasty", list(
      list(
        name = "NUCLEAR DYNASTY",
        url = "https://sleeper.com/leagues/1190192546172342272",
        logo = "logos/dynasty-logo.png",
        status = "FULL",
        details = "$50 ENTRY | 12 TEAM | SUPERFLEX"
      ),
      list(
        name = "NUCLEAR DYNASTY 02",
        url = "https://sleeper.com/leagues/1190192546172342272",
        logo = "logos/dynasty-logo-2.png",
        status = "STARTUP",
        details = "$50 ENTRY | 12 TEAM | SUPERFLEX | TEP"
      ),
      list(
        name = "NUCLEAR DYNASTY 03",
        url = "https://sleeper.com/leagues/1190192546172342272",
        logo = "logos/dynasty-logo-3.png",
        status = "ORPHAN",
        details = "$50 ENTRY | 12 TEAM | SUPERFLEX"
      )
    ))
  )
}

# ── Guillotine League Content ──
create_guillotine_content <- function() {
  tags$div(
    tags$h2(bs_icon("scissors"), "GUILLOTINE LEAGUES", class = "mb-4"),
    tags$p(
      class = "lead",
      "Survive or be eliminated! Each week, the lowest scoring team is cut and their players hit waivers."
    ),
    create_stat_cards(
      list("3" = "Active Leagues", "16" = "Teams per League", "Week 9" = "Avg Elimination")
    ),
    tags$hr(class = "my-4"),
    create_league_accordion("guillotine"),
    create_league_list("guillotine", list(
      list(
        name = "NUCLEARFF $10 GUILLOTINE",
        url = "https://sleeper.com/leagues/1240503074590568448",
        logo = "logos/guillotine-logo.png",
        status = "FULL",
        details = "$10 ENTRY | 16 TEAM | PPR | 6-PT PASS TD"
      ),
      list(
        name = "NUCLEARFF $10 GUILLOTINE 02",
        url = "https://sleeper.com/leagues/1260089054490275840",
        logo = "logos/guillotine-logo.png",
        status = "FULL",
        details = "$10 ENTRY | 16 TEAM | PPR | 6-PT PASS TD"
      ),
      list(
        name = "NUCLEARFF $25 GUILLOTINE",
        url = "https://sleeper.com/leagues/1240503074590568448",
        logo = "logos/guillotine-logo.png",
        status = "FULL",
        details = "$25 ENTRY | 16 TEAM | PPR | 6-PT PASS TD"
      )
    ))
  )
}

# ── Survivor League Content ──
create_survivor_content <- function() {
  tags$div(
    tags$h2(bs_icon("fire"), "SURVIVOR LEAGUES", class = "mb-4"),
    tags$p(
      class = "lead",
      "Pick a team to win each week to survive. Survival comes at a cost, your winning team cannot be chosen again for the remainder of the season. Choose wisely."
    ),
    create_stat_cards(
      list("W" = "Winning is survival", "infinite" = "Teams")
    ),
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

# ── Helper Functions for League Content ──
create_stat_cards <- function(stats) {
  tags$div(
    class = "league-stats-grid",
    lapply(names(stats), function(value) {
      tags$div(
        class = "stat-card",
        tags$div(class = "stat-value", value),
        tags$div(class = "stat-label", stats[[value]])
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
    "guillotine" = "NUCLEARFF GUILLOTINE LEAGUES",
    "survivor" = "NUCLEARFF SURVIVOR LEAGUES"
  )

  card(
    card_header(title),
    card_body(
      tags$div(
        class = "list-group",
        lapply(leagues, function(league) {
          status_class <- league$status_class %||% switch(league$status,
            "FULL" = "danger",
            "STARTUP" = "success",
            "ORPHAN" = "warning",
            "info"
          )

          tags$a(
            href = league$url,
            class = "list-group-item list-group-item-action league-item",
            tags$img(
              src = league$logo,
              alt = league$name,
              class = "league-logo"
            ),
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

# ── App ──
shinyApp(ui, server)
