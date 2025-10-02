# NUCLEARFF Home Page Module ---------------------------------------------------

#' Home Page Module Overview (UI + Server)
#'
#' @title Home Page Module UI and Server
#' @description
#' A pair of Shiny module functions that render the animated home/landing page
#' for the Nuclear Fantasy Football application and initialize related server-side
#' behaviors. The UI is composed of four full-viewport sections (Hero, Welcome,
#' Development, Community) with a reusable scroll indicator and a call-to-action
#' button. The server logic wires up one-time initialization hooks, custom
#' JavaScript events, and user-interaction logging.
#'
#' @details
#' The UI function, `home_page_ui()`, delegates the construction of each
#' section to small, focused helpers (e.g., `hero_section()`). This keeps the
#' markup readable and maintains separation of concerns. The module expects a
#' few client-side JavaScript helpers to exist (`window.gotoSection`,
#' `startTypingAnimation`), and a custom `electrified_button()` widget to be
#' available at runtime.
#'
#' The server function, `home_page_server()`, performs three tasks once the
#' UI has been flushed to the client: (1) notifies the app that the `home` tab is
#' active, (2) initializes the animated "electrified" CTA button, and
#' (3) triggers a typing animation in the Development section. It also exposes a
#' minimal reactive API for downstream modules to react to page state.
#'
#' @section Accessibility:
#' Scroll indicators include ARIA labels and keyboard focusability. Ensure that
#' the fixed-position headings still produce a logical reading order and that any
#' animations (typing/electrified effects) respect user reduced-motion settings
#' if you add them in CSS/JS.
#'
#' @seealso [home_page_ui()], [home_page_server()], [logEvent()]
#'
#' @name home_module
#' @keywords module
#' @author Nolan MacDonald
NULL

# =============================
# UI MODULE
# =============================

#' Home Page Module UI
#'
#' @title Home Page Module UI
#' @description Builds the home/landing page made of four scrollable sections and
#' a persistent scroll indicator. Composes semantic sections and defers complex
#' widgets to helper functions to keep the top-level layout tidy.
#'
#' @param id Character string. Module namespace ID used to uniquely scope all
#'   element IDs and input bindings within the module.
#'
#' @return A `shiny.tag` (HTML) tree representing the landing page UI.
#' @export
home_page_ui <- function(id) {
    ns <- NS(id) # namespace ensures unique IDs when the module is reused

    # Use a container with CSS-driven scroll snapping. The per-section helpers
    # keep this function short and maintainable.
    tags$div(
        class = "scroll-container",
        id = ns("scroll_container"),
        hero_section(ns),
        welcome_section(ns),
        development_section(ns),
        community_section(ns)
    )
}

#' Hero Section
#'
#' @title Hero Section UI Helper
#' @description Constructs the top-of-page hero section containing the app title
#' and a prominent CTA button that advances to the next section. Relies on
#' `window.gotoSection` to exist client-side.
#'
#' @param ns A namespace function created by [shiny::NS()].
#' @return A `shiny.tag` with the hero section markup.
hero_section <- function(ns) {
    tags$section(
        class = "first nff-backdrop",
        tags$div(
            class = "outer",
            tags$div(
                class = "inner",
                tags$div(
                    class = "bg",
                    # Primary heading with a deliberate line break for visual rhythm
                    tags$h2(
                        class = "section-heading",
                        "NUCLEAR",
                        tags$br(),
                        "FANTASY FOOTBALL"
                    ),
                    # Animated CTA. The small timeout allows CSS/JS to settle before scroll.
                    electrified_button(
                        id = ns("dashboard_action_btn"),
                        text = "EXPLORE",
                        position = "bottom-right",
                        onclick = "setTimeout(() => window.gotoSection(1), 50); return false;"
                    ),
                    # Visual affordance that hints at vertical navigation
                    create_scroll_indicator(ns, "1")
                )
            )
        )
    )
}

