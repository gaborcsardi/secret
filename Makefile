
all: inst/README.markdown

inst/README.markdown: inst/README.Rmd inst/vignette_child/child.Rmd
	Rscript -e "library(knitr); knit('$<', output = '$@', quiet = TRUE)"
