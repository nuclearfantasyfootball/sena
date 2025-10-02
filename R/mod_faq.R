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
                icon("chevron-right", class = "faq-article-arrow ms-2")
            )
        )
    )
}

#' Extract Metadata from R Markdown File
#'
#' Reads YAML frontmatter from an Rmd file using rmarkdown's built-in parser
#'
#' @param rmd_file Character. Path to the R Markdown file
#' @return List containing metadata fields
#' @keywords internal
extract_rmd_metadata <- function(rmd_file) {
    if (!file.exists(rmd_file)) {
        return(default_metadata())
    }

    tryCatch(
        {
            # Use rmarkdown's built-in YAML parser - most reliable approach
            metadata <- rmarkdown::yaml_front_matter(rmd_file)

            # Ensure required fields with defaults
            list(
                title = metadata$title %||% "Untitled Article",
                subtitle = metadata$subtitle %||% NULL,
                tagline = metadata$tagline %||% metadata$title %||% "Untitled Article",
                author = metadata$author %||% "NuclearFF Team",
                created = as.character(metadata$created %||% metadata$date %||% Sys.Date()),
                updated = as.character(metadata$updated %||% metadata$date %||% Sys.Date()),
                author_avatar = metadata$author_avatar %||% "logos/nuclearff-logo.png",
                category = metadata$category %||% "general" # For organizing into accordion sections
            )
        },
        error = function(e) {
            warning("Error reading metadata from ", rmd_file, ": ", e$message)
            default_metadata()
        }
    )
}

#' Default Metadata
#'
#' Returns default metadata structure
#'
#' @return List with default metadata
#' @keywords internal
default_metadata <- function() {
    list(
        title = "Article Coming Soon",
        subtitle = NULL,
        tagline = "Article Coming Soon",
        author = "NuclearFF Team",
        created = as.character(Sys.Date()),
        updated = as.character(Sys.Date()),
        author_avatar = "logos/nuclearff-logo.png",
        category = "general"
    )
}

#' Get All FAQ Articles
#'
#' Scans the FAQ directory and returns metadata for all articles
#'
#' @param faq_dir Character. Directory containing FAQ Rmd files
#' @return Named list of article metadata, keyed by article ID
#' @keywords internal
get_all_faq_articles <- function(faq_dir = "content/faq") {
    if (!dir.exists(faq_dir)) {
        warning("FAQ directory does not exist: ", faq_dir)
        return(list())
    }

    # Find all Rmd files in the FAQ directory
    rmd_files <- list.files(faq_dir, pattern = "\\.Rmd$", full.names = TRUE)

    if (length(rmd_files) == 0) {
        warning("No Rmd files found in: ", faq_dir)
        return(list())
    }

    articles <- list()

    for (file_path in rmd_files) {
        # Generate article ID from filename (without extension)
        article_id <- tools::file_path_sans_ext(basename(file_path))

        # Extract metadata from the file
        metadata <- extract_rmd_metadata(file_path)
        metadata$rmd_file <- file_path
        metadata$article_id <- article_id

        articles[[article_id]] <- metadata
    }

    return(articles)
}

#' Create Article Link from Metadata
#'
#' Helper function to create a clickable article link using metadata
#'
#' @param ns Namespace function
#' @param article_id Character. Unique ID for the article
#' @param metadata List. Article metadata containing tagline
#' @return HTML div containing article link
#' @keywords internal
create_article_link_from_metadata <- function(ns, article_id, metadata) {
    tagline <- metadata$tagline %||% metadata$title %||% "Untitled Article"

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
                    tags$span(class = "faq-article-title fw-bold", tagline)
                ),
                icon("chevron-right", class = "faq-article-arrow ms-2")
            )
        )
    )
}

