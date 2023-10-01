alias upgrade 'sudo pacman -Syu --noconfirm; paru -Syu --noconfirm'
alias updot '~/dotfiles/replace_config'
alias ls 'exa -1 --color=always --group-directories-first'
alias hxg 'nix run github:helix-editor/helix'

set -gx EDITOR hx
set -U fish_greeting
set -g -x ASPNETCORE_ENVIRONMENT Test

set -gx LOCALE_ARCHIVE /usr/lib/locale/locale-archive

set PATH /var/home/sofusa/.npm-packages/bin $PATH

alias gui "gitui"
alias gap "git commit --amend && git push --force"
alias gp "git push"
alias gpu "git pull"
alias gpud "git pull origin develop"

alias dt "dotnet test"
function dtt
    dotnet test --filter Name~$argv
end

function drmock
    cd ~/Documents/CorporateActions/src
    dotnet run --project IOS.Dimension.Mock --launch-profile http
end

function drapi    
    cd ~/Documents/CorporateActions/src
    dotnet run --project IOS.Api 
end

starship init fish | source
zoxide init fish | source
