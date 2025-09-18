#' Render Markdown File
#'
#' Safely renders a markdown file to HTML with error handling
#'
#' @param path Character string. Path to the markdown file
#' @return HTML content or error message div
#' @export
#' @examples
#' md_file("www/md/overview.md")
md_file <- function(path) {
  if (!file.exists(path)) {
    return(tags$div(
      class = "text-danger small",
      sprintf("Markdown file not found: %s (wd: %s)", path, getwd())
    ))
  }
  txt <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  HTML(commonmark::markdown_html(txt))
}

#' Nuclear FF Infinity SVG
#'
#' Creates an animated infinity symbol SVG for stats display
#'
#' @param size Numeric. Size of the SVG in pixels (default: 80)
#' @return HTML span containing animated SVG
#' @export
nff_infinity_svg <- function(size = 80) {
  height <- round(size * 0.325)
  HTML(sprintf('
    <span class="nff-inf" style="display:inline-block;width:%dpx;height:%dpx;">
      <svg viewBox="0 0 200 80" width="100%%" height="100%%" aria-hidden="true" focusable="false">
        <style>
          @keyframes nff-inf-anim {
            12.5%%  { stroke-dasharray: 42 300;  stroke-dashoffset: -33; }
            43.75%% { stroke-dasharray: 105 300; stroke-dashoffset: -105; }
            100%%   { stroke-dasharray: 3 300;   stroke-dashoffset: -297; }
          }
          .bg {
            fill: none; stroke: currentColor; stroke-width: 4; opacity: .2;
          }
          .outline {
            fill: none; stroke: currentColor; stroke-width: 4;
            stroke-linecap: round; stroke-linejoin: round;
            stroke-dasharray: 3 300;
            animation: nff-inf-anim 3000ms linear infinite;
          }
        </style>
        <path class="bg" pathLength="300"
          d="M100 40
             C 80 10, 40 10, 40 40
             C 40 70, 80 70, 100 40
             C 120 10, 160 10, 160 40
             C 160 70, 120 70, 100 40" />
        <path class="outline" pathLength="300"
          d="M100 40
             C 80 10, 40 10, 40 40
             C 40 70, 80 70, 100 40
             C 120 10, 160 10, 160 40
             C 160 70, 120 70, 100 40" />
      </svg>
    </span>', size, height))
}

#' Create Styled Blockquote
#'
#' Creates a styled blockquote for use in R Markdown articles.
#' Note that using this in R Markdown is slower than HTML.
#'
#' @param text Character string. The blockquote text
#' @param class Character string. Additional CSS class (optional)
#' @return HTML blockquote element
#' @export
nff_blockquote <- function(text, class = "") {
  additional_class <- if (nzchar(class)) paste0(" ", class) else ""

  HTML(sprintf(
    '<blockquote class="nff-blockquote%s">
      <p>%s</p>
    </blockquote>',
    additional_class,
    text
  ))
}
