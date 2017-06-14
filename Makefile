
all: README.md

README.md: README.Rmd inst/vignette_child/child.Rmd
	Rscript -e "library(knitr); knit('$<', output = '$@', quiet = TRUE)"
