#' Leagues Page Module UI
#'
#' Creates the UI for the leagues page with pill navigation
#'
#' @param id Character string. Module namespace ID
#' @return UI element for leagues page
#' @export
leagues_page_ui <- function(id) {
    ns <- NS(id)

    tags$div(
        class = "league-content-section nff-backdrop",

        # Single card with pill navigation
        bslib::card(
            class = "section-card centered-nav-pills",
            style = "height: auto; min-height: 80vh;",

            # Card header with title
            # card_header(
            #     tags$h4(
            #         class = "mb-0 text-center",
            #         "FORMATS"
            #     )
            # ),

            # Card body with navset_pill
            card_body(
                navset_pill(
                    id = ns("league_tabs"),

                    # Redraft panel
                    nav_panel(
                        title = tags$span(
                            bs_icon("arrow-repeat"),
                            tags$span(class = "ms-2", "REDRAFT")
                        ),
                        value = "redraft",
                        uiOutput(ns("redraft_content"))
                    ),

                    # Dynasty panel
                    nav_panel(
                        title = tags$span(
                            bs_icon("trophy"),
                            tags$span(class = "ms-2", "DYNASTY")
                        ),
                        value = "dynasty",
                        uiOutput(ns("dynasty_content"))
                    ),

                    # Chopped panel
                    nav_panel(
                        title = tags$span(
                            bs_icon("scissors"),
                            tags$span(class = "ms-2", "CHOPPED")
                        ),
                        value = "chopped",
                        uiOutput(ns("chopped_content"))
                    ),

                    # Survivor panel
                    nav_panel(
                        title = tags$span(
                            bs_icon("fire"),
                            tags$span(class = "ms-2", "SURVIVOR")
                        ),
                        value = "survivor",
                        uiOutput(ns("survivor_content"))
                    )
                )
            )
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
        # Track selected league from pill navigation
        selected_league <- reactive({
            input$league_tabs %||% "redraft"
        })

        # Render content for each league type
        output$redraft_content <- renderUI({
            create_redraft_content()
        })

        output$dynasty_content <- renderUI({
            create_dynasty_content()
        })

        output$chopped_content <- renderUI({
            create_chopped_content()
        })

        output$survivor_content <- renderUI({
            create_survivor_content()
        })

        # Log tab changes if needed
        observeEvent(input$league_tabs, {
            logEvent("league_tab_changed", league = input$league_tabs)
        })

        return(selected_league)
    })
}
