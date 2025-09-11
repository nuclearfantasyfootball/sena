#' Home Page Module UI
#'
#' Create the home/landing page with scroll sections
#'
#' One of the important features is the electrified button in the hero section.
#' This button uses SVG and JavaScript to create an animated, electrified effect.
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
            class = "first",
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
                            onclick = "window.gotoSection(1, 1); return false;"
                        )
                    )
                )
            )
        ),

        # Section 2 - Welcome
        tags$section(
            class = "second",
            tags$div(
                class = "outer",
                tags$div(
                    class = "inner",
                    tags$div(
                        class = "bg",
                        tags$h2(
                            class = "section-heading",
                            "Welcome to",
                            tags$br(),
                            "Elite Fantasy"
                        )
                    )
                )
            )
        ),

        # Section 3 - Features
        tags$section(
            class = "third",
            tags$div(
                class = "outer",
                tags$div(
                    class = "inner",
                    tags$div(
                        class = "bg",
                        tags$h2(
                            class = "section-heading",
                            "Advanced",
                            tags$br(),
                            "Analytics"
                        )
                    )
                )
            )
        ),

        # Section 4 - Community
        tags$section(
            class = "fourth",
            tags$div(
                class = "outer",
                tags$div(
                    class = "inner",
                    tags$div(
                        class = "bg",
                        tags$h2(
                            class = "section-heading",
                            "Join Our",
                            tags$br(),
                            "Community"
                        )
                    )
                )
            )
        ),

        # Section 5 - Get Started
        # Section 5 - Get Started (modified)
        tags$section(
            class = "fifth",
            tags$div(
                class = "outer",
                tags$div(
                    class = "inner",
                    tags$div(
                        class = "bg",
                        tags$h2(
                            class = "section-heading",
                            "Get Started" # Simplified - removed the button
                        )
                    )
                )
            )
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
            # Important! Remember to initialize in module with unique ID
            init_electrified_button(session,
                session$ns("dashboard_action_btn"),
                auto_play = TRUE # Enable auto-play on load
            )
        }, once = TRUE)

        # No need for button observers - look in main.js
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