#' Welcome Section
#'
#' @title Welcome Section UI Helper
#' @description A secondary section that showcases a glass-effect card with short
#' copy. Uses `bslib::card()` so the look-and-feel remains consistent with the
#' Bootstrap theme.
#'
#' @param ns A namespace function created by [shiny::NS()].
#' @return A `shiny.tag` with the welcome section markup.
welcome_section <- function(ns) {
    tags$section(
        class = "second nff-backdrop",
        tags$div(
            class = "outer",
            tags$div(
                class = "inner",
                tags$div(
                    class = "bg",
                    tags$div(
                        class = "section-block",
                        # The duplicated text is used to drive a CSS chrome/glitch effect
                        tags$h2(
                            class = "section-heading chrome",
                            `data-text` = "Every Decision Sets Off a Chain Reaction",
                            "Every Decision Sets Off a Chain Reaction"
                        ),
                        bslib::card(
                            class = "glass-effect section-card",
                            bslib::card_body(
                                tags$h4(
                                    tags$br(),
                                    "Reach critical mass.",
                                    tags$br(),
                                    "Create unstoppable momentum."
                                ),
                                # Keep copy short to avoid overflow on smaller devices
                                tags$p(
                                    "Fantasy football is a game of cascading consequences.",
                                    tags$br(),
                                    "Every decision you make from draft day to championship week fuels a chain reaction across your roster, league, and season.",
                                    tags$br(),
                                    tags$br()
                                )
                            )
                        ),
                        create_scroll_indicator(ns, "2")
                    )
                )
            )
        )
    )
}

#' Development Section
#'
#' @title Development Section UI Helper
#' @description A tabbed section pinned in view that presents multiple
#' development workstreams. The title uses a typing animation triggered by the
#' server once the UI is ready.
#'
#' @param ns A namespace function created by [shiny::NS()].
#' @return A `shiny.tag` with the development section markup.
development_section <- function(ns) {
    tags$section(
        class = "third nff-backdrop",
        tags$div(
            class = "outer",
            tags$div(
                class = "inner",
                tags$div(
                    class = "bg",
                    # Fixed-position title keeps orientation as tabs change
                    tags$h2(
                        class = "development-title typing-animation",
                        style = "position: fixed; left: 5%; transform: none; z-index: 100; --steps: 12;",
                        "DEVELOPMENT"
                    ),
                    tags$div(
                        class = "development-card-container",
                        bslib::card(
                            class = "glass-effect section-card no-tilt centered-nav-pills",
                            style = "height: 100%; overflow-y: auto;",
                            # navset_pill groups related workstreams; each tab is a small helper
                            navset_pill(
                                id = ns("dev_tabs"),
                                development_overview(),
                                development_sena(),
                                development_otis(),
                                development_gerald()
                            )
                        )
                    ),
                    create_scroll_indicator(ns, "3")
                )
            )
        )
    )
}

