# h/t to @jimhester and @yihui for this parse block:
# https://github.com/yihui/knitr/blob/dc5ead7bcfc0ebd2789fe99c527c7d91afb3de4a/Makefile#L1-L4
# Note the portability change as suggested in the manual:
# https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Writing-portable-packages
PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)
RM = rm -rf
RCMD = R --vanilla CMD
RSCRIPT = Rscript --vanilla


all: check clean
roxygen: docs

docs:
	@ $(RSCRIPT) -e "roxygen2::roxygenise(roclets = c('collate', 'namespace', 'rd'))"


readme:
	@ echo "Rendering README.Rmd"
	@ $(RSCRIPT) \
	-e "Sys.setenv(RSTUDIO_PANDOC='/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools')" \
	-e "options(cli.width = 80L)" \
	-e "rmarkdown::render('README.Rmd', quiet = TRUE)"
	@ $(RM) README.html

test:
	@ $(RSCRIPT) \
	-e "Sys.setenv(ON_JENKINS = 'true', TZ = 'America/Denver')" \
	-e "devtools::test(reporter = 'summary', stop_on_failure = TRUE)"

test_file:
	@ $(RSCRIPT) \
	-e "Sys.setenv(ON_JENKINS = 'true', TZ = 'America/Denver', NOT_CRAN = 'true')" \
	-e "devtools::load_all()" \
	-e "testthat::test_file('$(FILE)', reporter = 'progress', stop_on_failure = TRUE)"

accept_snapshots:
	@ Rscript -e "testthat::snapshot_accept()"

build: docs
	@ cd ..;\
	$(RCMD) build --resave-data $(PKGSRC)

pkgdown: docs
	@ $(RSCRIPT) inst/deploy-pkgdown.R

check: build
	@ cd ..;\
	$(RCMD) check --no-manual $(PKGNAME)_$(PKGVERS).tar.gz

fake_iris:
	@ echo "Creating 'data/classify.rda' ..."
	@ $(RSCRIPT) \
	-e "set.seed(12345)" \
	-e "x <- dplyr::filter(datasets::iris, Species != 'versicolor') # 2 classes" \
	-e "n <- nrow(x)" \
	-e "x <- dplyr::sample_n(x, size = n)       # reorder randomly" \
	-e "x <- dplyr::mutate(x," \
	-e "       Species = as.character(Species), # Species -> character" \
	-e "       Species = ifelse(runif(n) > 0.5, sample(Species), Species)," \
	-e "       Species = as.factor(Species)     # convert Species -> factor" \
	-e ")" \
	-e "x <- dplyr::mutate_if(x, is.numeric, jitter, amount = 1)   # jitter features" \
	-e "x <- dplyr::group_by(x, Species) |> dplyr::rename(Response = Species)" \
	-e "fake_iris <- structure(" \
	-e "  x," \
	-e "  class = c('tr_data', 'soma_adat', class(x))," \
	-e "  Header.Meta = list(HEADER   = list(Version = '1.2', Title = 'SL-99-999')," \
	-e "                     COL_DATA = list(Name = 'SeqId', Type = 'String')," \
	-e "                     ROW_DATA = list(Name = 'PlateId', Type = 'String'))," \
	-e " Col.Meta = tibble::tibble(SeqId    = '1234-56'," \
	-e "                           Target   = 'MMP-4'," \
	-e "                           Dilution = '0.005'," \
	-e "                           Units    = 'RFU')" \
	-e ")" \
	-e "save(fake_iris, file = 'data/classify.rda', compress = 'xz')"
	@ echo "Saving 'data/classify.rda' ..."

install:
	@ R CMD INSTALL --use-vanilla --preclean --resave-data .

clean:
	@ cd ..;\
	$(RM) $(PKGNAME)_$(PKGVERS).tar.gz $(PKGNAME).Rcheck
