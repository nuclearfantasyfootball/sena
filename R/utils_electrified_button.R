#' Create Electrified Button Component
#'
#' Generates an animated GSAP-powered button with electrical effects
#'
#' @param id Character. Unique ID for the button
#' @param text Character. Button text to display
#' @param class Character. Additional CSS classes
#' @param onclick Character. JavaScript onclick handler (optional)
#' @return HTML tags for electrified button
#' @export
electrified_button <- function(id = "electrified_btn",
                               text = "ENTER",
                               class = "",
                               onclick = NULL) {
    # Build button container with all necessary elements
    tags$div(
        class = paste("electrified-container", class),
        id = paste0(id, "_container"),

        # Gradient border wrapper
        tags$div(
            class = "electrified-border-gradient",

            # Actual button
            tags$button(
                id = id,
                class = "electrified-btn",
                onclick = onclick,
                tags$span(class = "vh", text) # Screen reader text
            ),

            # Visual button text
            tags$span(
                class = "electrified-button-text",
                `aria-hidden` = "true",
                text
            )
        ),

        # SVG lightning effects
        electrified_svg(id)
    )
}

#' Create Electrified Button SVG Effects
#'
#' Generates the SVG filters and lightning effects for the button
#'
#' @param button_id Character. ID of the associated button
#' @return HTML SVG element with filters
#' @keywords internal
electrified_svg <- function(button_id) {
    tags$svg(
        id = paste0(button_id, "_scribbles"),
        class = "electrified-scribbles",
        `aria-hidden` = "true",
        preserveAspectRatio = "none",
        viewBox = "0 0 100 50",

        # Filters
        tags$filter(
            `color-interpolation-filters` = "sRGB",
            id = paste0(button_id, "_glow"),
            x = "-50", y = "-50",
            width = "200", height = "200",
            filterUnits = "userSpaceOnUse",
            tags$feGaussianBlur(stdDeviation = "10"),
            tags$feComponentTransfer(
                tags$feFuncA(type = "linear", slope = "2")
            ),
            tags$feBlend(in2 = "SourceGraphic")
        ),

        # Turbulence filters for distortion
        create_turbulence_filter(paste0(button_id, "_filter1"), "0.15 0", "5"),
        create_turbulence_filter(paste0(button_id, "_filter2"), "0.2 0", "10"),
        create_turbulence_filter(paste0(button_id, "_filter3"), "0.2 0.2", "5"),
        create_turbulence_filter(paste0(button_id, "_filter4"), "0.2 0.2", "5"),

        # Gradients
        create_lightning_gradients(button_id),

        # Lightning strikes group
        tags$g(
            id = paste0(button_id, "_lightning"),
            class = "electrified-lightning",
            `stroke-width` = "1",
            filter = sprintf("url(#%s_glow)", button_id),
            stroke = sprintf("url(#%s_gradient1)", button_id),

            # Multiple strike layers with different filters
            create_strike_rect(paste0(button_id, "_filter1"), paste0(button_id, "_gradient1"), "1.5"),
            create_strike_rect(paste0(button_id, "_filter2"), paste0(button_id, "_gradient2"), "2"),
            create_strike_rect(paste0(button_id, "_filter3"), paste0(button_id, "_gradient3"), "1.5"),
            create_strike_rect(paste0(button_id, "_filter2"), paste0(button_id, "_gradient3"), "1"),
            create_strike_rect(paste0(button_id, "_filter4"), paste0(button_id, "_gradient3"), "1.5")
        )
    )
}

#' Create Turbulence Filter
#'
#' Helper function to create SVG turbulence filters
#'
#' @param id Filter ID
#' @param frequency Base frequency
#' @param scale Displacement scale
#' @return SVG filter element
#' @keywords internal
create_turbulence_filter <- function(id, frequency, scale) {
    tags$filter(
        `color-interpolation-filters` = "sRGB",
        id = id,
        x = "-50", y = "-50",
        width = "200", height = "200",
        filterUnits = "userSpaceOnUse",
        tags$feTurbulence(
            type = "fractalNoise",
            baseFrequency = frequency,
            numOctaves = "1",
            result = "warp"
        ),
        tags$feDisplacementMap(
            xChannelSelector = "R",
            yChannelSelector = "G",
            scale = scale,
            `in` = "SourceGraphic",
            in2 = "warp"
        )
    )
}

