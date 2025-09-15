#' Home Page Module UI
#'
#' Create the home/landing page with scroll sections
#'
#' @param id Character string. Module namespace ID
#' @return UI element for home page
#' @export
home_page_ui <- function(id) {
    ns <- NS(id)

    tags$div(
        class = "scroll-container",
        id = ns("scroll_container"),

        # Section 1 - Hero
        tags$section(
            class = "first nff-backdrop",
            tags$div(
                class = "outer",
                tags$div(
                    class = "inner",
                    tags$div(
                        class = "bg",
                        tags$h2(
                            class = "section-heading",
                            "NUCLEAR",
                            tags$br(),
                            "FANTASY FOOTBALL"
                        ),
                        # Electrified button
                        electrified_button(
                            id = ns("dashboard_action_btn"),
                            text = "EXPLORE",
                            position = "bottom-right",
                            onclick = "setTimeout(() => window.gotoSection(1), 50); return false;"
                        ),
                        # Scroll indicator - positioned below electrified button
                        scroll_indicator(
                            id = ns("scroll_indicator"),
                            text = "",
                            onclick = "if(typeof currentIndex !== 'undefined') window.gotoSection(currentIndex + 1, 1); return false;"
                        )
                    )
                )
            )
        ),

        # Section 2 - Welcome
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
                            tags$h2(
                                class = "section-heading",
                                "Reach critical mass.", tags$br(),
                                "Create unstoppable momentum."
                            ),
                            bslib::card(
                                class = "glass-effect section-card",
                                bslib::card_body(
                                    tags$h4("Enhanced Glass Effect"),
                                    tags$p("This card now features an advanced liquid glass effect with distortion and multiple layers."),
                                    tags$p("The effect responds to both light and dark themes with appropriate tinting.")
                                )
                            ),
                            scroll_indicator(
                                id = ns("scroll_indicator_2"),
                                text = "",
                                onclick = "if(typeof currentIndex !== 'undefined') window.gotoSection(currentIndex + 1, 1); return false;"
                            )
                        ),
                        # SVG filter for liquid glass distortion
                        tags$svg(
                            style = "position: absolute; width: 0; height: 0;",
                            tags$defs(
                                tags$filter(
                                    id = "liquid-glass-distortion",
                                    x = "0%", y = "0%",
                                    width = "100%", height = "100%",
                                    filterUnits = "objectBoundingBox",
                                    tags$feTurbulence(
                                        type = "fractalNoise",
                                        baseFrequency = "0.008 0.008",
                                        numOctaves = "2",
                                        seed = "3",
                                        result = "turbulence"
                                    ),
                                    tags$feGaussianBlur(
                                        `in` = "turbulence",
                                        stdDeviation = "2",
                                        result = "blur"
                                    ),
                                    tags$feDisplacementMap(
                                        `in` = "SourceGraphic",
                                        in2 = "blur",
                                        scale = "12",
                                        xChannelSelector = "R",
                                        yChannelSelector = "G"
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ),

        # Section 3 - Development
        tags$section(
            class = "third nff-backdrop",
            tags$div(
                class = "outer",
                tags$div(
                    class = "inner",
                    tags$div(
                        class = "bg",
                        # Title at the top
                        tags$h2(
                            class = "development-title typing-animation",
                            style = "position: fixed; top: 20px !important; left: 5%; transform: none; z-index: 100; --steps: 12;",
                            "DEVELOPMENT"
                        ),
                        # Full-height card container with more bottom padding
                        tags$div(
                            class = "development-card-container",
                            bslib::card(
                                class = "glass-effect section-card no-tilt centered-nav-pills",
                                style = "height: 100%; overflow-y: auto;",
                                navset_pill(
                                    id = ns("dev_tabs"),
                                    nav_panel(
                                        title = "Overview",
                                        icon = bsicons::bs_icon("info-circle"),
                                        tags$div(
                                            class = "p-3",
                                            tags$h4("Development Overview"),
                                            tags$p("Information about the development process and methodology."),
                                            tags$ul(
                                                tags$li("Modern R Shiny architecture"),
                                                tags$li("Modular design patterns"),
                                                tags$li("Custom CSS/JavaScript integration"),
                                                tags$li("Responsive design principles"),
                                                tags$li("Performance optimization")
                                            )
                                        )
                                    ),
                                    nav_panel(
                                        title = "Tech Stack",
                                        icon = bsicons::bs_icon("stack"),
                                        tags$div(
                                            class = "p-3",
                                            tags$h4("Technology Stack"),
                                            tags$p("Core technologies powering this application:"),
                                            tags$div(
                                                class = "row g-3",
                                                tags$div(
                                                    class = "col-md-6",
                                                    tags$h6("Frontend"),
                                                    tags$ul(
                                                        tags$li("R Shiny"),
                                                        tags$li("Bootstrap 5"),
                                                        tags$li("GSAP Animations"),
                                                        tags$li("Custom CSS"),
                                                        tags$li("JavaScript ES6+")
                                                    )
                                                ),
                                                tags$div(
                                                    class = "col-md-6",
                                                    tags$h6("Backend"),
                                                    tags$ul(
                                                        tags$li("R Server"),
                                                        tags$li("Modular Architecture"),
                                                        tags$li("Data Processing"),
                                                        tags$li("API Integration"),
                                                        tags$li("AWS Deployment")
                                                    )
                                                )
                                            )
                                        )
                                    ),
                                    nav_panel(
                                        title = "Resources",
                                        icon = bsicons::bs_icon("book"),
                                        tags$div(
                                            class = "p-3",
                                            tags$h4("Development Resources"),
                                            tags$p("Useful links and documentation:"),
                                            tags$div(
                                                class = "list-group",
                                                tags$a(
                                                    href = "https://shiny.posit.co/",
                                                    target = "_blank",
                                                    class = "list-group-item list-group-item-action",
                                                    tags$div(
                                                        class = "d-flex justify-content-between align-items-center",
                                                        tags$div(
                                                            tags$h6(class = "mb-1", "Shiny Documentation"),
                                                            tags$small("Official Shiny documentation and guides")
                                                        ),
                                                        bsicons::bs_icon("arrow-up-right")
                                                    )
                                                ),
                                                tags$a(
                                                    href = "https://rstudio.github.io/bslib/",
                                                    target = "_blank",
                                                    class = "list-group-item list-group-item-action",
                                                    tags$div(
                                                        class = "d-flex justify-content-between align-items-center",
                                                        tags$div(
                                                            tags$h6(class = "mb-1", "bslib Package"),
                                                            tags$small("Bootstrap themes and components for Shiny")
                                                        ),
                                                        bsicons::bs_icon("arrow-up-right")
                                                    )
                                                ),
                                                tags$a(
                                                    href = "https://github.com/nuclearfantasyfootball",
                                                    target = "_blank",
                                                    class = "list-group-item list-group-item-action",
                                                    tags$div(
                                                        class = "d-flex justify-content-between align-items-center",
                                                        tags$div(
                                                            tags$h6(class = "mb-1", "GitHub Repository"),
                                                            tags$small("Source code and development history")
                                                        ),
                                                        bsicons::bs_icon("arrow-up-right")
                                                    )
                                                )
                                            )
                                        )
                                    ),
                                    nav_panel(
                                        title = "Contact",
                                        icon = bsicons::bs_icon("envelope"),
                                        tags$div(
                                            class = "p-3",
                                            tags$h4("Get in Touch"),
                                            tags$p("Connect with the development team:"),
                                            tags$div(
                                                class = "row g-3",
                                                tags$div(
                                                    class = "col-12",
                                                    tags$div(
                                                        class = "card",
                                                        tags$div(
                                                            class = "card-body text-center",
                                                            tags$div(
                                                                class = "d-flex justify-content-center gap-3 mb-3",
                                                                tags$a(
                                                                    href = "https://x.com/nuclearffnolan",
                                                                    target = "_blank",
                                                                    class = "btn btn-outline-primary",
                                                                    bsicons::bs_icon("twitter-x"),
                                                                    " Twitter"
                                                                ),
                                                                tags$a(
                                                                    href = "https://discord.gg/9sJQ4yYkkF",
                                                                    target = "_blank",
                                                                    class = "btn btn-outline-primary",
                                                                    bsicons::bs_icon("discord"),
                                                                    " Discord"
                                                                ),
                                                                tags$a(
                                                                    href = "https://github.com/nuclearfantasyfootball",
                                                                    target = "_blank",
                                                                    class = "btn btn-outline-primary",
                                                                    bsicons::bs_icon("github"),
                                                                    " GitHub"
                                                                )
                                                            )
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        ),
                        scroll_indicator(
                            id = ns("scroll_indicator_3"),
                            text = "",
                            onclick = "if(typeof currentIndex !== 'undefined') window.gotoSection(currentIndex + 1, 1); return false;"
                        )
                    )
                )
            )
        ),

        # Section 4 - Community
        tags$section(
            class = "fourth nff-backdrop",
            tags$div(
                class = "outer",
                tags$div(
                    class = "inner",
                    tags$div(
                        class = "bg",
                        # Title at the top
                        tags$h2(
                            class = "section-heading development-title",
                            style = "position: fixed; top: 56px; left: 5%; transform: none; z-index: 100;",
                            "JOIN US"
                        ),
                        # Full-height card container with more bottom padding
                        tags$div(
                            class = "development-card-container",
                            style = "position: fixed; top: calc(56px + 4rem); bottom: 9%; left: 5% !important; right: 5% !important; transform: none; z-index: 10;",
                            bslib::card(
                                class = "glass-effect section-card",
                                style = "height: 100%; overflow-y: auto;",
                                bslib::card_body(
                                    tags$h4("Join Our Community"),
                                    tags$p("Connect with fellow fantasy football enthusiasts and stay updated on the latest features."),
                                    tags$p("Join our Discord server for real-time discussions and support.")
                                )
                            )
                        ),
                        scroll_indicator(
                            id = ns("scroll_indicator_4"),
                            text = "",
                            onclick = "if(typeof currentIndex !== 'undefined') window.gotoSection(currentIndex + 1, 1); return false;"
                        )
                    )
                )
            )
        ),

        # Section 5 - Get Started
        tags$section(
            class = "fifth nff-backdrop",
            tags$div(
                class = "outer",
                tags$div(
                    class = "inner",
                    tags$div(
                        class = "bg",
                        tags$h2(
                            class = "section-heading",
                            "Get Started"
                        )
                    )
                )
            )
        )
    )
}

#' Create Animated Scroll Indicator
#'
#' Creates an animated scroll indicator with arrows and text
#'
#' @param id Character string. Unique ID for the indicator
#' @param text Character string. Text to display below arrows (default: "SCROLL")
#' @param onclick Character string. JavaScript to execute on click
#' @return HTML tags for scroll indicator
#' @keywords internal
scroll_indicator <- function(id = "scroll_indicator",
                             text = "SCROLL",
                             onclick = "window.gotoSection(currentIndex + 1, 1); return false;") {
    tags$div(
        id = id,
        class = "scroll-indicator",
        onclick = onclick,
        role = "button",
        tabindex = "0",
        `aria-label` = paste("Scroll to next section"),

        # Arrow animation container
        tags$div(
            class = "scroll-box",
            tags$span(),
            tags$span(),
            tags$span()
        ),

        # Text below arrows
        tags$div(
            class = "scroll-text",
            text
        )
    )
}

#' Home Page Module Server
#'
#' Server logic for home page interactions
#'
#' @param id Character string. Module namespace ID
#' @param parent_session Parent session for navigation
#' @return Reactive values from home page
#' @export
home_page_server <- function(id, parent_session = getDefaultReactiveDomain()) {
    moduleServer(id, function(input, output, session) {
        # Initialize
        session$onFlushed(function() {
            # Scroll sections
            session$sendCustomMessage("tabChanged", "home")
            # Initialize Electrified button
            init_electrified_button(session,
                session$ns("dashboard_action_btn"),
                auto_play = TRUE # Enable auto-play on load
            )
            # Start typing animation for development section
            session$sendCustomMessage("startTypingAnimation", session$ns("typing_title"))
        }, once = TRUE)

        list(page_loaded = reactive(TRUE))
    })
}

#' Log Event
#'
#' Log user interactions for analytics
#'
#' @param event Character. Event name
#' @param ... Additional event parameters
#' @keywords internal
logEvent <- function(event, ...) {
    # TODO: Implement logging (files, database, analytics)
    if (getOption("nuclearff.debug", FALSE)) {
        message(sprintf("[%s] Event: %s", Sys.time(), event))
    }
}
