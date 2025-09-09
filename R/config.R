#' App Configuration
#'
#' Central configuration for the NuclearFF Shiny application
#' @export
app_config <- function() {
    list(
        # Shiny options
        options = list(
            shiny.minified = TRUE,
            bslib.precompiled = TRUE,
            bslib.color_contrast_warnings = FALSE
        ),

        # Theme definitions
        themes = list(
            light = bslib::bs_theme(
                version = 5,
                bg = "#ffffff",
                fg = "#212529",
                primary = "#0fa0ce"
            ),
            dark = bslib::bs_theme(
                version = 5,
                bg = "#0e0e0e",
                fg = "#e9ecef",
                primary = "#ce0fa0"
            )
        ),

        # League types
        league_types = c("redraft", "dynasty", "chopped", "survivor"),

        # External resources
        external_resources = list(
            logo_url = "https://raw.githubusercontent.com/NuclearAnalyticsLab/nuclearff/refs/heads/main/inst/logos/png/nuclearff-2color.png",
            fonts = list(
                roboto = "https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap",
                montserrat = "https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&display=swap"
            )
        )
    )
}
