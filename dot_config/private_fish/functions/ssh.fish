function ssh -w ssh
    switch $argv[1]
        case "*.cs.*"
            env TERM=xterm ssh $argv -t 'fish -l'
        case "*"
            env TERM=xterm ssh $argv
    end
end
