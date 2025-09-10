#' Data Tools Module UI
#'
#' Creates the UI for data analysis tools
#'
#' @param id Character string. Module namespace ID
#' @return UI element for data tools
#' @export
data_tools_ui <- function(id) {
    ns <- NS(id)

    tags$div(
        class = "tools-content-section", # Wrapper for content/table
        # Styled title for dataTable card
        tags$div(
            class = "league-hero-row",
            tags$img(
                src = "https://raw.githubusercontent.com/NuclearAnalyticsLab/nuclearff/refs/heads/main/inst/logos/png/nuclearff-2color.png",
                alt = "Tools logo",
                class = "hero-logo"
            ),
            tags$span("TOOLS", class = "hero-text")
        ),
        tags$hr(class = "my-4"),
        layout_column_wrap(
            widths = 1,
            card(
                card_header(
                    class = "d-flex justify-content-between align-items-center",
                    tags$span("Data Explorer"),
                    tags$div(
                        class = "btn-group btn-group-sm",
                        actionButton(ns("refresh_data"),
                            "Refresh",
                            icon = icon("rotate-right"),
                        ),
                        actionButton(ns("download_data"),
                            "Download",
                            icon = icon("download"),
                            class = "btn-outline-secondary"
                        )
                    )
                ),
                card_body(
                    DTOutput(ns("data_table"), width = "100%")
                )
            )
        )
    )
}

#' Data Tools Module Server
#'
#' Server logic for data analysis tools
#'
#' @param id Character string. Module namespace ID
#' @param data Reactive expression or data frame to display
#' @param options List. Additional DataTable options
#' @return List containing reactive values for data state
#' @export
data_tools_server <- function(id,
                              data = reactive(iris),
                              options = list()) {
    moduleServer(id, function(input, output, session) {
        # Merge default options with custom options
        default_options <- list(
            pageLength = 25,
            dom = "Bfrtip",
            buttons = c("copy", "csv", "excel", "pdf", "print"),
            scrollX = TRUE,
            responsive = TRUE,
            order = list(list(0, "asc")),
            columnDefs = list(
                list(targets = "_all", className = "dt-center")
            )
        )

        dt_options <- modifyList(default_options, options)

        # Render DataTable
        output$data_table <- renderDT({
            req(data())

            datatable(
                data(),
                extensions = c("Buttons", "Responsive"),
                options = dt_options,
                rownames = FALSE,
                class = "stripe hover order-column nowrap",
                style = "bootstrap5"
            )
        })

        # Handle refresh
        observeEvent(input$refresh_data, {
            session$sendCustomMessage("dtRefresh", session$ns("data_table"))
            showNotification("Data refreshed", type = "success", duration = 2)
        })

        # Handle download
        output$download_data <- downloadHandler(
            filename = function() {
                paste0("nuclearff_data_", Sys.Date(), ".csv")
            },
            content = function(file) {
                write.csv(data(), file, row.names = FALSE)
            }
        )

        # Return reactive values
        list(
            data = data,
            selected_rows = reactive(input$data_table_rows_selected),
            current_page = reactive(input$data_table_rows_current)
        )
    })
}