#' Development Overview Tab
#'
#' @title Development Overview Tab
#' @description A high-level overview for the Development section.
#' @return A `nav_panel` representing the overview tab.
development_overview <- function() {
    nav_panel(
        title = "OVERVIEW",
        icon = icon("code"),
        tags$div(
            class = "p-3",
            # Title and logo container with content in right column
            tags$div(
                style = "display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; align-items: start; min-height: 100px;",
                # LEFT COLUMN: Logo only
                tags$a(
                    href = "https://github.com/nuclearfantasyfootball",
                    target = "_blank",
                    class = "text-decoration-none",
                    style = "display: block; width: 100%; align-self: start;",
                    tags$img(
                        src = "logos/packages/NuclearFF-Packages.png",
                        alt = "NUCLEARFF R Packages",
                        style = "width: 100%; height: auto; object-fit: contain; display: block; vertical-align: top;"
                    )
                ),
                # RIGHT COLUMN: Title AND content together
                tags$div(
                    tags$h4("OVERVIEW", class = "mb-0"),
                    tags$div(
                        style = "margin-top: 0.5rem;", # spacing below the title

                        # README content (text only, no PNG logo)
                        tags$p("Nuclear Fantasy Football (NUCLEARFF) utilizes several packages for data management and analyses."),
                        tags$p("The packages are developed for data wrangling and analyses of college football prospects, the National Football League (NFL), and fantasy football."),
                        tags$p("The three packages that form the framework of NUCLEARFF are currently in the early stages of development:"),
                        tags$ul(
                            tags$li(
                                tags$strong("OTIS"), " – Optimized Toolkit Interfacing Sleeper. Provides functions for pulling, parsing, and analyzing Sleeper fantasy football data."
                            ),
                            tags$li(
                                tags$strong("SENA"), " – Shiny Essentials for NuclearFF Applications. Contains Shiny modules and utilities for rapidly building interactive fantasy football dashboards and applications."
                            ),
                            tags$li(
                                tags$strong("GERALD"), " – Gridiron Engine for Research, Analytics, and League Data. Focuses on statistical models, predictive analytics, and advanced insights using NFL and fantasy football data."
                            )
                        ),
                        tags$p("Together, these packages create a modular and extensible framework for fantasy football analytics within the Nuclear Fantasy Football ecosystem.")
                    )
                )
            )
        )
    )
}


#' Development SENA Tab
#'
#' @title Development SENA Tab
#' @description A tab panel for the SENA workstream; replace placeholder copy
#' with real content as the feature evolves.
#' @return A `nav_panel` representing the SENA tab.
development_sena <- function() {
    nav_panel(
        title = "SENA",
        icon = icon("sitemap"),
        tags$div(
            class = "p-3",
            # Title and logo container with content in left column
            tags$div(
                style = "display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; align-items: start; min-height: 100px;",
                # LEFT COLUMN: Title AND content together
                tags$div(
                    tags$h4("SENA", class = "mb-0"),
                    tags$div(
                        style = "margin-top: 0.5rem; text-align: left;", # Exactly 0.5rem below the title
                        tags$p(
                            HTML(
                                paste0(
                                    '<strong><span style="color: #ce0fa0;">S</span></strong>hiny ',
                                    '<strong><span style="color: #ce0fa0;">E</span></strong>ssentials for ',
                                    '<strong><span style="color: #ce0fa0;">N</span></strong>uclearFF ',
                                    '<strong><span style="color: #ce0fa0;">A</span></strong>pplications, or SENA, is a modular R package designed to accelerate UI development in Shiny apps. ',
                                    "It provides reusable components, layout utilities, and module scaffolding for rapid prototyping within the Nuclear Fantasy Football ecosystem."
                                )
                            )
                        ),
                        # CREATED badge alone
                        tags$div(
                            style = "margin-top: 0.5rem;", # Space above badges
                            HTML('<img src="https://img.shields.io/github/created-at/nuclearfantasyfootball/sena?style=for-the-badge&logo=github&label=Created&labelColor=%23181717">')
                        ),
                        tags$br(),
                        # Language badges
                        tags$div(
                            HTML(paste(
                                '<img src="https://img.shields.io/github/languages/count/nuclearfantasyfootball/sena?style=for-the-badge&logo=github&labelColor=%23181717">',
                                '<img src="https://img.shields.io/github/languages/top/nuclearfantasyfootball/sena?style=for-the-badge&logo=github&labelColor=%23181717">'
                            ))
                        ),
                        tags$br(),
                        # Issues badges
                        tags$div(
                            HTML(paste(
                                '<img src="https://img.shields.io/github/issues/nuclearfantasyfootball/sena?style=for-the-badge&logo=github&labelColor=%23181717">',
                                '<img src="https://img.shields.io/github/issues-pr/nuclearfantasyfootball/sena?style=for-the-badge&logo=github&labelColor=%23181717">'
                            ))
                        ),
                        tags$br(),
                        # Versioning badges
                        tags$div(
                            HTML(paste(
                                '<img src="https://img.shields.io/github/r-package/v/nuclearfantasyfootball/sena?style=for-the-badge&logo=r&label=Version&labelColor=%23276DC3">',
                                '<img src="https://img.shields.io/badge/lifecycle-experimental-orange.svg?style=for-the-badge&label=Lifecycle&labelColor=%23181717">'
                            ))
                        )
                    )
                ),
                # RIGHT COLUMN: Logo only
                tags$a(
                    href = "https://github.com/nuclearfantasyfootball/sena",
                    target = "_blank",
                    class = "text-decoration-none",
                    style = "display: block; width: 100%; align-self: start;",
                    tags$img(
                        src = "logos/packages/Sena-Package-Transparent.png",
                        alt = "SENA R Package Logo",
                        style = "width: 100%; height: auto; object-fit: contain; display: block; vertical-align: top;"
                    )
                )
            )
        )
    )
}

