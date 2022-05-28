function fish_right_prompt
    set -g __fish_git_prompt_showcolorhints
    set -g __fish_git_prompt_show_informative_status
    echo (fish_git_prompt)
end

