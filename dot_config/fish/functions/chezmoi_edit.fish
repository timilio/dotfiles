function chezmoi_edit --argument-names file
    if test -n "$file"
        if not test -f $file
            mkdir -p (dirname $file)
            $EDITOR $file
            chezmoi add $file
            false
        else
            chezmoi status $file &>/dev/null || chezmoi add $file # Add to source state if file exists but isn't managed
            set -f file (chezmoi source-path $file) >/dev/null
        end
    else
        set -f file (fd --type file --hidden --exclude '.git' . $XDG_DATA_HOME/chezmoi | fzf -d / --with-nth 7.. --reverse --height 40%)
    end
    and $EDITOR $file && chezmoi apply

    if string match '*.fnl' $file >/dev/null
        nvim --headless -c FnlCompile -c quitall
    end
    if string match '*.fish' $file >/dev/null
        source $file
    end
end
