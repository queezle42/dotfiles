{ pkgs, ... }:

let
  promptPath = ../../zsh/prompt;

in
{
  environment.systemPackages = with pkgs; [
    neovim
    less
  ];

  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;

  programs.zsh.promptInit = ''
if [ "$TERM" != dumb ]
then
  fpath=(
    ${promptPath}
    $fpath
  )
  source ${promptPath}/load_prompt
fi
  '';

  environment.shellAliases = {
    # 'root' gives a proper root login session
    #root = "machinectl shell root@";
    root = "sudo su";

    ls = "ls --color=auto";
    l = "ls -l";
    lh = "ls -lh";
    la = "ls -la";
    lah = "ls -lah";

    cal = "cal --monday";

    copy = "xclip -selection c -i";
    paste = "xclip -selection c -o";

    mqtt_sub = "mosquitto_sub";
    mqtt_pub = "mosquitto_pub";

    myip = "drill @resolver1.opendns.com any myip.opendns.com";
    myipv4 = "drill -4 @resolver1.opendns.com any myip.opendns.com";
    myipv6 = "drill -6 @resolver1.opendns.com any myip.opendns.com";
  };

  environment.shellInit = ''
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export LS_COLORS='no=00:fi=00:di=34:ow=34;40:ln=35:pi=30;44:so=35;44:do=35;44:bd=33;44:cd=37;44:or=05;37;41:mi=05;37;41:ex=01;31:*.cmd=01;31:*.exe=01;31:*.com=01;31:*.bat=01;31:*.reg=01;31:*.app=01;31:*.txt=32:*.org=32:*.md=32:*.mkd=32:*.h=32:*.c=32:*.C=32:*.cc=32:*.cpp=32:*.cxx=32:*.objc=32:*.sh=32:*.csh=32:*.zsh=32:*.el=32:*.vim=32:*.java=32:*.pl=32:*.pm=32:*.py=32:*.rb=32:*.hs=32:*.php=32:*.htm=32:*.html=32:*.shtml=32:*.erb=32:*.haml=32:*.xml=32:*.rdf=32:*.css=32:*.sass=32:*.scss=32:*.less=32:*.js=32:*.coffee=32:*.man=32:*.0=32:*.1=32:*.2=32:*.3=32:*.4=32:*.5=32:*.6=32:*.7=32:*.8=32:*.9=32:*.l=32:*.n=32:*.p=32:*.pod=32:*.tex=32:*.go=32:*.bmp=33:*.cgm=33:*.dl=33:*.dvi=33:*.emf=33:*.eps=33:*.gif=33:*.jpeg=33:*.jpg=33:*.JPG=33:*.mng=33:*.pbm=33:*.pcx=33:*.pdf=33:*.pgm=33:*.png=33:*.PNG=33:*.ppm=33:*.pps=33:*.ppsx=33:*.ps=33:*.svg=33:*.svgz=33:*.tga=33:*.tif=33:*.tiff=33:*.xbm=33:*.xcf=33:*.xpm=33:*.xwd=33:*.xwd=33:*.yuv=33:*.aac=33:*.au=33:*.flac=33:*.m4a=33:*.mid=33:*.midi=33:*.mka=33:*.mp3=33:*.mpa=33:*.mpeg=33:*.mpg=33:*.ogg=33:*.ra=33:*.wav=33:*.anx=33:*.asf=33:*.avi=33:*.axv=33:*.flc=33:*.fli=33:*.flv=33:*.gl=33:*.m2v=33:*.m4v=33:*.mkv=33:*.mov=33:*.MOV=33:*.mp4=33:*.mp4v=33:*.mpeg=33:*.mpg=33:*.nuv=33:*.ogm=33:*.ogv=33:*.ogx=33:*.qt=33:*.rm=33:*.rmvb=33:*.swf=33:*.vob=33:*.webm=33:*.wmv=33:*.doc=31:*.docx=31:*.rtf=31:*.dot=31:*.dotx=31:*.xls=31:*.xlsx=31:*.ppt=31:*.pptx=31:*.fla=31:*.psd=31:*.7z=1;35:*.apk=1;35:*.arj=1;35:*.bin=1;35:*.bz=1;35:*.bz2=1;35:*.cab=1;35:*.deb=1;35:*.dmg=1;35:*.gem=1;35:*.gz=1;35:*.iso=1;35:*.jar=1;35:*.msi=1;35:*.rar=1;35:*.rpm=1;35:*.tar=1;35:*.tbz=1;35:*.tbz2=1;35:*.tgz=1;35:*.tx=1;35:*.war=1;35:*.xpi=1;35:*.xz=1;35:*.z=1;35:*.Z=1;35:*.zip=1;35:*.ANSI-30-black=30:*.ANSI-01;30-brblack=01;30:*.ANSI-31-red=31:*.ANSI-01;31-brred=01;31:*.ANSI-32-green=32:*.ANSI-01;32-brgreen=01;32:*.ANSI-33-yellow=33:*.ANSI-01;33-bryellow=01;33:*.ANSI-34-blue=34:*.ANSI-01;34-brblue=01;34:*.ANSI-35-magenta=35:*.ANSI-01;35-brmagenta=01;35:*.ANSI-36-cyan=36:*.ANSI-01;36-brcyan=01;36:*.ANSI-37-white=37:*.ANSI-01;37-brwhite=01;37:*.log=01;32:*~=01;32:*#=01;32:*.bak=01;33:*.BAK=01;33:*.old=01;33:*.OLD=01;33:*.org_archive=01;33:*.off=01;33:*.OFF=01;33:*.dist=01;33:*.DIST=01;33:*.orig=01;33:*.ORIG=01;33:*.swp=01;33:*.swo=01;33:*,v=01;33:*.gpg=34:*.gpg=34:*.pgp=34:*.asc=34:*.3des=34:*.aes=34:*.enc=34:*.sqlite=34:'

# set the default less options
export LESS='-g -i -M -R -S -w -z-4'
  '';
# FIXME: set the less input preprocessor
#export LESSOPEN="| ${pkgs.lesspipe}/bin/lesspipe.sh %s 2>&-"

  programs.zsh.interactiveShellInit = ''
zstyle ':completion:*' auto-description '%d'
zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' format '%d'
zstyle ':completion:*' list-colors "''${(@s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' max-errors 0
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
autoload -Uz compinit
compinit

if (( $+commands[kitty] ))
then
	kitty + complete setup zsh | source /dev/stdin
	alias icat="kitty +kitten icat"
fi

if (( $+commands[direnv] ))
then
  eval "$(direnv hook zsh)"
fi

# "The time the shell waits, in hundredths of seconds, for another key to be pressed when reading bound multi-character sequences."
# This is for vim-style multi-letter commands (<f><d> is mapped to <Esc>)
KEYTIMEOUT=10

HISTSIZE=100000
SAVEHIST=100000

setopt appendhistory histignorealldups
setopt autocd
setopt extendedglob

# Shift-Tab reverse tab through completions
bindkey '^[[Z' reverse-menu-complete

# F1 to view man pages
autoload -Uz run-help
autoload -Uz run-help-sudo
autoload -Uz run-help-git
autoload -Uz run-help-openssl
bindkey '^[OP' run-help

# edit command line using $VISUAL (or $EDITOR)
# bound to ctrl-x-ctrl-e (common shell behaviour) and alt-v (faster shortcut)
zle -N edit-command-line
autoload -Uz edit-command-line
bindkey '\ev' edit-command-line
bindkey '^X^E' edit-command-line

# pos1, end, ctrl+arrow word navigation
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1;5D' emacs-backward-word
bindkey '^[[1;5C' emacs-forward-word

# vi mode
bindkey -v
bindkey 'fd' vi-cmd-mode
# backspace
bindkey '^?' backward-delete-char
# delete key
bindkey '^[[3~' delete-char

# ctrl-j, ctrl-k, alt-p, alt-n: search for commands starting with the current input
bindkey '\ep' history-search-backward
bindkey '^K' history-search-backward
bindkey '\en' history-search-forward
bindkey '^J' history-search-forward
# alt-enter: insert newline without running command
bindkey -M viins '\e\r' self-insert-unmeta

# ctrl-h, ctrl-w, ctrl-? for char and word deletion (standard behavior)
bindkey '^H' backward-delete-char
bindkey '^W' backward-kill-word
bindkey '^U' backward-kill-line

# ctrl-p, ctrl-n for history navigation (standard behavior)
bindkey '^P' up-history
bindkey '^N' down-history

# bind ctrl-r to perform backward search in history
bindkey '^r' history-incremental-search-backward

# bind ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# alt-backspace to kill backwards to the next '/'
backward-kill-dir () {
    local WORDCHARS=''${WORDCHARS/\/}
    zle backward-kill-word
}
zle -N backward-kill-dir
bindkey '^[^?' backward-kill-dir

set-cursor-bar (){
  if [[ "$TERM" = xterm* ]]; then
      echo -ne "\e[6 q"
  fi
}
set-cursor-block() {
  if [[ "$TERM" = xterm* ]]; then
      echo -ne "\e[2 q"
  fi
}

# change cursor on vi mode switch
zle-keymap-select() {
  # FIXME: Activating vi-command-mode (typing ":" in vicmd-keymap) results in incorrect bar cursor
  if [ $KEYMAP = vicmd ]; then
    # vi command mode
    set-cursor-block
  else
    set-cursor-bar
  fi
  zle reset-prompt
  zle -R
}
zle -N zle-keymap-select

# runs before executing a command
preexec() {
  set-cursor-block
}

# runs before new prompt
precmd(){
  # change cursor to bar before new prompt
  set-cursor-bar
}

# use cd tab completion without cdpath if that gives a result
_cd_try_without_cdpath () {
  CDPATH= _cd "$@" || _cd "$@"
}
compdef _cd_try_without_cdpath cd pushd

# colored man output
man() {
  LESS_TERMCAP_md=$'\e[01;31m' \
  LESS_TERMCAP_me=$'\e[0m' \
  LESS_TERMCAP_se=$'\e[0m' \
  LESS_TERMCAP_so=$'\e[01;44;33m' \
  LESS_TERMCAP_ue=$'\e[0m' \
  LESS_TERMCAP_us=$'\e[01;32m' \
  command man "$@"
}
  '';
}
