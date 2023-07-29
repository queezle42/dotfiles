{ lib, pkgs, config, ... }:
with lib;
pkgs.writeText "kitty.conf" ''
# kitty.conf

font_family      PragmataPro Mono Liga

#font_family      Fira Code
#italic_font      auto
#bold_font        Fira Code Bold
#bold_italic_font auto

font_size        10

cursor_blink_interval     0.5

cursor_stop_blinking_after 5

scrollback_lines 10000
scrollback_pager_history_size 10

scrollback_fill_enlarged_window yes

mouse_hide_wait -3

enable_audio_bell no
visual_bell_duration 0.05

# Shell integration should be done in the shell
shell_integration disabled


${builtins.readFile "${pkgs.vimPlugins.kanagawa-nvim}/extras/kanagawa.conf"}


update_check_interval 0

map kitty_mod+plus change_font_size current +0.5
map kitty_mod+minus change_font_size current -0.5
map kitty_mod+backspace restore_font_size
map kitty_mod+´ set_font_size 8.5

map kitty_mod+f run_kitten text hints
map kitty_mod+u input_unicode_character

map kitty_mod+enter new_os_window_with_cwd
''
