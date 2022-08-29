function update
    brew upgrade
    and nvim -c PackerSync
    and nvim -c LspInstallInfo
    and fundle update
    and fish_update_completions
    and newsboat -r
end