#' FAQ Page Module Server (Updated)
#'
#' Server logic for the FAQ page with Rmd metadata reading
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

        # Get all FAQ articles from directory - reactive for dynamic updates
        all_articles <- reactive({
            get_all_faq_articles("content/faq")
        })

        # Article data repository - now reads from Rmd files
        article_data <- reactive({
            req(selected_article())

            article_id <- selected_article()
            articles <- all_articles()

            if (article_id %in% names(articles)) {
                return(articles[[article_id]])
            } else {
                return(default_metadata())
            }
        })

        # Main content output - switches between FAQ list and article
        output$faq_content <- renderUI({
            if (current_view() == "article" && !is.null(selected_article())) {
                # Article view
                render_article_view(session$ns, article_data())
            } else {
                # FAQ list view - now dynamically generated
                render_dynamic_faq_list(session$ns, all_articles())
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
            selected_article = selected_article,
            available_articles = all_articles
        )
    })
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
                        render_html_content(article_data$article_id)
                    ),

                    # Navigation
                    tags$div(
                        class = "article-nav-buttons mt-5",
                        actionButton(
                            ns("back_to_faq"),
                            "Back",
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

#' Render Pre-Rendered HTML Content
#' @keywords internal
render_html_content <- function(article_id) {
    html_file <- file.path("www/content/faq", paste0(article_id, ".html"))

    if (file.exists(html_file)) {
        includeHTML(html_file)
    } else {
        tags$div(
            class = "alert alert-info",
            "This article is not yet available."
        )
    }
}


#' Updated Dynamic FAQ List Renderer
#'
#' Renders FAQ list with proper ordering from config
#'
#' @param ns Namespace function
#' @param articles List of all articles
#' @keywords internal
render_dynamic_faq_list <- function(ns, articles) {
    if (length(articles) == 0) {
        return(tags$div(
            class = "alert alert-info",
            "No FAQ articles found. Please add Rmd files to content/faq/ directory."
        ))
    }

    # Load ordering configuration
    config <- load_faq_order_config()

    # Order articles according to config
    ordered_categories <- order_articles_by_config(articles, config)

    card(
        full_screen = TRUE,
        # No card_header() only card_body()
        card_body(
            class = "p-4",

            # Dynamic FAQ Accordion with proper ordering
            do.call(accordion, c(
                list(
                    id = "faq_accordion",
                    class = "faq-accordion",
                    open = FALSE # Ensure no panels are open by default
                ),
                # Generate accordion panels in configured order
                lapply(names(ordered_categories), function(cat_name) {
                    cat_articles <- ordered_categories[[cat_name]]
                    cat_info <- get_category_info(cat_name, config)

                    accordion_panel(
                        title = tags$span(
                            cat_info$icon,
                            tags$span(class = "ms-2", cat_info$title)
                        ),
                        value = cat_name,
                        # Do NOT add 'open = TRUE' here
                        tags$div(
                            class = "faq-article-list",
                            # Generate article links in specified order
                            lapply(names(cat_articles), function(article_id) {
                                create_article_link_from_metadata(
                                    ns,
                                    article_id,
                                    cat_articles[[article_id]]
                                )
                            })
                        )
                    )
                })
            ))
        )
    )
}

#' Load FAQ Order Configuration
#'
#' Reads the FAQ order configuration file to determine category and article ordering
#'
#' @param config_file Character. Path to the configuration file
#' @return List containing ordered categories and articles
#' @export
load_faq_order_config <- function(config_file = "content/faq/faq_order.yml") {
    if (!file.exists(config_file)) {
        warning("FAQ order config file not found: ", config_file)
        return(get_default_faq_order())
    }

    tryCatch(
        {
            # Use rmarkdown's YAML parser for consistency
            config <- rmarkdown::yaml_front_matter(config_file)

            # If no frontmatter, try reading as pure YAML
            if (length(config) == 0) {
                config <- yaml::yaml.load_file(config_file)
            }

            return(config)
        },
        error = function(e) {
            warning("Error reading FAQ order config: ", e$message)
            return(get_default_faq_order())
        }
    )
}

#' Get Default FAQ Order
#'
#' Returns default ordering if no config file exists
#'
#' @return List with default category order
#' @keywords internal
get_default_faq_order <- function() {
    list(
        categories = list(
            list(
                name = "general",
                title = "GENERAL",
                icon = "football",
                articles = list()
            ),
            list(
                name = "drafting",
                title = "DRAFTING",
                icon = "ranking-star",
                articles = list()
            ),
            list(
                name = "rosters",
                title = "ROSTERS",
                icon = "users-rays",
                articles = list()
            ),
            list(
                name = "scoring",
                title = "SCORING",
                icon = "magnifying-glass-chart",
                articles = list()
            ),
            list(
                name = "trading",
                title = "TRADING",
                icon = "handshake-angle",
                articles = list()
            ),
            list(
                name = "waivers",
                title = "WAIVER WIRE",
                icon = "user-plus",
                articles = list()
            )
        )
    )
}

#' Order Articles According to Configuration
#'
#' Takes discovered articles and orders them according to the config file
#'
#' @param articles List. All discovered articles from Rmd files
#' @param config List. Configuration from faq_order file
#' @return List of ordered articles by category
#' @keywords internal
order_articles_by_config <- function(articles, config) {
    if (!"categories" %in% names(config)) {
        # Fallback to simple category grouping
        return(split(articles, sapply(articles, function(x) x$category %||% "general")))
    }

    ordered_categories <- list()

    for (cat_config in config$categories) {
        cat_name <- cat_config$name

        # Get all articles for this category
        cat_articles <- articles[sapply(articles, function(x) {
            (x$category %||% "general") == cat_name
        })]

        if (length(cat_articles) == 0) {
            next # Skip empty categories
        }

        # Order articles within category if specified
        if ("articles" %in% names(cat_config) && length(cat_config$articles) > 0) {
            ordered_articles <- list()

            # First, add articles in specified order
            for (article_ref in cat_config$articles) {
                # Find article by tagline or article ID
                matching_article <- find_article_by_reference(cat_articles, article_ref)
                if (!is.null(matching_article)) {
                    ordered_articles <- append(ordered_articles, matching_article, length(ordered_articles))
                    # Remove from remaining articles
                    cat_articles <- cat_articles[!names(cat_articles) %in% names(matching_article)]
                }
            }

            # Add any remaining articles not specified in order
            ordered_articles <- append(ordered_articles, cat_articles, length(ordered_articles))
            cat_articles <- ordered_articles
        }

        if (length(cat_articles) > 0) {
            ordered_categories[[cat_name]] <- cat_articles
        }
    }

    # Add any categories not specified in config
    remaining_categories <- setdiff(
        unique(sapply(articles, function(x) x$category %||% "general")),
        names(ordered_categories)
    )

    for (cat_name in remaining_categories) {
        cat_articles <- articles[sapply(articles, function(x) {
            (x$category %||% "general") == cat_name
        })]
        if (length(cat_articles) > 0) {
            ordered_categories[[cat_name]] <- cat_articles
        }
    }

    return(ordered_categories)
}

#' Get Category Info with Config Override
#'
#' Gets category display info, allowing config file to override defaults
#'
#' @param cat_name Character. Category name
#' @param config List. Configuration object
#' @return List with title and icon
#' @keywords internal
get_category_info <- function(cat_name, config) {
    # Default category info
    default_info <- list(
        "general" = list(title = "GENERAL", icon = "football"),
        "drafting" = list(title = "DRAFTING", icon = "ranking-star"),
        "rosters" = list(title = "ROSTERS", icon = "users-rays"),
        "scoring" = list(title = "SCORING", icon = "magnifying-glass-chart"),
        "trading" = list(title = "TRADING", icon = "handshake-angle"),
        "waivers" = list(title = "WAIVER WIRE", icon = "user-plus")
    )

    # Check if config overrides this category
    if ("categories" %in% names(config)) {
        for (cat_config in config$categories) {
            if (cat_config$name == cat_name) {
                return(list(
                    title = cat_config$title %||% default_info[[cat_name]]$title %||% toupper(cat_name),
                    icon = icon(cat_config$icon %||% default_info[[cat_name]]$icon %||% "football")
                ))
            }
        }
    }

    # Fall back to defaults
    info <- default_info[[cat_name]] %||% list(title = toupper(cat_name), icon = "football")
    return(list(
        title = info$title,
        icon = icon(info$icon)
    ))
}

#' Find Article by Reference
#'
#' Finds an article by tagline, title, or article ID
#'
#' @param articles List. Articles to search
#' @param reference Character. Reference to match (tagline, title, or ID)
#' @return List with single article or NULL
#' @keywords internal
find_article_by_reference <- function(articles, reference) {
    # Try exact match on article ID first
    if (reference %in% names(articles)) {
        result <- list()
        result[[reference]] <- articles[[reference]]
        return(result)
    }

    # Try matching tagline or title
    for (article_id in names(articles)) {
        article <- articles[[article_id]]
        if (identical(article$tagline, reference) ||
            identical(article$title, reference)) {
            result <- list()
            result[[article_id]] <- article
            return(result)
        }
    }

    return(NULL)
}

#' Render FAQ Articles to HTML
#'
#' Pre-renders all `.Rmd` articles from content/faq/ to www/content/faq/.
#'
#' @param input_dir Path to the source Rmd FAQ files.
#' @param output_dir Path where rendered HTML files should be stored.
#' @param quiet Logical, suppress rmarkdown output if TRUE.
#' @return Invisibly returns a vector of rendered HTML file paths.
#' @export
render_faq_articles <- function(input_dir = here::here("content/faq"),
                                output_dir = here::here("www/content/faq"),
                                quiet = TRUE) {
    # normalize paths (turns relative into absolute)
    input_dir <- normalizePath(input_dir, mustWork = TRUE)
    output_dir <- normalizePath(output_dir, mustWork = FALSE)

    if (!dir.exists(output_dir)) {
        dir.create(output_dir, recursive = TRUE)
        message("Created output directory: ", output_dir)
    }

    rmd_files <- list.files(input_dir, "\\.Rmd$", full.names = TRUE)

    if (length(rmd_files) == 0) {
        warning("No Rmd files found in: ", input_dir)
        return(invisible(character()))
    }

    out_files <- character(length(rmd_files))

    for (i in seq_along(rmd_files)) {
        rmd <- rmd_files[[i]]
        out_file <- file.path(
            output_dir,
            paste0(tools::file_path_sans_ext(basename(rmd)), ".html")
        )

        rmarkdown::render(
            input = rmd,
            output_file = out_file,
            output_format = rmarkdown::html_fragment(
                self_contained = FALSE,
                section_divs = FALSE
            ),
            quiet = quiet,
            envir = new.env()
        )

        out_files[[i]] <- out_file
        message("Rendered: ", basename(rmd), " → ", out_file)
    }

    invisible(out_files)
}
