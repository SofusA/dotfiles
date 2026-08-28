let session_id = (random uuid)
let socket = $env.XDG_RUNTIME_DIR? | default "/tmp" | path join $"hxr-($session_id).sock"

$env.HXR_SESSION_ID = $session_id
$env.HXR_SOCKET = $socket

try {
    ^/home/linuxbrew/.linuxbrew/bin/fish
} finally {
    do -i { ^hxr --stop --socket $socket }
    rm -f $socket
}
