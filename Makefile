ms.pdf : ms.ps
	@echo "   Converting PS to PDF..."; \
	ps2pdf ms.ps 1>> ms_make.log 2>&1; \
   echo -e "\n############################################\n" >> ms_make.log; \
	echo -e "   \"Make\" complete."

ms.ps : ms.dvi
	@echo "   Converting DVI to PS..."; \
	dvips ms.dvi 1>> ms_make.log 2>&1; \
   echo -e "\n############################################\n" >> ms_make.log

ms.dvi : ms.tex master.bib
	@echo -e "\n############################################\n" > ms_make.log; \
	echo "   First pass with LaTeX..."; \
	latex ms 1>> ms_make.log 2>&1; \
   echo -e "\n############################################\n" >> ms_make.log; \
	echo "   Running BibTeX..."; \
	bibtex ms 1>> ms_make.log 2>&1; \
   echo -e "\n############################################\n" >> ms_make.log; \
	echo "   Second pass with LaTeX..."; \
	latex ms 1>> ms_make.log 2>&1; \
   echo -e "\n############################################\n" >> ms_make.log; \
	echo "   Third pass with LaTeX..."; \
	latex ms 1>> ms_make.log 2>&1; \
   echo -e "\n############################################\n" >> ms_make.log

clean:
	@echo "   Removing intermediate files."; \
	rm ms.aux ms.bbl ms.blg ms.dvi ms.log ms_make.log ms.ps
