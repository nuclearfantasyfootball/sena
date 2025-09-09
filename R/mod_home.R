#' Home Page Module UI
#'
#' Create the home/landing page
#'
#' @param id Character string. Module namespace ID
#' @return UI element for home page
#' @export
home_page_ui <- function(id) {
    ns <- NS(id)
    config <- app_config()

    tags$section(
        class = "hero-section hero-minimal",
        tags$div(class = "hero-overlay"),
        tags$div(
            class = "hero-center",
            tags$img(
                src = config$external_resources$logo_url,
                class = "hero-logo",
                alt = "Nuclear Fantasy Football"
            ),
            tags$div(
                class = "hero-title",
                tags$div(class = "hero-title-main text-focus-in", "NUCLEAR"),
                tags$div(class = "hero-title-sub text-focus-in", "FANTASY FOOTBALL")
            ),
            tags$button(
                id = ns("cta_view_app"),
                type = "button",
                class = "league-nav-btn hero-cta",
                `aria-label` = "Explore the app",
                "EXPLORE"
            )
        ),
        # Optional: Add feature cards or additional content
        uiOutput(ns("additional_content"))
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
        # Handle CTA button click
        observeEvent(input$cta_view_app, {
            # Navigate to leagues page
            updateNavbarPage(parent_session, "topnav", selected = "leagues")

            # Log interaction
            logEvent("home_cta_clicked", timestamp = Sys.time())
        })

        # Optional: Dynamic content based on user or time
        output$additional_content <- renderUI({
            # Could add seasonal content, announcements, etc.
            NULL
        })

        # Return any reactive values needed by parent
        list(
            cta_clicked = reactive(input$cta_view_app)
        )
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
    # TODO: Implement logging (file, database, or analytics service)
    if (getOption("nuclearff.debug", FALSE)) {
        message(sprintf("[%s] Event: %s", Sys.time(), event))
    }
}
