function pdf --wraps pandoc --description 'Compiles md to pdf'
    argparse --ignore-unknown 'b/bordered-images' 'u/usepackage=+' -- $argv

    # Basic options
    set -f options -V colorlinks -V geometry:letterpaper -V geometry:margin=1in -V mainfont='Times New Roman' -V monofont='Arial' -V fontsize=12pt --pdf-engine=xelatex -o (basename $argv[1] .md).pdf $argv
    
    # Add citations if a bibliography is specified
    if contains -- --bibliography $argv
        set -fa options --csl ~/.local/pdf/apa.csl --citeproc
    end

    # Add a small black border to all images
    if test -n "$_flag_b"
        set -fa header_includes '\\usepackage[export]{adjustbox} \\let\\includegraphicsbak\\includegraphics \\renewcommand*{\\includegraphics}[2][]{\\includegraphicsbak[frame,#1]{#2}}'

        # Install missing packages
        set -l installed (tlmgr info --only-installed --data name)
        echo $installed | grep -q adjustbox; and echo $installed | grep -q collectbox
        if test $status -ne 0
            sudo tlmgr install adjustbox collectbox
        end
    end

    # Add packages to use
    if test (count $_flag_u) -ne 0
        for package in $_flag_u
            set -fa header_includes "\\usepackage{$package}"
        end
    end

    # Add any header_includes to options
    if test (count $header_includes) -ne 0
        set -fa options -V header-includes:(string join ' ' $header_includes)
    end

    # Generate pdf
    pandoc $options
end
