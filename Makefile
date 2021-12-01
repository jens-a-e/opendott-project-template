# Make sure you change the filename from Paper.md to something meaningful.
SOURCE := ReadMe.md
TARGET_NAME := Name-of-Researchoutput

HTML := $(patsubst %.md,index.html, $(SOURCE))
PDF := $(patsubst %.md,%.pdf, $(SOURCE))
DOCX := $(patsubst %.md,%.docx, $(SOURCE))
ARCHIVE := $(TARGET_NAME).zip

# STYLE := _pandoc/pandoc.css
# Source: https://gist.github.com/killercup/5917178
# Make sure you save this in the same directory as shown or change the path.

OPTS :=  --from=markdown+smart+simple_tables+table_captions+yaml_metadata_block+smart

ARGS := \
	--filter pandoc-crossref \
	--citeproc \
	--csl=.styles/acm-sig-proceedings-long-author-list.csl
	# --toc

.PHONY : archive
archive:
	git archive -o $(ARCHIVE) HEAD
	git submodule --quiet foreach 'cd "$$toplevel"; zip -ru $(ARCHIVE) "$$sm_path"'

.PHONY : info
info:
	@echo --- Input ---
	@echo $(SOURCE)
	@echo --- Output ---
	@echo $(PDF)
	@echo $(HTML)
	@echo $(DOCX)


.PHONY : watch
watch:
	@echo ------ Building on file changes -----
	@ls *.md | entr make acm

.PHONY : all
all : $(HTML) $(PDF) $(DOCX)

.PHONY : html
html: $(HTML)
$(HTML) : $(SOURCE)
	@echo --- Generating HTML ---
	@pandoc $(OPTS)+ascii_identifiers $(ARGS) -s -w html \
		--self-contained \
		--default-image-extension=png \
		--mathjax \
		--metadata link-citations=true \
		--metadata linkReferences=true \
		--metadata title="$(TARGET_NAME)" \
		-o $@ $<

.PHONY : pdf
pdf : $(PDF)
$(PDF) : $(SOURCE)
	@echo --- Generating PDF ---
	@pandoc $(OPTS)+raw_tex $(ARGS) -t pdf \
		--shift-heading-level-by=0 \
		--default-image-extension=pdf \
		-V papersize:a4 \
		-V colorlinks=true \
		-V linkcolor=blue \
		-V urlcolor=red \
		-V toccolor=gray \
		--pdf-engine xelatex \
		-o $(TARGET_NAME).pdf $<

.PHONY : doc
doc: $(DOCX)
$(DOCX) : $(SOURCE)
	@echo --- Generating DOCX ---
	@pandoc $(OPTS) $(ARGS) -w docx \
		--katex \
		--default-image-extension=png \
		-o $(TARGET_NAME).docx $<
# --reference-doc=_pandoc/base.docx

.PHONY : clean
clean :
	@echo --- Deleting generated files ---
	@-rm $(HTML) $(PDF) $(DOCX)
