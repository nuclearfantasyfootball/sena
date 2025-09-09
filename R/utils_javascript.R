#' Send JavaScript Message
#'
#' Helper to send custom JavaScript messages
#'
#' @param session Shiny session object
#' @param type Character. Message type
#' @param data Any R object to send to JavaScript
#' @export
send_js_message <- function(session, type, data) {
    session$sendCustomMessage(type, data)
}

#' Initialize JavaScript Handlers
#'
#' Set up JavaScript event handlers
#'
#' @param session Shiny session object
#' @export
init_js_handlers <- function(session) {
    session$onFlushed(function() {
        # Initialize theme from localStorage
        send_js_message(session, "initializeTheme", TRUE)

        # Initialize tooltips
        send_js_message(session, "initTooltips", TRUE)

        # Initialize league button handlers
        send_js_message(session, "addLeagueButtonHandler", TRUE)
    }, once = TRUE)
}

#' Create JavaScript Callback
#'
#' Generate JavaScript callback code
#'
#' @param event Character. Event type
#' @param code Character. JavaScript code to execute
#' @return JavaScript code string
#' @export
js_callback <- function(event, code) {
    sprintf(
        "Shiny.addCustomMessageHandler('%s', function(data) { %s });",
        event, code
    )
}
