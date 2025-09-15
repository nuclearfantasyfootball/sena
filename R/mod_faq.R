#' FAQ Page Module UI
#'
#' Creates the UI for the FAQ page with accordion sections containing article links
#'
#' @param id Character string. Module namespace ID
#' @return UI element for FAQ page
#' @export
faq_page_ui <- function(id) {
    ns <- NS(id)

    tags$div(
        class = "faq-content-section",
        # Conditional UI: FAQ list or article display
        uiOutput(ns("faq_content"))
    )
}

#' Create Article Link
#'
#' Helper function to create a clickable article link
#'
#' @param ns Namespace function
#' @param article_id Character. Unique ID for the article
#' @param title Character. Article title
#' @param description Character. Article description (optional, ignored)
#' @return HTML div containing article link
#' @keywords internal
create_article_link <- function(ns, article_id, title, description = NULL) {
    tags$div(
        class = "faq-article-item",
        tags$a(
            href = "#",
            class = "faq-article-link text-decoration-none d-block py-2 px-3",
            `data-article-id` = article_id,
            onclick = sprintf(
                "Shiny.setInputValue('%s', '%s', {priority: 'event'})",
                ns("article_clicked"), article_id
            ),
            tags$div(
                class = "d-flex justify-content-between align-items-center",
                tags$div(
                    class = "flex-grow-1",
                    tags$span(class = "faq-article-title fw-bold", title)
                ),
                bs_icon("chevron-right", class = "faq-article-arrow ms-2")
            )
        )
    )
}

#' FAQ Page Module Server
#'
#' Server logic for the FAQ page with integrated article navigation
#'
#' @param id Character string. Module namespace ID
#' @param parent_session Parent session for navigation (optional)
#' @return Reactive values from FAQ page including selected article
#' @export
faq_page_server <- function(id, parent_session = getDefaultReactiveDomain()) {
    moduleServer(id, function(input, output, session) {
        # State management
        current_view <- reactiveVal("list") # "list" or "article"
        selected_article <- reactiveVal(NULL)

        # Article data repository
        article_data <- reactive({
            if (is.null(selected_article())) {
                return(NULL)
            }

            articles <- list(
                "draft-strategy" = list(
                    title = "Drafting Strategy for Beginners",
                    subtitle = "A comprehensive guide to fantasy football draft fundamentals",
                    author = "NuclearFF Team",
                    author_avatar = "logos/nuclearff-logo.png",
                    created = "2024-01-15",
                    updated = "2024-12-15",
                    rmd_file = "content/faq/draft-strategy.Rmd"
                ),
                "faab-bidding" = list(
                    title = "FAAB Budget and Bidding",
                    subtitle = "Free Agent Acquisition Budget strategy and best practices",
                    author = "NuclearFF Team",
                    author_avatar = "logos/nuclearff-logo.png",
                    created = "2024-02-05",
                    updated = "2024-11-28",
                    rmd_file = "content/faq/faab-bidding.Rmd"
                ),
                "waiver-strategy" = list(
                    title = "Navigating Waivers and Strategy",
                    subtitle = "Strategic thinking about waiver wire pickups and timing",
                    author = "NuclearFF Team",
                    author_avatar = "logos/nuclearff-logo.png",
                    created = "2024-02-10",
                    updated = "2024-11-25",
                    rmd_file = "content/faq/waiver-strategy.Rmd"
                )
            )

            articles[[selected_article()]] %||% NULL
        })

        # Main content output - switches between FAQ list and article
        output$faq_content <- renderUI({
            if (current_view() == "article" && !is.null(selected_article())) {
                # Article view
                render_article_view(session$ns, article_data())
            } else {
                # FAQ list view
                render_faq_list(session$ns)
            }
        })

        # Handle article clicks
        observeEvent(input$article_clicked, {
            selected_article(input$article_clicked)
            current_view("article")

            # Smooth scroll to top
            session$sendCustomMessage("scrollToTop", list())
        })

        # Handle back to FAQ
        observeEvent(input$back_to_faq, {
            current_view("list")
            selected_article(NULL)
        })

        # Return reactive values
        list(
            page_loaded = reactive(TRUE),
            current_view = current_view,
            selected_article = selected_article
        )
    })
}

