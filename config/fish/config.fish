alias h hx
set -gx EDITOR hx

alias nb "jj bookmark"
alias nbs "jj bookmark set --revision=@"
alias nd "jj describe -m"
alias nl "jj log"
alias np "jj git push"
alias npc "jj git push -c @"
alias nf "jj git fetch"
alias nn "jj new"
alias nbm "nb move --from @- --to @"
alias n jj
alias nr "tv jjrestore"

alias music "qobuz-player open --audio-cache ~/Music --audio-cache-time-to-live 720"

function ls
    eza -1 --icons --group-directories-first $argv
end

alias sudo sudo-rs

function fish_jj_prompt --description 'Write out the jj prompt'
    if not command -sq jj
        return 1
    end

    if not jj root --quiet &>/dev/null
        return 1
    end

    jj log --ignore-working-copy --no-graph --color always -r @ -T '
        surround(
            " (",
            ")",
            separate(
                " ",
                bookmarks.join(", "),
                coalesce(
                    if(
                        description.first_line().substr(0, 24).starts_with(description.first_line()),
                        description.first_line().substr(0, 24),
                        description.first_line().substr(0, 23) ++ "…"
                    ),
                    label(if(empty, "empty"), description_placeholder)
                ),
                if(conflict, label("conflict", "conflict")),
                if(empty, label("empty", "empty")),
                if(divergent, "divergent"),
                if(hidden, "hidden"),
            )
        )
    '
end

function fish_prompt
    set -l last_status $status
    set -l stat

    if test $last_status -ne 0
        set stat (set_color red)"[$last_status]"(set_color normal)
    end

    string join '' -- (set_color blue) (prompt_pwd) (set_color normal) (fish_jj_prompt) $stat '> '
end

alias dt "dotnet test"
function dtt
    dotnet test -v quiet --nologo -l:"console;verbosity=normal" --filter Name~$argv
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

alias th "cd ~"

atuin init fish | sed 's/-k up/up/' | source
pathmarks init fish | source
