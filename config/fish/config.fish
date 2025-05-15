set -U fish_greeting

alias nix "~/nixsa/bin/nixsa nix"
alias h hx
set -gx EDITOR hx

alias nb "jj bookmark"
alias nbs "jj bookmark set"
alias nd "jj describe -m"
alias nl "jj log"
alias np "jj git push"
alias npc "jj git push -c @"
alias nf "jj git fetch"
alias nn "jj new"
alias nbm "nb move --from @- --to @"
alias n jj

alias ls "eza -1 --icons --group-directories-first; rpg-cli ls"

alias dt "dotnet test"
function dtt
    dotnet test -v quiet --nologo -l:"console;verbosity=normal" --filter Name~$argv
end

function ts
    if set -q argv[1]
        z $argv[1]
        rpg-cli cd .
    else
        set dir (fd -t d | sk --preview 'eza -1 --icons --group-directories-first {} --color=always')

        if not test -z "$dir"
            z $dir
            rpg-cli cd .
        end
    end
end

function t
    if set -q argv[1]
        set -l dir_name $argv[1]
        set -l matched_dir (ls | grep -i "^$dir_name")

        if test -n "$matched_dir"
            set -l new_args $matched_dir $argv[2..-1]
            z $new_args
            rpg-cli cd .
        else
            z $argv[1..-1]
            rpg-cli cd .
        end
    else
        set dir (fd -t d -d 1 | sort -r -f | cat - (echo .. | psub) | sk --preview 'eza -1 --icons --group-directories-first {} --color=always')

        if not test -z "$dir"
            z $dir
            t
        end
    end
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

alias th "cd ~; rpg-cli cd ."

starship init fish | source
zoxide init fish | source
atuin init fish | source
