#' utility function that closes all parallel instances of RSelenium
#'
#' @param clust \code{parallel} cluster
#' @return No return value, called to close RSelenium instances in parscrape.
#' @keywords internal

close_rselenium <- function(clust) {
  parallel::clusterEvalQ(clust, function(){
    remDr$close()
    rD$server$stop()
  })
  system("taskkill /im java.exe /f", intern = FALSE, ignore.stdout = FALSE)
}
