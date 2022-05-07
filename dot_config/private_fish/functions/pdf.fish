function pdf --wraps pandoc --description 'Compiles md to pdf'
    pandoc -V linkcolor:blue -V geometry:letterpaper -V geometry:margin=1in \
    -V mainfont='Times New Roman' -V monofont='Helvetica' -V fontsize=12pt \
    --csl ~/.pdf/apa.csl --citeproc --pdf-engine=xelatex \
    -o (basename $argv[1] .md).pdf $argv
end
