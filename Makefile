
all: inst/README.md

inst/README.md: inst/README.Rmd inst/vignette_child/child.Rmd
	Rscript -e "library(knitr); knit('$<', output = '$@', quiet = TRUE)"