#' Development OTIS Tab
#'
#' @title Development OTIS Tab
#' @description A tab panel for the OTIS workstream.
#' @return A `nav_panel` representing the OTIS tab.
development_otis <- function() {
    nav_panel(
        title = "OTIS",
        icon = icon("share-nodes"),
        tags$div(
            class = "p-3",
            # Title and logo container with content in right column
            tags$div(
                style = "display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; align-items: start; min-height: 100px;",
                # LEFT COLUMN: Logo only
                tags$a(
                    href = "https://github.com/nuclearfantasyfootball/otis",
                    target = "_blank",
                    class = "text-decoration-none",
                    style = "display: block; width: 100%; align-self: start;",
                    tags$img(
                        src = "logos/packages/Otis-Package-Transparent.png",
                        alt = "OTIS R Package Logo",
                        style = "width: 100%; height: auto; object-fit: contain; display: block; vertical-align: top;"
                    )
                ),
                # RIGHT COLUMN: Title AND content together
                tags$div(
                    tags$h4("OTIS", class = "mb-0"),
                    tags$div(
                        style = "margin-top: 0.5rem;", # Exactly 0.5rem below the title
                        tags$p(
                            HTML(
                                paste0(
                                    '<strong><span style="color: #0fa0ce;">O</span></strong>ptimized ',
                                    '<strong><span style="color: #0fa0ce;">T</span></strong>oolkit ',
                                    '<strong><span style="color: #0fa0ce;">I</span></strong>ntegrating ',
                                    '<strong><span style="color: #0fa0ce;">S</span></strong>leeper, ',
                                    "(OTIS) is an R package that provides a convenient interface to the Sleeper Fantasy Football API. ",
                                    "OTIS makes it easy to pull data from your fantasy football leagues on Sleeper, whether by username or league ID, and transform it into R-friendly formats for analysis, visualization, or integration into apps such as Shiny. "
                                )
                            )
                        ),
                        # CREATED badge alone
                        tags$div(
                            style = "margin-top: 0.5rem;", # Space above badges
                            HTML('<img src="https://img.shields.io/github/created-at/nuclearfantasyfootball/otis?style=for-the-badge&logo=github&color=%2300aeef&label=Created&labelColor=%23000&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fotis">')
                        ),
                        tags$br(),
                        # Language badges
                        tags$div(
                            HTML(paste(
                                '<img src="https://img.shields.io/github/languages/count/nuclearfantasyfootball/otis?style=for-the-badge&logo=github&labelColor=%23181717&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fotis">',
                                '<img src="https://img.shields.io/github/languages/top/nuclearfantasyfootball/otis?style=for-the-badge&logo=github&labelColor=%23181717&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fotis">'
                            ))
                        ),
                        tags$br(),
                        # Issues badges
                        tags$div(
                            HTML(paste(
                                '<img src="https://img.shields.io/github/issues/nuclearfantasyfootball/otis?style=for-the-badge&logo=github&labelColor=%23181717&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fotis%2Fissues">',
                                '<img src="https://img.shields.io/github/issues-pr/nuclearfantasyfootball/otis?style=for-the-badge&logo=github&labelColor=%23181717&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fotis%2Fpulls">'
                            ))
                        ),
                        tags$br(),
                        # Versioning badges
                        tags$div(
                            HTML(paste(
                                '<img src="https://img.shields.io/github/r-package/v/nuclearfantasyfootball/otis?style=for-the-badge&logo=r&label=Version&labelColor=%23276DC3&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fotis">',
                                '<img src="https://img.shields.io/badge/lifecycle-experimental-orange.svg?style=for-the-badge&label=Lifecycle&labelColor=%23181717&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fotis">'
                            ))
                        )
                    )
                )
            )
        )
    )
}




