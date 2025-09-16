#' League Data Structure
#'
#' Define and validate league data structure
#'
#' @param name Character. League name
#' @param url Character. League URL
#' @param logo Character. Path to logo
#' @param status Character. League status (FULL, OPEN, STARTUP, ORPHAN)
#' @param details Character. League details
#' @param status_class Character. Optional Bootstrap status class
#' @return List with validated league data
#' @export
create_league_data <- function(name,
                               url,
                               logo,
                               status = "OPEN",
                               details = "",
                               status_class = NULL) {
    # Validate status
    valid_statuses <- c("FULL", "FILLED", "LOCKED", "OPEN", "STARTUP", "ORPHAN")
    if (!status %in% valid_statuses) {
        stop(sprintf(
            "Invalid status. Must be one of: %s",
            paste(valid_statuses, collapse = ", ")
        ))
    }

    # Validate URL
    if (!grepl("^https?://", url)) {
        warning("URL should start with http:// or https://")
    }

    structure(
        list(
            name = as.character(name),
            url = as.character(url),
            logo = as.character(logo),
            status = status,
            details = as.character(details),
            status_class = status_class
        ),
        class = "league_data"
    )
}

#' Get League Data
#'
#' Retrieve league data for a specific type
#'
#' @param type Character. League type (redraft, dynasty, chopped, survivor)
#' @param source Character. Data source ("config", "database", "api")
#' @return List of league data objects
#' @export
get_league_data <- function(type, source = "config") {
    if (source == "config") {
        # Static configuration data
        league_configs <- list(
            redraft = list(
                create_league_data(
                    name = "Nuclear Football",
                    url = "https://sleeper.com/leagues/1240509989819273216",
                    logo = "logos/redraft-logo.png",
                    status = "FILLED",
                    details = "10 TEAM | PPR | 3 FLEX"
                )
            ),
            dynasty = list(
                create_league_data(
                    name = "NUCLEARFF DYNASTY",
                    url = "https://sleeper.com/leagues/1190192546172342272",
                    logo = "logos/dynasty-logo.png",
                    status = "FILLED",
                    details = "12 TEAM | PPR | SUPERFLEX"
                )
            ),
            chopped = list(
                create_league_data(
                    name = "NUCLEARFF GUILLOTINE $10",
                    url = "https://sleeper.com/leagues/1240503074590568448",
                    logo = "logos/guillotine-logo.png",
                    status = "FILLED",
                    details = "$10 ENTRY | 16 TEAM | PPR | 6PT PASS TD"
                ),
                create_league_data(
                    name = "NUCLEARFF CHOPPED $10 02",
                    url = "https://sleeper.com/leagues/1260089054490275840",
                    logo = "logos/guillotine-logo.png",
                    status = "FILLED",
                    details = "$10 ENTRY | 16 TEAM | PPR | 6PT PASS TD"
                ),
                create_league_data(
                    name = "NUCLEARFF CHOPPED $25",
                    url = "https://sleeper.com/leagues/1240503074590568448",
                    logo = "logos/guillotine-logo.png",
                    status = "FILLED",
                    details = "$25 ENTRY | 16 TEAM | PPR | 6PT PASS TD"
                )
            ),
            survivor = list(
                create_league_data(
                    name = "|NUCLEARFF Survivor (Pick 'Em) 2025",
                    url = "https://sleeper.com/leagues/1256760468719030272",
                    logo = "logos/survivor-logo.png",
                    status = "OPEN",
                    status_class = "success",
                    details = "$10 ENTRY | PICK 'EM"
                )
            )
        )

        return(league_configs[[type]] %||% list())
    } else if (source == "database") {
        # TODO: Implement database retrieval
        stop("Database source not yet implemented")
    } else if (source == "api") {
        # TODO: Implement API retrieval (e.g., Sleeper API)
        stop("API source not yet implemented")
    } else {
        stop("Invalid source. Must be one of: config, database, api")
    }
}

#' Get League Statistics
#'
#' Retrieve statistics for a league type
#'
#' @param type Character. League type
#' @return Named list of statistics
#' @export
get_league_stats <- function(type) {
    stats_config <- list(
        redraft = list(
            "12" = "Active Leagues",
            "156" = "Total Teams",
            "$50" = "Avg Buy-in",
            "89%" = "Return Rate"
        ),
        dynasty = list(
            "8" = "Active Dynasties",
            "3.2" = "Avg Years Running",
            "$75" = "Avg Buy-in",
            "94%" = "Retention Rate"
        ),
        chopped = list(
            "3" = "Active Leagues",
            "16" = "Teams per League",
            "Week 9" = "Avg Elimination"
        ),
        survivor = list(
            "W" = "Winning is survival",
            "infinite" = "Teams"
        )
    )

    stats_config[[type]] %||% list()
}
