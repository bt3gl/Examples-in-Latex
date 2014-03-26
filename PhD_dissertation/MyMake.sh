#!/bin/bash
# marina wahl @ 2014

# list of source files
main="dissertation"
srcfiles=`ls $main.tex subdocuments/* styles/* figures/*`
outdir="build"
target="$main.pdf"
run_latex="pdflatex -shell-escape"

# check if PDF is newer than all source files
if [ -e $target ]
then
   newer=1
   for file in $srcfiles
   do
      if [ $file -nt $target ]
      then
         newer=0
      fi
   done
   recompile=`echo "1-$newer" | bc`
   if [ $recompile -eq 1 ]
   then
      echo "$target is not the newest file"
   else
      echo "$target is the newest file"
   fi
else
   # PDF does not exist
   recompile=1
   echo "$target does not exist"
fi

# check for "force" option
if [ -n "$1" ]
then
   if [ "$1" = "-f" -o "$1" = "--force" ]
   then
      recompile=1
      echo "force: recompile regardless"
   fi
fi

# exit if no need to recompile
if [ $recompile -eq 0 ]
then
   echo "no need to recompile"
   exit 0
fi

# run LaTeX without the -halt-on-error flag
$run_latex -output-directory $outdir $main.tex 2>&1 | tee $outdir/make.latex1 
latex_exit=${PIPESTATUS[0]}   # cannot use $? or you get the exit status of tee
                              # PIPESTATUS only works for bash

# if the exit status is nonzero, terminate so the user can fix the LaTeX
if [ $latex_exit -ne 0 ]
then
   echo ""
   echo ""
   echo "failure on first LaTeX call"
   exit 1
fi

# rerun LaTeX with the -halt-on-error flag and dump the output
$run_latex -output-directory $outdir -halt-on-error $main.tex 1> $outdir/make.latex2 2>&1

# run BibTeX, save the output
echo ""
bibtex $outdir/$main 2>&1 | tee $outdir/make.bibtex

# run LaTeX once more with the -halt-on-error flag and capture the output
$run_latex -output-directory $outdir -halt-on-error $main.tex 1> $outdir/make.latex3 2>&1

# count the occurrences of "LaTeX Error" and "LaTeX Warning" in the output
latex_err=`grep -c "LaTeX Error" $outdir/make.latex3`
latex_wrn=`grep -c "LaTeX Warning" $outdir/make.latex3`

# notify the user about the number of errors and warnings (errors should be
# zero, because they should have been caught by the first pass of LaTeX,
# causing the script to stop)
echo ""
echo "number of errors / warnings = $latex_err / $latex_wrn"

if [ "$run_latex" = "latex" ]
then
   # convert the DVI to PS
   echo ""
   echo -n "converting..."
   dvips -o $outdir/$main.ps $outdir/$main.dvi 1> $outdir/make.dvips 2>&1

   # convert the PS to PDF
   echo -n "..."
   epstopdf --outfile $main.pdf $outdir/$main.ps 1> $outdir/make.epstopdf 2>&1
   echo "done"
else
   # copy the PDF to the current directory
   cp -f $outdir/$main.pdf $main.pdf
fi
