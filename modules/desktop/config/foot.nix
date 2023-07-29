{ lib, pkgs, config, floating ? false, ... }:
with lib;
let
font = "monospace:size=${toString config.queezle.desktop.font.monospace.size}";
theme = kanagawa;

gruvbox = ''
foreground=ebdbb2
background=1d2021
regular0=282828  # black
regular1=cc241d  # red
regular2=98971a  # green
regular3=d79921  # yellow
regular4=458588  # blue
regular5=b16286  # magenta
regular6=689d6a  # cyan
regular7=a89984  # white
bright0=928374   # bright black
bright1=fb4934   # bright red
bright2=b8bb26   # bright green
bright3=fabd2f   # bright yellow
bright4=83a598   # bright blue
bright5=d3869b   # bright magenta
bright6=8ec07c   # bright cyan
bright7=ebdbb2   # bright white
'';

kanagawa = ''
[colors]
foreground = dcd7ba
background = ${if floating then "16161d" else "1f1f28"}

selection-foreground = c8c093
selection-background = 2d4f67

regular0 = 090618
regular1 = c34043
regular2 = 76946a
regular3 = c0a36e
regular4 = 7e9cd8
regular5 = 957fb8
regular6 = 6a9589
regular7 = c8c093

bright0  = 727169
bright1  = e82424
bright2  = 98bb6c
bright3  = e6c384
bright4  = 7fb4ca
bright5  = 938aa9
bright6  = 7aa89f
bright7  = dcd7ba

16       = ffa066
17       = ff5d62
'';

in pkgs.writeText "foot.ini" ''
# foot config file

dpi-aware=no

font=${font}

[scrollback]
lines=10000

[mouse]
hide-when-typing=yes

[colors]
${theme}

[key-bindings]
spawn-terminal=Control+Shift+Return
font-increase=Control+Shift+plus
font-decrease=Control+Shift+minus
font-reset=Control+Shift+0
''
