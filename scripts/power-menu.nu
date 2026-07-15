use launcher.nu

launcher [
    [" Lock",      {|| ^swaylock }]
    [" Power off", {|| ^systemctl poweroff }]
    [" Reboot",    {|| ^systemctl reboot }]
    ["󰤄 Suspend",   {|| ^systemctl suspend }]
    [" Log out",   {|| ^niri msg action quit --skip-confirmation }]
] " "