#' Render FAQ List View
#' @keywords internal
render_faq_list <- function(ns) {
    card(
        full_screen = TRUE,
        card_header(
            tags$h4(
                class = "mb-0",
                ""
            )
        ),
        card_body(
            class = "p-4",
            tags$div(
                class = "text-center mb-4",
                tags$h2("Frequently Asked Questions"),
                tags$p(
                    class = "lead text-muted",
                    "Find answers to common fantasy football questions organized by topic."
                )
            ),

            # FAQ Accordion
            accordion(
                id = "faq_accordion",
                class = "faq-accordion",
                accordion_panel(
                    title = tags$span(
                        bs_icon("pencil-square"),
                        tags$span(class = "ms-2", "DRAFTING")
                    ),
                    value = "drafting",
                    tags$div(
                        class = "faq-article-list",
                        create_article_link(
                            ns, "draft-strategy",
                            "What is the best draft strategy for beginners?"
                        ),
                        create_article_link(
                            ns, "auction-drafts",
                            "How do auction drafts work?"
                        ),
                        create_article_link(
                            ns, "draft-preparation",
                            "How should I prepare for my fantasy draft?"
                        )
                    )
                ),
                accordion_panel(
                    title = tags$span(
                        bs_icon("cash-stack"),
                        tags$span(class = "ms-2", "WAIVERS AND FAAB")
                    ),
                    value = "waivers",
                    tags$div(
                        class = "faq-article-list",
                        create_article_link(
                            ns, "waiver-priority",
                            "How does waiver priority work?"
                        ),
                        create_article_link(
                            ns, "faab-bidding",
                            "What is FAAB and how do I use it effectively?"
                        ),
                        create_article_link(
                            ns, "waiver-strategy",
                            "When should I use my waiver priority?"
                        )
                    )
                ),
                accordion_panel(
                    title = tags$span(
                        bs_icon("calculator"),
                        tags$span(class = "ms-2", "SCORING")
                    ),
                    value = "scoring",
                    tags$div(
                        class = "faq-article-list",
                        create_article_link(
                            ns, "ppr-vs-standard",
                            "What's the difference between PPR and Standard scoring?"
                        ),
                        create_article_link(
                            ns, "superflex-scoring",
                            "How does Superflex scoring work?"
                        ),
                        create_article_link(
                            ns, "idp-scoring",
                            "What is IDP scoring?"
                        )
                    )
                )
            )
        )
    )
}

#' Render Article View
#' @keywords internal
render_article_view <- function(ns, article_data) {
    if (is.null(article_data)) {
        return(tags$div(
            class = "alert alert-warning",
            "Article not found."
        ))
    }

    fluidPage(
        class = "article-content-section",

        # Article container
        tags$div(
            class = "container-fluid",
            tags$div(
                class = "row justify-content-center",
                tags$div(
                    class = "col-12 col-lg-10 col-xl-8",

                    # Article header
                    tags$div(
                        class = "article-header mb-4",
                        tags$h1(
                            class = "article-title display-4 fw-bold mb-3",
                            article_data$title
                        ),
                        if (!is.null(article_data$subtitle) && nzchar(article_data$subtitle)) {
                            tags$h2(
                                class = "article-subtitle fs-4 text-muted mb-4",
                                article_data$subtitle
                            )
                        },
                        # Article metadata
                        tags$div(
                            class = "article-meta d-flex align-items-center mb-4 pb-4 border-bottom",
                            tags$div(
                                class = "author-info d-flex align-items-center",
                                tags$img(
                                    src = article_data$author_avatar,
                                    class = "author-avatar rounded-circle me-3",
                                    style = "width: 50px; height: 50px; object-fit: contain;",
                                    alt = paste(article_data$author, "avatar")
                                ),
                                tags$div(
                                    class = "author-details",
                                    tags$div(
                                        class = "author-name fw-semibold fs-6",
                                        article_data$author
                                    ),
                                    tags$div(
                                        class = "article-dates text-muted small",
                                        tags$span("Created: ", article_data$created),
                                        tags$br(),
                                        tags$span("Updated: ", article_data$updated)
                                    )
                                )
                            )
                        )
                    ),

                    # Article content
                    tags$div(
                        class = "article-body",
                        render_rmd_content(article_data$rmd_file)
                    ),

                    # Navigation
                    tags$div(
                        class = "article-nav-buttons mt-5",
                        actionButton(
                            ns("back_to_faq"),
                            "Back to FAQ",
                            class = "btn btn-outline-secondary btn-sm w-100",
                            icon = icon("arrow-left")
                        )
                    )
                )
            )
        )
    )
}

#' Render R Markdown Content
#' @keywords internal
render_rmd_content <- function(rmd_file) {
    if (!is.null(rmd_file) && file.exists(rmd_file)) {
        tryCatch(
            {
                # Create temporary HTML file
                temp_html <- tempfile(fileext = ".html")

                # Render Rmd to HTML
                rmarkdown::render(
                    input = rmd_file,
                    output_file = temp_html,
                    output_format = rmarkdown::html_fragment(
                        self_contained = FALSE,
                        section_divs = FALSE
                    ),
                    quiet = TRUE,
                    envir = new.env()
                )

                # Read HTML content
                html_content <- readLines(temp_html, warn = FALSE)
                html_string <- paste(html_content, collapse = "\n")

                # Clean up
                unlink(temp_html)

                # Return as HTML
                HTML(html_string)
            },
            error = function(e) {
                tags$div(
                    class = "alert alert-warning",
                    tags$h4(class = "alert-heading", "Content Loading Error"),
                    tags$p(paste("Unable to render article content:", e$message))
                )
            }
        )
    } else {
        tags$div(
            class = "alert alert-info",
            tags$h4(class = "alert-heading", "Article Coming Soon"),
            tags$p("This article is currently being written and will be available soon.")
        )
    }
}
