set -g -x LC_ALL C

alias h hx

set -gx EDITOR hx
set -U fish_greeting
set -g -x ASPNETCORE_ENVIRONMENT Test

set -gx LOCALE_ARCHIVE /usr/lib/locale/locale-archive

# set PATH /var/home/sofusa/.npm-packages/bin $PATH
fish_add_path ~/.cargo/bin/

alias ls "eza -1 --icons --group-directories-first"

alias gui gitui
alias gap "git commit --amend && git push --force"
alias gp "git push"
alias gpu "git pull"
alias gpud "git pull origin develop"

alias dnr "~/dotnet-run-multiple/target/release/dotnet_run_multi"

alias git "flatpak-spawn --host git"

function gdb
    git fetch
    set branch (git branch | grep -v ^\* | sk)
    if not test -z "$branch"
        set trim (string trim $branch)
        git branch -d $trim
    end

end

function gsb
    git fetch
    set branch (git branch -a --format='%(refname:short)' | sk)

    if not test -z "$branch"
        git checkout $branch
    end
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

function hs
    set file (rg --files-with-matches --no-messages $argv[1] | sk --preview "hgrep $argv[1] {} --theme=TwoDark --no-grid --term-width 200")
    h $file
end

alias th "cd ~"

starship init fish | source
zoxide init fish | source
atuin init fish | source
