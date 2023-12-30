alias updot '~/dotfiles/replace_config'

alias h helix
alias t z

alias host "flatpak-spawn --host"

set -gx EDITOR helix
set -U fish_greeting
set -g -x ASPNETCORE_ENVIRONMENT Test

set -gx LOCALE_ARCHIVE /usr/lib/locale/locale-archive

set PATH /var/home/sofusa/.npm-packages/bin $PATH

alias ls "eza -1 --icons --group-directories-first"

alias gui "gitui"
alias gap "git commit --amend && git push --force"
alias gp "git push"
alias gpu "git pull"
alias gpud "git pull origin develop"

function gdb
    set branch (git branch | grep -v ^\* | fzf)
    if not test -z "$branch"
        set trim (string trim $branch)
        git branch -d $trim
    end

end

function gsb
    set branch (git branch --format='%(refname:short)' | fzf)

    if not test -z "$branch"
        git checkout $branch
    end
end

alias dt "dotnet test"
function dtt
    dotnet test --filter Name~$argv
end

function ts
    set dir (fd -t d | fzf)

    if not test -z "$dir"
        cd $dir
    end
end

starship init fish | source
zoxide init fish | source
