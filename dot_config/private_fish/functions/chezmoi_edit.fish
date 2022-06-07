function chezmoi_edit --argument-names file
    if test -n "$file"
        set -f file (chezmoi source-path $file) >/dev/null
    else
        set -f file (fd --type file . $XDG_DATA_HOME/chezmoi | fzf -d / --with-nth 7.. --reverse --height 40%)
    end
    and $EDITOR $file
        chezmoi apply
        if string match '*.fish' $file >/dev/null
            source $file
        end
end
