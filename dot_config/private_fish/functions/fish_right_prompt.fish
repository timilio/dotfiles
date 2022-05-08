function fish_right_prompt

    ls -a | grep -q ^.git\$

    if test $status -eq 0
        git status | grep -q "working tree clean"

        if test $status -eq 0
            set_color -b green
        else
            set_color -b yellow
        end

        set_color black
        echo -ns " " (git branch --show-current) " "
        set_color normal
    end
end

