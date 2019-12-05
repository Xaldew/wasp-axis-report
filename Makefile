ROOT          := $(CURDIR)
TMP           := $(CURDIR)/build
TEX_SRCS      := report.tex
SVG_SRCS      := $(wildcard img/*.svg)
EXR_SRCS      := $(wildcard img/*.exr)
PDF_OUT       := $(TEX_SRCS:.tex=.pdf)
IMG_OUT       := $(EXR_SRCS:.exr=.png) $(SVG_SRCS:.svg=.pdf)
PYTHON        ?= python3
LATEXMK       ?= latexmk
LACHECK       ?= lacheck
TEX_FLAGS     ?= --shell-escape
LATEXMK_FLAGS ?= -bibtex -pdf -output-directory=$(TMP) -pdflatex="pdflatex $(TEX_FLAGS) %O %S"

# Create build directories.
$(shell mkdir -p $(TMP))


# Custom dependencies.
$(PDF_OUT): $(IMG_OUT)


# Build commands.
.DEFAULT_GOAL := all
.PHONY: all
all : $(PDF_OUT)

.PHONY: check
check : all
	for f in $(TEX_SRCS); do echo "$$f:" ; $(LACHECK) $(LACHECK_FLAGS) $$f ; done

.PHONY: wc
wc : ${TEX_SRCS}
	detex $< | wc --words

.PHONY: gray
gray : all
	gs -sOutputFile=$(basename $(TEX_SRCS))_grayscale.pdf \
	-sDEVICE=pdfwrite \
	-sColorConversionStrategy=Gray \
	-dProcessColorModel=/DeviceGray \
	-dCompatibilityLevel=1.4 \
	-dNOPAUSE \
	-dBATCH \
	$(basename $(TEX_SRCS)).pdf

.PHONY: clean
clean :
	$(RM) -r $(TMP) $(PDF_OUT) $(IMG_OUT)

.PHONY: imclean
imclean :
	$(RM) -r $(IMG_OUT)


# Pattern rules.
%.pdf : %.tex
	BSTINPUTS=".:../sty:" \
	TEXINPUTS=".:./sty:" \
	$(LATEXMK) $(LATEXMK_FLAGS) $(TEX_SRCS)

%.pdf : %.svg
	inkscape $< -A $(patsubst %.svg, %.pdf, $<)

%.png : GAMMA := 2.1
%.png : %.exr
	convert $< -gamma=$(GAMMA) $@
