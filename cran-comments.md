This is a minor release introducing the new constructor functions `start_scraper` and `build_scraper`

## Test environments
* local Ubuntu 22.04.1 LTS install, R 4.2.2 Patched
* win-builder, R version 4.2.2
* win-builder, R version 4.1.3
* R-hub macOS (r-release)
* R-hub Windows Server 2022 (r-release)

## R CMD check results

0 errors | 0 warnings | 1 note

Found the following assignments to the global environment: \
File ‘parsel/R/constructors_build.R’: \
assign(name, eval(parse(text = call)), envir = globalenv()) 
  
**Global assignment is essential for the `build_scraper` functionality. Users can 
specify the object name to avoid overwriting existing objects.**
    
    


