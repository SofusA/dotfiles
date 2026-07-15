alias h hx
set -gx EDITOR hx

alias nb "jj bookmark"
alias nbs "jj bookmark set --revision=@"
alias nd "jj describe -m"
alias nl "jj log"
alias npc "jj git push -c @"
alias nf "jj git fetch"
alias nn "jj new"
alias nbm "nb advance"
alias n jj
alias nr "tv jjrestore"

function np
    jj git push $argv
    set -l push_status $status

    if test $push_status -ne 0
        return $push_status
    end

    if test -n "$(jj log -r 'immutable() & @' --no-graph --color never -T 'commit_id' 2>/dev/null)"
        jj new
    end
end

alias music "qobuz-tui --audio-cache ~/Music --audio-cache-time-to-live 720"

function ls
    eza -1 --icons --group-directories-first $argv
end

alias sudo sudo-rs
alias crlf-line-endings "fd -t f -x perl -pi -e 's/\r?\n/\r\n/g'"

function fish_jj_prompt --description 'Write out the jj prompt'
    if not command -sq jj
        return 1
    end

    if not jj root --quiet &>/dev/null
        return 1
    end

    jj log --no-graph --color always -r @ -T '
        separate(
            " ",
            bookmarks.join(", "),
            coalesce(
                if(
                    description.first_line().substr(0, 24).starts_with(description.first_line()),
                    description.first_line().substr(0, 24),
                    description.first_line().substr(0, 23) ++ "…"
                ),
                description_placeholder
            ),
            if(conflict, label("conflict", "conflict")),
            if(divergent, "divergent"),
            if(hidden, "hidden")
        )
    '
end

function fish_prompt
    set -l last_status $status
    set -l stat

    if test $last_status -ne 0
        set stat (set_color red)"[$last_status]"(set_color normal)
    end

    string join '' -- (set_color blue) (prompt_pwd) (set_color normal)\ \((fish_jj_prompt)\) $stat '> '
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
