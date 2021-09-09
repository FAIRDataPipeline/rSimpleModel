#' get_provenance
#'
#' @param data_product data_product
#' @param version version
#' @param namespace namespace
#' @param endpoint endpoint
#'
#' @export
#'
get_provenance <- function(data_product, version, namespace,
                           endpoint = "http://localhost:8000/api/") {

  # Get provenance URL
  namespace_entry <- rDataPipeline::get_entry("namespace",
                                              list(name = namespace),
                                              endpoint = endpoint)
  assertthat::assert_that(length(namespace_entry) == 1)
  namespace_url <- namespace_entry[[1]]$url
  namespace_id <- gsub(paste0(endpoint, ".*/([0-9]*)/"), "\\1", namespace_url)

  dp_entry <- rDataPipeline::get_entry("data_product",
                                       list(name = data_product,
                                            version = version,
                                            namespace = namespace_id),
                                       endpoint = endpoint)
  assertthat::assert_that(length(dp_entry) == 1)
  prov_url <- dp_entry[[1]]$prov_report
  api_url <- paste0(prov_url, "?format=svg")

  # Get XML
  response <- httr::GET(api_url)
  svg <- httr::content(response, as = "text", encoding = "UTF-8")
  if(!isXMLString(svg))
    stop(paste(response, "\n",
               api_url, "\n",
               svg, "\n",
               "XML missing from provenance report."))
  xml <- XML::xmlParse(svg, asText = TRUE)
  assertthat::assert_that(all(class(xml) %in% c("XMLInternalDocument",
                                                "XMLAbstractDocument")))
  xml_file <- tempfile(fileext = ".xml")
  XML::saveXML(xml, xml_file)

  # Generate and display png
  png_file <- tempfile(fileext = ".png")
  rsvg::rsvg_png(xml_file, png_file)
  display_png(png_file)
}

display_png <- function(img) {
  img <- png::readPNG(img)
  plot.new()
  plot.window(0:1, 0:1, asp = 1)
  rasterImage(img, 0, 0, 1, 1)
}