#' Development GERALD Tab
#'
#' @title Development GERALD Tab
#' @description A tab panel for the GERALD workstream.
#' @return A `nav_panel` representing the GERALD tab.
development_gerald <- function() {
    nav_panel(
        title = "GERALD",
        icon = icon("cube"),
        tags$div(
            class = "p-3",
            # Title and logo container with content in left column
            tags$div(
                style = "display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; align-items: start; min-height: 100px;",
                # LEFT COLUMN: Title AND content together
                tags$div(
                    tags$h4("GERALD", class = "mb-0"),
                    tags$div(
                        style = "margin-top: 0.5rem;", # Exactly 0.5rem below the title
                        tags$p(
                            HTML(
                                paste0(
                                    '<strong><span style="color: #9d0fce;">G</span></strong>ridiron ',
                                    '<strong><span style="color: #9d0fce;">E</span></strong>ngine for ',
                                    '<strong><span style="color: #9d0fce;">R</span></strong>esearch, ',
                                    '<strong><span style="color: #9d0fce;">A</span></strong>nalytics, and ',
                                    '<strong><span style="color: #9d0fce;">L</span></strong>eague ',
                                    '<strong><span style="color: #9d0fce;">D</span></strong>ata, ',
                                    "or GERALD, is an R package utilized to obtain NFL information and statistics. ",
                                    "GERALD is utilized for NFL and fantasy football analytics with up-to-date ",
                                    "league data. "
                                )
                            )
                        ),
                        # CREATED badge alone
                        tags$div(
                            style = "margin-top: 0.5rem;", # Space above badges
                            HTML('<img src="https://img.shields.io/github/created-at/nuclearfantasyfootball/gerald?style=for-the-badge&logo=github&color=%2300aeef&label=Created&labelColor=%23000&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fgerald">')
                        ),
                        tags$br(),
                        # Language badges
                        tags$div(
                            HTML(paste(
                                '<img src="https://img.shields.io/github/languages/count/nuclearfantasyfootball/gerald?style=for-the-badge&logo=github&labelColor=%23181717&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fgerald">',
                                '<img src="https://img.shields.io/github/languages/top/nuclearfantasyfootball/gerald?style=for-the-badge&logo=github&labelColor=%23181717&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fgerald">'
                            ))
                        ),
                        tags$br(),
                        # Issues badges
                        tags$div(
                            HTML(paste(
                                '<img src="https://img.shields.io/github/issues/nuclearfantasyfootball/gerald?style=for-the-badge&logo=github&labelColor=%23181717&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fgerald%2Fissues">',
                                '<img src="https://img.shields.io/github/issues-pr/nuclearfantasyfootball/gerald?style=for-the-badge&logo=github&labelColor=%23181717&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fgerald%2Fpulls">'
                            ))
                        ),
                        tags$br(),
                        # Versioning badges
                        tags$div(
                            HTML(paste(
                                '<img src="https://img.shields.io/github/r-package/v/nuclearfantasyfootball/gerald?style=for-the-badge&logo=r&label=Version&labelColor=%23276DC3&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fgerald">',
                                '<img src="https://img.shields.io/badge/lifecycle-experimental-orange.svg?style=for-the-badge&label=Lifecycle&labelColor=%23181717&link=https%3A%2F%2Fgithub.com%2Fnuclearfantasyfootball%2Fgerald">'
                            ))
                        )
                    )
                ),

                # RIGHT COLUMN: Logo only
                tags$a(
                    href = "https://github.com/nuclearfantasyfootball/gerald",
                    target = "_blank",
                    class = "text-decoration-none",
                    style = "display: block; width: 100%; align-self: start;",
                    tags$img(
                        src = "logos/packages/Gerald-Package-Transparent.png",
                        alt = "GERALD R Package Logo",
                        style = "width: 100%; height: auto; object-fit: contain; display: block; vertical-align: top;"
                    )
                )
            )
        )
    )
}

