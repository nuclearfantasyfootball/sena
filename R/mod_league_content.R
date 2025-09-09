#' Create Redraft League Content
#'
#' Generate content specific to redraft leagues
#'
#' @return UI content for redraft leagues
#' @export
create_redraft_content <- function() {
    config <- app_config()

    tags$div(
        league_hero_row(config$external_resources$logo_url, "Redraft"),
        create_stat_cards(
            list(
                "12" = "Active Leagues",
                "156" = "Total Teams",
                "$50" = "Avg Buy-in",
                "89%" = "Return Rate"
            )
        ),
        tags$hr(class = "my-4"),
        create_league_accordion("redraft"),
        create_league_list("redraft", list(
            list(
                name = "Nuclear Football",
                url = "https://sleeper.com/leagues/1240509989819273216",
                logo = "logos/redraft-logo.png",
                status = "FULL",
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
        league_hero_row(config$external_resources$logo_url, "Dynasty"),
        create_stat_cards(
            list(
                "8" = "Active Dynasties",
                "3.2" = "Avg Years Running",
                "$75" = "Avg Buy-in",
                "94%" = "Retention Rate"
            )
        ),
        tags$hr(class = "my-4"),
        create_league_accordion("dynasty"),
        create_league_list("dynasty", list(
            list(
                name = "NUCLEARFF DYNASTY",
                url = "https://sleeper.com/leagues/1190192546172342272",
                logo = "logos/dynasty-logo.png",
                status = "FULL",
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
        league_hero_row(config$external_resources$logo_url, "Chopped"),
        create_stat_cards(
            list(
                "3" = "Active Leagues",
                "16" = "Teams per League",
                "Week 9" = "Avg Elimination"
            )
        ),
        tags$hr(class = "my-4"),
        create_league_accordion("chopped"),
        create_league_list("chopped", list(
            list(
                name = "NUCLEARFF GUILLOTINE $10",
                url = "https://sleeper.com/leagues/1240503074590568448",
                logo = "logos/guillotine-logo.png",
                status = "FULL",
                details = "$10 ENTRY | 16 TEAM | PPR | 6PT PASS TD"
            ),
            list(
                name = "NUCLEARFF CHOPPED $10 02",
                url = "https://sleeper.com/leagues/1260089054490275840",
                logo = "logos/guillotine-logo.png",
                status = "FULL",
                details = "$10 ENTRY | 16 TEAM | PPR | 6PT PASS TD"
            ),
            list(
                name = "NUCLEARFF CHOPPED $25",
                url = "https://sleeper.com/leagues/1240503074590568448",
                logo = "logos/guillotine-logo.png",
                status = "FULL",
                details = "$25 ENTRY | 16 TEAM | PPR | 6PT PASS TD"
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
        league_hero_row(config$external_resources$logo_url, "Survivor"),
        create_stat_cards(
            list(
                "W" = "Winning is survival",
                "infinite" = "Teams"
            )
        ),
        tags$hr(class = "my-4"),
        create_league_accordion("survivor"),
        create_league_list("survivor", list(
            list(
                name = "|NUCLEARFF Survivor (Pick 'Em) 2025",
                url = "https://sleeper.com/leagues/1256760468719030272",
                logo = "logos/survivor-logo.png",
                status = "OPEN",
                status_class = "success",
                details = "$10 ENTRY | PICK 'EM"
            )
        ))
    )
}
