#' Article Display Module UI
#'
#' Creates a fluid page UI for displaying R Markdown articles with structured layout
#'
#' @param id Character string. Module namespace ID
#' @return UI element for article display page
#' @export
article_display_ui <- function(id) {
    ns <- NS(id)

    fluidPage(
        class = "article-content-section",

        # Article container with max width and centering
        tags$div(
            class = "container-fluid",
            tags$div(
                class = "row justify-content-center",
                tags$div(
                    class = "col-12 col-lg-10 col-xl-8",

                    # Article header section
                    tags$div(
                        class = "article-header mb-4",
                        uiOutput(ns("article_title")),
                        uiOutput(ns("article_subtitle")),
                        uiOutput(ns("article_meta"))
                    ),

                    # Article content from R Markdown
                    tags$div(
                        class = "article-body",
                        uiOutput(ns("article_content"))
                    ),

                    # Article navigation
                    tags$div(
                        class = "article-nav-buttons mt-5",
                        actionButton(
                            ns("back_to_faq"),
                            "Back to FAQ",
                            class = "btn btn-outline-secondary btn-sm w-100",
                            icon = icon("arrow-left")
                        ),
                        tags$div(
                            class = "ms-auto",
                            # Future: Next/Previous article buttons could go here
                        )
                    )
                )
            )
        )
    )
}

#' Article Display Module Server
#'
#' Server logic for displaying R Markdown articles with metadata
#'
#' @param id Character string. Module namespace ID
#' @param article_id Reactive. The ID of the article to display
#' @param parent_session Parent session for navigation
#' @return Reactive values from article display
#' @export
article_display_server <- function(id, article_id = reactive(NULL), parent_session = getDefaultReactiveDomain()) {
    moduleServer(id, function(input, output, session) {
        # Article data repository - this would typically come from a database or file system
        article_data <- reactive({
            req(article_id())

            # Define article metadata and content paths
            articles <- list(
                "draft-strategy" = list(
                    title = "What is the best draft strategy for beginners?",
                    subtitle = "A comprehensive guide to fantasy football draft fundamentals",
                    author = "NuclearFF Team",
                    author_avatar = "logos/nuclearff-logo.png", # Your logo
                    created = "2024-01-15",
                    updated = "2024-12-15",
                    rmd_file = "content/faq/draft-strategy.Rmd"
                ),
                "faab-bidding" = list(
                    title = "What is FAAB and how do I use it effectively?",
                    subtitle = "Free Agent Acquisition Budget strategy and best practices",
                    author = "NuclearFF Team",
                    author_avatar = "logos/nuclearff-logo.png", # Your logo
                    created = "2024-02-05",
                    updated = "2024-11-28",
                    rmd_file = "content/faq/faab-bidding.Rmd"
                ),
                "waiver-strategy" = list(
                    title = "When should I use my waiver priority?",
                    subtitle = "Strategic thinking about waiver wire pickups and timing",
                    author = "NuclearFF Team",
                    author_avatar = "logos/nuclearff-logo.png", # Your logo
                    created = "2024-02-10",
                    updated = "2024-11-25",
                    rmd_file = "content/faq/waiver-strategy.Rmd"
                )
            )

            # Return article data or default if not found
            articles[[article_id()]] %||% list(
                title = "Article Not Found",
                subtitle = "The requested article could not be located",
                author = "NuclearFF Team",
                created = Sys.Date(),
                updated = Sys.Date(),
                rmd_file = NULL
            )
        })

        # Render article title
        output$article_title <- renderUI({
            req(article_data())
            tags$h1(
                class = "article-title display-4 fw-bold mb-3",
                article_data()$title
            )
        })

        # Render article subtitle
        output$article_subtitle <- renderUI({
            req(article_data())
            if (!is.null(article_data()$subtitle) && nzchar(article_data()$subtitle)) {
                tags$h2(
                    class = "article-subtitle fs-4 text-muted mb-4",
                    article_data()$subtitle
                )
            }
        })

        # Render article metadata
        output$article_meta <- renderUI({
            req(article_data())

            # Get author initials for avatar
            author_initial <- substr(article_data()$author, 1, 1)

            tags$div(
                class = "article-meta d-flex align-items-center mb-4 pb-4 border-bottom",
                tags$div(
                    class = "author-info d-flex align-items-center",
                    tags$img(
                        src = article_data()$author_avatar, # Use the logo path from article data
                        class = "author-avatar rounded-circle me-3",
                        style = "width: 50px; height: 50px; object-fit: contain;",
                        alt = paste(article_data()$author, "avatar")
                    ),
                    tags$div(
                        class = "author-details",
                        tags$div(
                            class = "author-name fw-semibold fs-6",
                            article_data()$author
                        ),
                        tags$div(
                            class = "article-dates text-muted small",
                            tags$span("Created: ", article_data()$created),
                            tags$br(),
                            tags$span("Updated: ", article_data()$updated)
                        )
                    )
                )
            )
        })

        # Render R Markdown content
        output$article_content <- renderUI({
            req(article_data())

            rmd_file <- article_data()$rmd_file

            if (!is.null(rmd_file) && file.exists(rmd_file)) {
                # Render R Markdown to HTML
                tryCatch(
                    {
                        # Create temporary HTML file
                        temp_html <- tempfile(fileext = ".html")

                        # Render Rmd to HTML with custom options
                        rmarkdown::render(
                            input = rmd_file,
                            output_file = temp_html,
                            output_format = rmarkdown::html_fragment(
                                self_contained = FALSE,
                                section_divs = FALSE
                            ),
                            quiet = TRUE,
                            envir = new.env() # Isolate rendering environment
                        )

                        # Read the HTML content
                        html_content <- readLines(temp_html, warn = FALSE)
                        html_string <- paste(html_content, collapse = "\n")

                        # Clean up temporary file
                        unlink(temp_html)

                        # Return as HTML
                        HTML(html_string)
                    },
                    error = function(e) {
                        # Error handling for R Markdown rendering
                        tags$div(
                            class = "alert alert-warning",
                            tags$h4(class = "alert-heading", "Content Loading Error"),
                            tags$p(paste("Unable to render article content:", e$message)),
                            tags$hr(),
                            tags$p(
                                class = "mb-0",
                                "Please check that the article file exists and is properly formatted."
                            )
                        )
                    }
                )
            } else {
                tags$div(
                    class = "alert alert-info",
                    tags$h4(class = "alert-heading", "Article Coming Soon"),
                    tags$p("This article is currently being written and will be available soon."),
                    tags$hr(),
                    tags$p(
                        class = "mb-0",
                        "Check back later for comprehensive coverage of this topic."
                    )
                )
            }
        })

        # Handle back to FAQ navigation
        observeEvent(input$back_to_faq, {
            updateTabsetPanel(parent_session, "topnav", selected = "faq")
        })

        # Return reactive values
        list(
            current_article = article_id,
            article_loaded = reactive(!is.null(article_data()))
        )
    })
}
