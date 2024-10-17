function pdfgrep -w rg
    rg --pre ~/.local/bin/pdftext.sh --pre-glob '*.pdf' $argv
end
