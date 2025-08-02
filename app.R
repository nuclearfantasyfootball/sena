# Load required libraries
library(shiny)
library(bslib)
library(gt)
library(dplyr)
library(readr)
library(htmltools)
library(purrr)
library(bsicons)

# Define UI using HTML template (landing page only)
ui <- htmlTemplate(
  # Main HTML template file
  "www/index.html",

  # Map your Shiny outputs to template placeholders
  countdown_display = div(
    class = "countdown-container",
    textOutput("countdown", inline = TRUE)
  ),

  # Social media links
  social_links = div(
    class = "social-links",
    tags$a(
      href = "https://x.com/nuclearffnolan",
      target = "_blank",
      bs_icon("twitter-x")
    ),
    tags$a(
      href = "https://discord.gg/9sJQ4yYkkF",
      target = "_blank",
      bs_icon("discord")
    ),
    tags$a(
      href = "https://github.com/nuclearfantasyfootball",
      target = "_blank",
      bs_icon("github")
    )
  ),

  # Logo
  logo_img = tags$img(
    src = "https://raw.githubusercontent.com/NuclearAnalyticsLab/nuclearff/refs/heads/main/inst/logos/png/nuclearff-2color.png",
    height = "40px",
    alt = "Nuclear Fantasy Football"
  )
)

# Define server logic
server <- function(input, output, session) {
  # Countdown timer
  output$countdown <- renderText({
    invalidateLater(1000, session)

    target_date <- as.POSIXct("2025-08-15 09:00:00", tz = "America/New_York")
    now <- Sys.time()
    attr(now, "tzone") <- "America/New_York"

    time_remaining <- difftime(target_date, now, units = "secs")

    if (as.numeric(time_remaining) <= 0) {
      return("LAUNCHED!")
    }

    total_seconds <- as.numeric(time_remaining)
    days <- floor(total_seconds / (24 * 3600))
    hours <- floor((total_seconds %% (24 * 3600)) / 3600)
    minutes <- floor((total_seconds %% 3600) / 60)
    seconds <- floor(total_seconds %% 60)

    paste0(days, "D ", hours, "H ", minutes, "M ", seconds, "S")
  })

  # CSS injection for mobile viewport handling
  observe({
    # Inject additional mobile-specific CSS
    insertUI(
      selector = "head",
      where = "beforeEnd",
      ui = tags$style(HTML("
      @media (max-width: 400px) {
        .hero-section {
          min-height: 100vh;
          height: auto;
        }
        .hero-title-nuclear-minimal {
          font-size: 2.2rem !important;
          font-weight: 700 !important;
          letter-spacing: 0.0px;
        }
      }
    "))
    )
  })
}

# Create and run the app
shinyApp(ui = ui, server = server)