#' Community Section
#'
#' @title Community Section UI Helper
#' @description Final section with a call-to-action encouraging users to join the
#' community chat. Uses a fixed card to ensure the CTA remains visible across
#' viewport sizes.
#'
#' @param ns A namespace function created by [shiny::NS()].
#' @return A `shiny.tag` with the community section markup.
community_section <- function(ns) {
    tags$section(
        class = "fourth nff-backdrop",
        tags$div(
            class = "outer",
            tags$div(
                class = "inner",
                tags$div(
                    class = "bg",
                    tags$h2(
                        class = "glitch-title glitch-text",
                        `data-text` = "Get Started",
                        "Get Started"
                    ),
                    tags$div(
                        class = "development-card-container",
                        style = "position: fixed; top: calc(56px + 4rem); bottom: 9%; left: 5% !important; right: 5% !important; transform: none; z-index: 10;",
                        bslib::card(
                            class = "glass-effect section-card",
                            style = "height: 100%; overflow-y: auto;",
                            bslib::card_body(
                                tags$h4("Join Our Community"),
                                tags$p("Connect with fantasy football enthusiasts."),
                                tags$p("Join Discord for live discussions.")
                            )
                        )
                    ),
                    create_scroll_indicator(ns, "4")
                )
            )
        )
    )
}

#' Create Scroll Indicator
#'
#' @title Scroll Indicator Builder
#' @description A small helper that creates a namespaced scroll indicator
#' component. Clicking the indicator advances to the next section using a global
#' `window.gotoSection` function (must be provided by the app).
#'
#' @param ns A namespace function created by [shiny::NS()].
#' @param id_suffix Character. Unique suffix to namespace the indicator's ID.
#'
#' @return A `shiny.tag` representing the indicator.
create_scroll_indicator <- function(ns, id_suffix) {
    scroll_indicator(
        id = ns(paste0("scroll_indicator_", id_suffix)),
        text = "",
        onclick = "if(typeof currentIndex !== 'undefined') window.gotoSection(currentIndex + 1, 1); return false;"
    )
}

#' Scroll Indicator Tag
#'
#' @title Scroll Indicator Tag Builder
#' @description The core tag generator for scroll indicators. Includes ARIA
#' attributes for better screen reader support and keyboard operability.
#'
#' @param id String. HTML element ID.
#' @param text String. Visible label text. Defaults to "SCROLL".
#' @param onclick String. JavaScript handler for click events.
#'
#' @return A `shiny.tag` representing the indicator element.
scroll_indicator <- function(
    id,
    text = "SCROLL",
    onclick = "window.gotoSection(currentIndex + 1, 1); return false;") {
    tags$div(
        id = id,
        class = "scroll-indicator",
        onclick = onclick,
        role = "button",
        tabindex = "0", # allow keyboard focus for accessibility
        `aria-label` = paste("Scroll to next section"),
        # Three spans inside a box allow for simple CSS keyframe animations
        tags$div(class = "scroll-box", tags$span(), tags$span(), tags$span()),
        tags$div(class = "scroll-text", text)
    )
}

