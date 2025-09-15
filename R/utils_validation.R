#' Validate URL
#'
#' Check if a URL is valid and accessible
#'
#' @param url Character. URL to validate
#' @param check_exists Logical. Whether to check if URL is accessible
#' @return Logical indicating if URL is valid
#' @export
validate_url <- function(url, check_exists = FALSE) {
    # Basic pattern validation
    pattern <- "^https?://[\\w\\-]+(\\.[\\w\\-]+)+[/#?]?.*$"

    if (!grepl(pattern, url, perl = TRUE)) {
        return(FALSE)
    }

    # Optional: Check if URL exists
    if (check_exists) {
        tryCatch(
            {
                response <- httr::HEAD(url, httr::timeout(5))
                httr::status_code(response) < 400
            },
            error = function(e) FALSE
        )
    } else {
        TRUE
    }
}

#' Validate League Type
#'
#' Ensure league type is valid
#'
#' @param type Character. League type to validate
#' @return Validated league type or error
#' @export
validate_league_type <- function(type) {
    valid_types <- c("redraft", "dynasty", "chopped", "survivor")

    type <- tolower(trimws(type))

    if (!type %in% valid_types) {
        stop(sprintf(
            "Invalid league type '%s'. Must be one of: %s",
            type,
            paste(valid_types, collapse = ", ")
        ))
    }

    type
}

#' Safe NULL Default
#'
#' Return default value if input is NULL
#'
#' @param x Value to check
#' @param default Default value if x is NULL
#' @return x if not NULL, otherwise default
#' @export
`%||%` <- function(x, default) {
    if (is.null(x)) default else x
}
