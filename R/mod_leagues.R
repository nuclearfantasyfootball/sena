#' Leagues Page Module UI
#'
#' Creates the UI for the leagues page with sidebar navigation
#'
#' @param id Character string. Module namespace ID
#' @return UI element for leagues page
#' @export
leagues_page_ui <- function(id) {
    ns <- NS(id)

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
                    actionButton(ns("btn_redraft"),
                        tags$span(bs_icon("arrow-repeat"), "Redraft"),
                        class = "league-nav-btn"
                    ),
                    actionButton(ns("btn_dynasty"),
                        tags$span(bs_icon("trophy"), "Dynasty"),
                        class = "league-nav-btn"
                    ),
                    actionButton(ns("btn_chopped"),
                        tags$span(bs_icon("scissors"), "Chopped"),
                        class = "league-nav-btn"
                    ),
                    actionButton(ns("btn_survivor"),
                        tags$span(bs_icon("fire"), "Survivor"),
                        class = "league-nav-btn"
                    )
                )
            )
        ),
        tags$div(
            class = "league-content-section",
            uiOutput(ns("league_content"))
        )
    )
}

#' Leagues Page Module Server
#'
#' Server logic for managing league page interactions
#'
#' @param id Character string. Module namespace ID
#' @return Reactive value containing selected league type
#' @export
leagues_page_server <- function(id) {
    moduleServer(id, function(input, output, session) {
        # Track selected league
        selected_league <- reactiveVal("redraft")

        # League button observers
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

        # Render league content
        output$league_content <- renderUI({
            league_content_generator(selected_league())
        })

        # Initialize league buttons
        session$onFlushed(function() {
            session$sendCustomMessage("addLeagueButtonHandler", TRUE)
        }, once = TRUE)

        return(selected_league)
    })
}

#' League Content Generator
#'
#' Generate content for selected league type
#'
#' @param league Character. Type of league
#' @return UI content for the selected league
#' @keywords internal
league_content_generator <- function(league) {
    # Delegate to specific content generators
    switch(league,
        "redraft" = create_redraft_content(),
        "dynasty" = create_dynasty_content(),
        "chopped" = create_chopped_content(),
        "survivor" = create_survivor_content(),
        tags$div("Unknown league type") # Fallback
    )
}