#' Create Lightning Gradients
#'
#' Helper function to create SVG gradients for lightning effects
#'
#' @param button_id Button ID prefix
#' @return List of SVG linearGradient elements
#' @keywords internal
create_lightning_gradients <- function(button_id) {
    tagList(
        # Gradient 1 - Yellow to cyan
        tags$linearGradient(
            gradientUnits = "userSpaceOnUse",
            id = paste0(button_id, "_gradient1"),
            tags$stop(offset = "0%", `stop-color` = "#ffe17e"),
            tags$stop(offset = "10%", `stop-color` = "#f65426"),
            tags$stop(offset = "50%", `stop-color` = "#fff"),
            tags$stop(offset = "100%", `stop-color` = "#6ff5ff")
        ),

        # Gradient 2 - Rotated version
        tags$linearGradient(
            gradientUnits = "userSpaceOnUse",
            id = paste0(button_id, "_gradient2"),
            gradientTransform = "rotate(65)",
            tags$stop(offset = "0%", `stop-color` = "#ffe17e"),
            tags$stop(offset = "10%", `stop-color` = "#f65426"),
            tags$stop(offset = "50%", `stop-color` = "#fff"),
            tags$stop(offset = "100%", `stop-color` = "#6ff5ff")
        ),

        # Gradient 3 - Cyan focused
        tags$linearGradient(
            gradientUnits = "userSpaceOnUse",
            id = paste0(button_id, "_gradient3"),
            tags$stop(offset = "0%", `stop-color` = "#69eeff"),
            tags$stop(offset = "50%", `stop-color` = "#fff"),
            tags$stop(offset = "100%", `stop-color` = "#69eeff")
        )
    )
}

#' Create Strike Rectangle
#'
#' Helper function to create lightning strike rectangles
#'
#' @param filter_id Filter ID to apply
#' @param gradient_id Gradient ID to use
#' @param stroke_width Stroke width
#' @return SVG rect element
#' @keywords internal
create_strike_rect <- function(filter_id, gradient_id, stroke_width) {
    tags$rect(
        filter = sprintf("url(#%s)", filter_id),
        class = "electrified-strike",
        stroke = sprintf("url(#%s)", gradient_id),
        x = "0", y = "0",
        width = "100", height = "50",
        rx = "38.59",
        fill = "none",
        `stroke-miterlimit` = "10",
        `stroke-width` = stroke_width
    )
}

#' Initialize Electrified Button JavaScript
#'
#' Send initialization message to set up GSAP animations
#'
#' @param session Shiny session
#' @param button_id Button ID to initialize
#' @export
init_electrified_button <- function(session, button_id) {
    session$sendCustomMessage("initElectrifiedButton", list(id = button_id))
}

#' Create Hero Electrified Button
#'
#' Wrapper for electrified button specifically for hero section
#'
#' @param id Character. Unique ID for the button (default: "hero_enter_btn")
#' @param text Character. Button text to display (default: "ENTER")
#' @param onclick Character. JavaScript to execute on click
#' @param wrapper_class Character. CSS class for wrapper div (default: "hero-electrified-wrapper")
#' @return HTML div with positioned electrified button
#' @export
hero_electrified_button <- function(id = "hero_enter_btn",
                                    text = "ENTER",
                                    onclick = "window.bslib.navSelect('topnav', 'leagues'); return false;",
                                    wrapper_class = "hero-electrified-wrapper") {
    tags$div(
        class = wrapper_class,
        electrified_button(
            id = id,
            text = text,
            onclick = onclick
        )
    )
}
