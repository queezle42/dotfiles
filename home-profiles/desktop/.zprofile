# start sway when logging in on tty1
if [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] && [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
  exec sway --config ${swayConfig} &> /run/user/$UID/sway_log
fi