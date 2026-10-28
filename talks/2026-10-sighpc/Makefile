# Build the SIG-HPC meeting deck (run from this directory):
#   make -C talks/2026-10-sighpc
SRC = data-what-where-how.md
OUT = data-what-where-how.pptx
REF = reference.pptx
TPL = template.pptx

$(OUT): $(SRC) $(REF) fix-code-size.py
	pandoc $(SRC) -o $(OUT) --reference-doc=$(REF) --slide-level=2 --syntax-highlighting=none
	./fix-code-size.py $(OUT) 14

$(REF): $(TPL) theme.sh
	./theme.sh

# Render slides to PNGs for a quick visual check (needs LibreOffice)
preview: $(OUT)
	rm -rf preview && mkdir preview
	soffice --headless --convert-to png --outdir preview $(OUT)
	soffice --headless --convert-to pdf --outdir preview $(OUT)
	pdftoppm -png -r 60 preview/$(OUT:.pptx=.pdf) preview/slide

clean:
	rm -rf $(OUT) $(REF) preview

.PHONY: preview clean
