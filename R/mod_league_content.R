#' Create Redraft League Content
#'
#' Generate content specific to redraft leagues
#'
#' @return UI content for redraft leagues
#' @export
create_redraft_content <- function() {
    config <- app_config()

    tags$div(
        create_stat_cards(
            list(
                "12" = "Active Leagues",
                "156" = "Total Teams",
                "$50" = "Avg Buy-in"
            )
        ),
        tags$hr(class = "league-section-divider"),
        create_league_accordion("redraft", sections = "overview"),
        # Add LEAGUES title before league list
        tags$div(
            class = "league-hero-row",
            tags$img(
                src = "https://raw.githubusercontent.com/NuclearAnalyticsLab/nuclearff/refs/heads/main/inst/logos/png/nuclearff-2color.png",
                alt = "Leagues logo",
                class = "hero-logo"
            ),
            tags$span("LEAGUES", class = "hero-text")
        ),
        # List of leagues
        create_league_list("redraft", list(
            list(
                name = "NUCLEARFF REDRAFT",
                url = "https://sleeper.com/leagues/1240509989819273216",
                logo = "logos/Redraft/Redraft-Radioactive-Hex-Transparent.png",
                status = "FILLED",
                details = "10 TEAM | PPR | 3 FLEX"
            )
        ))
    )
}

#' Create Dynasty League Content
#'
#' Generate content specific to dynasty leagues
#'
#' @return UI content for dynasty leagues
#' @export
create_dynasty_content <- function() {
    config <- app_config()

    tags$div(
        create_stat_cards(
            list(
                "8" = "Active Dynasties",
                "3.2" = "Avg Years Running",
                "$75" = "Avg Buy-in"
            )
        ),
        tags$hr(class = "league-section-divider"),
        create_league_accordion("dynasty", sections = "overview"),
        # Add LEAGUES title before league list
        tags$div(
            class = "league-hero-row",
            tags$img(
                src = "https://raw.githubusercontent.com/NuclearAnalyticsLab/nuclearff/refs/heads/main/inst/logos/png/nuclearff-2color.png",
                alt = "Leagues logo",
                class = "hero-logo"
            ),
            tags$span("LEAGUES", class = "hero-text")
        ),
        # List of leagues
        create_league_list("dynasty", list(
            list(
                name = "NUCLEARFF DYNASTY",
                url = "https://sleeper.com/leagues/1190192546172342272",
                logo = "logos/Dynasty/Dynasty-Fission-Lightning-Circle-Transparent.png",
                status = "FILLED",
                details = "12 TEAM | PPR | SUPERFLEX"
            )
        ))
    )
}

#' Create Chopped League Content
#'
#' Generate content specific to chopped/guillotine leagues
#'
#' @return UI content for chopped leagues
#' @export
create_chopped_content <- function() {
    config <- app_config()

    tags$div(
        create_stat_cards(
            list(
                "3" = "Active Leagues",
                "16" = "Teams per League",
                "Week 9" = "Avg Elimination"
            )
        ),
        tags$hr(class = "league-section-divider"),
        create_league_accordion("chopped", sections = "overview"),
        # Add LEAGUES title before league list
        tags$div(
            class = "league-hero-row",
            tags$img(
                src = "https://raw.githubusercontent.com/NuclearAnalyticsLab/nuclearff/refs/heads/main/inst/logos/png/nuclearff-2color.png",
                alt = "Leagues logo",
                class = "hero-logo"
            ),
            tags$span("LEAGUES", class = "hero-text")
        ),
        # List of leagues
        create_league_list("chopped", list(
            list(
                name = "NUCLEARFF CHOPPED OG $10",
                url = "https://sleeper.com/leagues/1262207133378695168",
                logo = "logos/Chopped/NUCLEARFF-Chopped-Blue-Transparent.png",
                status = "FILLED",
                details = "16 TEAM | PPR | 6PT PASS TD"
            ),
            list(
                name = "NUCLEARFF CHOPPED $10 02",
                url = "https://sleeper.com/leagues/1261897006209581056",
                logo = "logos/Chopped/NUCLEARFF-Chopped-Pink-Transparent.png",
                status = "FILLED",
                details = "16 TEAM | PPR | 6PT PASS TD"
            ),
            list(
                name = "NUCLEARFF $25 CHOPPED",
                url = "https://sleeper.com/leagues/1262195970007912448",
                logo = "logos/Chopped/NUCLEARFF-Chopped-Green-Transparent.png",
                status = "FILLED",
                details = "16 TEAM | PPR | 6PT PASS TD"
            )
        ))
    )
}

#' Create Survivor League Content
#'
#' Generate content specific to survivor leagues
#'
#' @return UI content for survivor leagues
#' @export
create_survivor_content <- function() {
    config <- app_config()

    tags$div(
        create_stat_cards(
            list(
                "W" = "Winning is survival",
                "infinite" = "Teams"
            )
        ),
        tags$hr(class = "league-section-divider"),
        create_league_accordion("survivor", sections = "overview"),
        # Add LEAGUES title before league list
        tags$div(
            class = "league-hero-row",
            tags$img(
                src = "https://raw.githubusercontent.com/NuclearAnalyticsLab/nuclearff/refs/heads/main/inst/logos/png/nuclearff-2color.png",
                alt = "Leagues logo",
                class = "hero-logo"
            ),
            tags$span("LEAGUES", class = "hero-text")
        ),
        # List of leagues
        create_league_list("survivor", list(
            list(
                name = "NUCLEARFF Survivor (Pick 'Em) 2025",
                url = "https://sleeper.com/leagues/1256760468719030272",
                logo = "logos/Survivor/Survivor-Diamond-Fire-Transparent.png",
                status = "LOCKED",
                status_class = "danger",
                details = "$10 ENTRY | PICK 'EM"
            )
        ))
    )
}
