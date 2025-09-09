#' Initialize App Environment
#'
#' Set up global environment for the app
#'
#' @export
init_app_environment <- function() {
    # Set global options
    options(
        # Shiny options
        shiny.minified = TRUE,
        shiny.sanitize.errors = TRUE,
        shiny.trace = FALSE,

        # bslib options
        bslib.precompiled = TRUE,
        bslib.color_contrast_warnings = FALSE,

        # Cache Sass
        sass.cache = TRUE,

        # App-specific options
        nuclearff.debug = FALSE,
        nuclearff.cache = TRUE,
        nuclearff.timeout = 30
    )

    # Set up caching directory
    cache_dir <- "cache"
    if (!dir.exists(cache_dir)) {
        dir.create(cache_dir, recursive = TRUE)
    }

    # Initialize logging
    if (getOption("nuclearff.debug")) {
        message("NuclearFF App initialized in debug mode")
    }

    invisible(TRUE)
}

#' Check Required Packages
#'
#' Verify all required packages are installed
#'
#' @param packages Character vector of required packages
#' @export
check_required_packages <- function(packages = NULL) {
    if (is.null(packages)) {
        packages <- c(
            "shiny", "bslib", "DT", "htmltools",
            "bsicons", "commonmark", "httr"
        )
    }

    missing <- packages[!packages %in% installed.packages()[, "Package"]]

    if (length(missing) > 0) {
        stop(sprintf(
            "Missing required packages: %s\nInstall with: install.packages(c(%s))",
            paste(missing, collapse = ", "),
            paste(sprintf('"%s"', missing), collapse = ", ")
        ))
    }

    invisible(TRUE)
}
