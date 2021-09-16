#' get_provenance
#'
#' @param data_product data_product
#' @param version version
#' @param namespace namespace
#' @param aspect_ratio aspect_ratio
#' @param dpi dpi
#' @param attributes attributes
#' @param endpoint endpoint
#'
#' @export
#'
get_provenance <- function(data_product,
                           version,
                           namespace,
                           aspect_ratio = NULL,
                           dpi = NULL,
                           attributes = FALSE,
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

  if (!attributes)
    api_url <- paste0(api_url, "&attributes=False")

  if (!is.null(aspect_ratio))
    api_url <- paste0(api_url, "&aspect_ratio=", aspect_ratio)

  if (!is.null(dpi))
    api_url <- paste0(api_url, "&dpi=", dpi)

  key <- readLines(file.path("~", ".fair", "registry", "token"))
  h <- c(Authorization = paste("token", key))

  # Get XML
  response <- httr::GET(api_url,
                        httr::add_headers(.headers = h))
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

  # convert directly into a png format
  png_file <- tempfile(fileext = ".png")
  rsvg::rsvg_png(xml_file, png_file)
  # render into raw png array
  png <- rsvg::rsvg(xml_file)
  # read in png
  magick::image_read(png)
}
