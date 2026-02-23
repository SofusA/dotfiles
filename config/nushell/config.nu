export-env {
  # EDITOR
  $env.EDITOR = "hx"
  $env.config.show_banner = false

  # Order:
  # 1) /var/home/sofusa/build/bin
  # 2) /usr/libexec/uutils-coreutils
  # 3) /var/home/sofusa/.cargo/bin
  # 4) /usr/bin
  # 5) existing PATH (if any)
  let existing = ($env.PATH? | default [])
  $env.PATH = [
    "/var/home/sofusa/build/bin"
    "/usr/libexec/uutils-coreutils"
    "/var/home/sofusa/.cargo/bin"
    "/usr/bin"
    ...$existing
  ]

  # Prompt command must be a closure
  $env.PROMPT_COMMAND = {|| create-prompt }
  $env.PROMPT_COMMAND_RIGHT = {|| "" }
}

alias h = hx

alias nb = jj bookmark
alias nbs = jj bookmark set --revision=@
alias nd = jj describe -m
alias nl = jj log
alias np = jj git push
alias npc = jj git push -c @
alias nf = jj git fetch
alias nn = jj new
alias nbm = nb move --from @- --to @
alias n = jj
alias nr = tv jjrestore

alias music = qobuz-player open --audio-cache ~/Music --audio-cache-time-to-live 720

alias sudo = sudo-rs

def jj_prompt [] {
  # If jj is missing, nothing to show
  if (which jj | is-empty) {
    return ""
  }

  # If not inside a jj repo/root, nothing to show
  let root_ok = (jj root --quiet | complete | get exit_code)
  if $root_ok != 0 {
    return ""
  }

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
}


def create-prompt [] {
    let raw_path = $env.PWD
    let home = $env.HOME

    # Replace $HOME prefix with ~
    let display_path = if ($raw_path | str starts-with $home) {
        $raw_path | str replace $home "~"
    } else {
        $raw_path
    }

    let last = $env.LAST_EXIT_CODE
    let stat = if $last != 0 { $"(ansi red)[$last](ansi reset)" } else { "" }

    let jjinfo = (jj_prompt)

    $"(ansi blue)($display_path)(ansi reset)($jjinfo)($stat)"
}

def y [...args] {
  let tmp = (mktemp -t "yazi-cwd.XXXXXX")
  yazi ...$args --cwd-file $tmp

  let cwd = (open $tmp | str trim)
  if ($cwd != "" and $cwd != $env.PWD) {
    cd $cwd
  }

  rm -f $tmp
}

alias th = cd ~

source ~/.local/share/atuin/init.nu
source ~/.local/share/pathmarks/init.nu
