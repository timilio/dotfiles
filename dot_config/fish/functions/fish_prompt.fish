function fish_prompt
    set -l last_status $status

    # SSH mode
    if test -n "$SSH_CLIENT"
        set_color -b blue
        set_color white
        echo -n " SSH "
    end

    # Prompt pwd
    set_color -b normal
    set_color $fish_color_cwd
    echo -n " "
    echo -n (basename $PWD)
    echo -n " "

    # Warning when root privileges
    if test (id -u $USER) -eq 0
        set_color -b red
        set_color normal
        echo -ns " ! "
    end

    # Red arrow when not successful
    set_color -b normal
    if test $last_status -eq 0
        set_color cyan
    else
        set_color red
    end
    echo -ns "->> "
end
