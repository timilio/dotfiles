function loadplug
    set -l plugdir "$argv[1]"
    if test -d $plugdir
        # Find every command and remove any existing completions for the commands
        for command in (rg complete $plugdir | string match --groups-only --regex '\-c ([a-z]*) ')
            complete -c $command -e
        end

        # Source all shell scripts in the plugin directory
        for fishfile in $plugdir/*{,/*}.fish
            source $fishfile
            echo "$fishfile was sourced!"
        end
    else
        echo 'Please specify a plugin directory to load.'
    end
end
