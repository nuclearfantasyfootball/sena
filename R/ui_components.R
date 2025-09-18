#' Create Stat Cards
#'
#' Generate a grid of statistic cards for league display
#'
#' @param stats Named list of statistics (name = value, label = description)
#' @return HTML div containing stat cards grid
#' @export
#' @examples
#' create_stat_cards(list("12" = "Active Leagues", "156" = "Total Teams"))
create_stat_cards <- function(stats) {
    tags$div(
        class = "league-stats-grid",
        lapply(names(stats), function(name) {
            label <- stats[[name]]

            # Handle infinity symbol specially
            value_node <- if (tolower(name) %in% c("infinite", "infinity", "∞")) {
                tags$div(class = "stat-value", nff_infinity_svg(size = 180))
            } else {
                tags$div(class = "stat-value", name)
            }

            tags$div(
                class = "stat-card glass-effect",
                value_node,
                tags$div(class = "stat-label", label)
            )
        })
    )
}

#' Create League Hero Row
#'
#' Creates a hero row with logo and text for league pages
#'
#' @param logo_src Character. Path or URL to logo image
#' @param word Character. Word to display next to logo
#' @return HTML div containing hero row
#' @export
league_hero_row <- function(logo_src, word) {
    tags$div(
        class = "league-hero-row",
        tags$img(
            src = logo_src,
            alt = paste(word, "logo"),
            class = "hero-logo"
        ),
        tags$span(toupper(word), class = "hero-text")
    )
}

#' Create League Accordion
#'
#' Generate an accordion for league configuration details
#'
#' @param type Character. Type of league (redraft, dynasty, etc.)
#' @param sections Character vector. Which sections to include
#' @return Card containing accordion
#' @export
create_league_accordion <- function(type,
                                    sections = c(
                                        "overview", "roster", "draft",
                                        "scoring", "transactions"
                                    )) {
    # Section configurations with icon() calls
    section_config <- list(
        overview = list(
            title = "OVERVIEW",
            icon = bs_icon("chevron-double-right") # Direct icon usage
        )
    )

    # Build accordion panels
    panels <- lapply(sections, function(section) {
        config <- section_config[[section]]
        accordion_panel(
            title = tags$span(
                config$icon,
                tags$span(class = "ms-2", config$title)
            ),
            value = section, # Use section name as the value/ID
            md_file(sprintf("www/md/%s/%s_%s.md", type, type, section))
        )
    })

    card(
        # card_header(tags$h5("League Configuration", class = "mb-0")),
        card_body(
            do.call(accordion, c(
                list(id = paste0(type, "_accordion"), class = "league-accordion"),
                panels
            ))
        )
    )
}

#' Create League List Card
#'
#' Generate a card containing list of leagues
#'
#' @param type Character. Type of league
#' @param leagues List. List of league information
#' @return Card containing league list
#' @export
create_league_list <- function(type, leagues) {
    # Determine title based on type
    title <- switch(type,
        "redraft" = "NUCLEARFF REDRAFT LEAGUES",
        "dynasty" = "NUCLEARFF DYNASTY LEAGUES",
        "chopped" = "NUCLEARFF CHOPPED/GUILLOTINE LEAGUES",
        "survivor" = "NUCLEARFF SURVIVOR LEAGUES",
        "NUCLEARFF LEAGUES" # Default
    )

    bslib::card(
        # bslib::card_header(title),
        bslib::card_body(
            tags$div(
                class = "list-group",
                lapply(leagues, create_league_list_item)
            )
        )
    )
}

#' Create Individual League List Item
#'
#' Helper function to create a single league list item
#'
#' @param league List containing league information
#' @return HTML anchor tag for league item
#' @keywords internal
create_league_list_item <- function(league) {
    # Determine status class
    status_class <- if (!is.null(league$status_class)) {
        league$status_class
    } else {
        switch(league$status,
            "FULL" = "danger",
            "FILLED" = "danger",
            "LOCKED" = "danger",
            "STARTUP" = "success",
            "ORPHAN" = "warning",
            "info" # Default
        )
    }

    is_full <- league$status %in% c("FULL", "FILLED")
    is_locked <- identical(league$status, "LOCKED")

    tags$a(
        href = league$url,
        class = paste(
            "list-group-item list-group-item-action league-item",
            if (is_full || is_locked) "is-full" else ""
        ),
        # Tooltip attributes for full leagues
        `data-bs-toggle` = if (is_full || is_locked) "tooltip" else NULL,
        `data-bs-title` = if (is_full) {
            "League has been filled!"
        } else if (is_locked) {
            "League has been locked!"
        } else {
            NULL
        },
        `data-bs-placement` = if (is_full || is_locked) "top" else NULL,
        `data-bs-container` = if (is_full || is_locked) "body" else NULL,
        `aria-disabled` = if (is_full || is_locked) "true" else NULL,
        tabindex = if (is_full || is_locked) "0" else NULL,
        # Content
        tags$img(src = league$logo, alt = league$name, class = "league-logo"),
        tags$div(
            class = "league-copy w-100",
            tags$div(
                class = "d-flex justify-content-between align-items-center",
                tags$h6(league$name, class = "league-title mb-0"),
                tags$small(
                    tags$span(
                        class = paste("badge", paste0("bg-", status_class)),
                        league$status
                    )
                )
            ),
            tags$p(league$details, class = "league-sub mb-0")
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
#' @export
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
