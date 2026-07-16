use launcher.nu

let teams_url = "https://teams.microsoft.com"
let slack_url = "https://cvation.slack.com"
let outlook_url = "https://outlook.cloud.microsoft"

let user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36"

let common_args = [
    "--enable-features=UseOzonePlatform"
    "--ozone-platform=wayland"
    $"--user-agent=($user_agent)"
]

launcher [
    [
        "Skaylink teams"
        {|| ^flatpak run com.microsoft.Edge $"--app=($teams_url)" ...$common_args }
    ]
    [
        "Skaylink outlook"
        {|| ^flatpak run com.microsoft.Edge $"--app=($outlook_url)" ...$common_args }
    ]
    [
        "cvation teams"
        {|| ^flatpak run com.google.Chrome $"--app=($teams_url)" ...$common_args }
    ]
    [
        "Slack"
        {|| ^flatpak run com.google.Chrome $"--app=($slack_url)" ...$common_args }
    ]
    [
        "cvation outlook"
        {|| ^flatpak run com.google.Chrome $"--app=($outlook_url)" ...$common_args }
    ]
] "Coms"