# =============================
# SERVER MODULE
# =============================

#' Home Page Server Logic
#'
#' @title Home Page Module Server
#' @description Initializes server-side behaviors for the home page, including
#' one-time setup after initial rendering, animated CTA initialization, and basic
#' interaction analytics. Emits a small reactive API for composition.
#'
#' @param id Character string. Module ID (namespace ID).
#' @param parent_session A [shiny::session] object. Optional; used when the
#'   server logic needs to interact with a parent session (e.g., navigation).
#'
#' @return A named list of reactives: `page_loaded` and `explore_clicked`.
#' @export
home_page_server <- function(id, parent_session = getDefaultReactiveDomain()) {
    moduleServer(id, function(input, output, session) {
        # Use onFlushed so that dependent JS/CSS is guaranteed to be available
        session$onFlushed(function() {
            # Inform the app-level router / analytics that the Home tab is visible
            session$sendCustomMessage("tabChanged", "home")

            # Initialize the electrified CTA button; passing a namespaced ID ensures
            # it remains unique even if the module is instantiated multiple times
            init_electrified_button(
                session,
                session$ns("dashboard_action_btn"),
                auto_play = TRUE
            )

            # Kick off the typing animation for the DEVELOPMENT header
            session$sendCustomMessage("startTypingAnimation", session$ns("typing_title"))
        }, once = TRUE)

        # Track engagement with the primary CTA to inform future UX iterations
        observeEvent(input$dashboard_action_btn, {
            logEvent(
                event = "explore_clicked",
                location = "hero_section",
                module_id = session$ns("dashboard_action_btn"),
                session = session
            )
        })

        # Provide a tiny reactive contract to upstream callers
        list(
            page_loaded = reactive(TRUE),
            explore_clicked = reactive(input$dashboard_action_btn)
        )
    })
}

# =============================
# UTILITIES
# =============================

#' Log Event Utility
#'
#' @title Structured Event Logger
#' @description Logs user interactions or system events to the R console (or a
#' JSON file) when debugging is enabled via the `nuclearff.debug` option. The log
#' entry includes a timestamp, the event name, optional session metadata, and
#' arbitrary key-value pairs describing context.
#'
#' @param event Character. Name of the event (e.g., "button_click").
#' @param ... Named arguments carrying metadata about the event (e.g., `location`,
#'   `context`). These are collected into a list and serialized for output.
#' @param session Optional Shiny session. When provided, the session token and
#'   module namespace are included to help trace multi-user interactions.
#' @param log_to_file Logical. If `TRUE`, append JSON lines to `event_log.json` in
#'   the working directory. Defaults to `FALSE`.
#'
#' @return Invisibly returns the structured log entry (list) for testing.
#' @keywords internal
logEvent <- function(event, ..., session = NULL, log_to_file = FALSE) {
    # Construct a small, structured payload. Use uppercase month for easy scanning
    info <- list(
        timestamp = format(Sys.time(), "%Y-%b-%d") |> toupper(),
        event = event,
        data = list(...)
    )

    # Attach session metadata when available so we can reconcile events later
    if (!is.null(session)) {
        info$session_id <- session$token
        info$module_id <- session$ns(NULL)
    }

    # Only emit logs when debug mode is active to avoid noisy production logs
    if (getOption("nuclearff.debug", FALSE)) {
        message(jsonlite::toJSON(info, auto_unbox = TRUE, pretty = TRUE))
    }

    if (isTRUE(log_to_file)) {
        # Append newline-delimited JSON for easy ingestion by log shippers
        cat(
            paste0("[", format(Sys.time(), "%Y-%b-%d") |> toupper(), "] "),
            jsonlite::toJSON(info, auto_unbox = TRUE),
            "\n",
            file = "event_log.json",
            append = TRUE
        )
    }

    invisible(info)
}
