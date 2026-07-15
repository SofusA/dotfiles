export def main [entries: list, prompt: string] {
    let chosen = (
        $entries
        | each {|entry| $entry.0 }
        | str join "\n"
        | fuzzel --dmenu --prompt $"($prompt) "
    )

    let matches = $entries | where {|entry| $entry.0 == $chosen }

    if ($matches | is-not-empty) {
        do ($matches | first | get 1)
    }
}

