# set -g -x LC_ALL C
# set -gx LOCALE_ARCHIVE /usr/lib/locale/locale-archive
# set -g -x ASPNETCORE_ENVIRONMENT Test

set -U fish_greeting

alias h hx
set -gx EDITOR hx

# set PATH /var/home/sofusa/.npm-packages/bin $PATH
# fish_add_path ~/.cargo/bin/

alias ls "eza -1 --icons --group-directories-first"

alias gui gitui
alias se "wezterm cli get-text --start-line -99999 | hx"

# Todo: parameterize this
function cms
    zellij action rename-tab close
    zellij action new-tab -l ~/dotfiles/layouts/configuration-management.kdl
    zellij action go-to-tab-name close
    zellij action close-tab
end

alias dt "dotnet test -v quiet --nologo -l:'console;verbosity=normal'"
function dtt
    dotnet test -v quiet --nologo -l:"console;verbosity=normal" --filter Name~$argv
end

function ts
    if set -q argv[1]
        z $argv[1]
    else
        set dir (fd -t d | sk --preview 'eza -1 --icons --group-directories-first {} --color=always')

        if not test -z "$dir"
            z $dir
        end
    end
end

function t
    if set -q argv[1]
        z $argv[1..-1]
    else
        set dir (fd -t d -d 1 | sort -r -f | cat - (echo .. | psub) | sk --preview 'eza -1 --icons --group-directories-first {} --color=always')

        if not test -z "$dir"
            z $dir
            t
        end
    end
end

alias th "cd ~"

starship init fish | source
zoxide init fish | source
atuin init fish | source
