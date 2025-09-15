#' Navigation UI Component
#'
#' Creates navigation elements for header/sidebar
#'
#' @param id Character string. Component namespace ID
#' @param type Character. Type of navigation ("header", "sidebar")
#' @return UI element with navigation components
#' @export
navigation_ui <- function(id, type = "header") {
    ns <- NS(id)

    if (type == "header") {
        tags$div(
            class = "social-links d-flex align-items-center",
            # Direct social links without bs_icon wrapper issues
            tags$a(
                href = "https://x.com/nuclearffnolan",
                target = "_blank",
                title = "X / Twitter",
                class = "social-link",
                `aria-label` = "Follow on X",
                bs_icon("twitter-x")
            ),
            tags$a(
                href = "https://discord.gg/9sJQ4yYkkF",
                target = "_blank",
                title = "Discord",
                class = "social-link",
                `aria-label` = "Join Discord",
                bs_icon("discord")
            ),
            tags$a(
                href = "https://github.com/nuclearfantasyfootball",
                target = "_blank",
                title = "GitHub",
                class = "social-link",
                `aria-label` = "View on GitHub",
                bs_icon("github")
            ),
        )
    } else {
        # Sidebar navigation if needed
        tags$div("Sidebar navigation placeholder")
    }
}

#' Social Links UI Component
#'
#' Create social media links
#'
#' @param id Character string. Component namespace ID
#' @return UI element with social links
#' @export
social_links_ui <- function(id) {
    ns <- NS(id)

    tags$div(
        class = "social-links-group",
        tags$a(
            href = "https://x.com/nuclearffnolan",
            target = "_blank",
            title = "X / Twitter",
            class = "social-link",
            `aria-label` = "Follow on X",
            icon("x-twitter")
        ),
        tags$a(
            href = "https://discord.gg/9sJQ4yYkkF",
            target = "_blank",
            title = "Discord",
            class = "social-link",
            `aria-label` = "Join Discord",
            icon("discord")
        ),
        tags$a(
            href = "https://github.com/nuclearfantasyfootball",
            target = "_blank",
            title = "GitHub",
            class = "social-link",
            `aria-label` = "View on GitHub",
            icon("github")
        )
    )
}
