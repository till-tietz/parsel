#' utility function that closes all parallel instances of rselenium
#' @export

close_rselenium <- function() {
  parallel::clusterEvalQ(clust, {
    remDr$close()
    rD$server$stop()
  })
  system("taskkill /im java.exe /f", intern = FALSE, ignore.stdout = FALSE)
}
