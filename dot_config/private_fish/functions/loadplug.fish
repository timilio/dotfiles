function __remove_duplicates
    set -f result
    for item in $argv
        if not contains $item $result
            set -fa result $item
        end
    end
    echo "$result"
    return 0
end

function loadplug
    set -l plugdir "$argv[1]"
    if test -d $plugdir
        set -l plugname (basename $plugdir)

        # Find every command and unload any loaded completions for the commands
        set -l completions (rg '^complete' $plugdir | string match -gr '\-c ([a-z]*) ')
        for comp in (__remove_duplicates $completions)
            echo "Unloaded completions for $comp."
            complete -c $comp -e
        end

        # Unload functions
        for func in (rg '^function' $plugdir | string match -gr 'function ([a-z]*) ')
            echo "Unloaded function $func."
            functions -e $func
        end
        echo '---'

        # Source all shell scripts in the plugin directory
        for fishfile in $plugdir/*{,/*}.fish
            source $fishfile
            echo "$(string match -gr "$plugname/(.*/?.*)" $fishfile) was sourced!"
        end
        echo '---'

        set_color green
        echo "Successfully loaded $plugname!"
    else
        echo 'Please specify a plugin directory to load.'
    end
end
