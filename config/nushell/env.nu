$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

$env.EDITOR = "hx"

if not ("~/.local/share/zoxide/init.nu" | path exists) {
  mkdir ~/.local/share/zoxide
  zoxide init nushell | save -f ~/.local/share/zoxide/init.nu
}

if not ("~/.local/share/carapace/init.nu" | path exists) {
  mkdir ~/.local/share/carapace
  carapace _carapace nushell | save -f ~/.local/share/carapace/init.nu
}

if not ("~/.local/share/atuin/init.nu" | path exists) {
  mkdir ~/.local/share/atuin/
  atuin init nu | save -f ~/.local/share/atuin/init.nu
}

if not ("~/.local/share/starship/init.nu" | path exists) {
  mkdir ~/.local/share/starship
  starship init nu | save -f ~/.local/share/starship/init.nu
}
