#!/bin/zsh

[ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
  source "$EAT_SHELL_INTEGRATION_DIR/zsh"

# Get it out of here
[ -d ~/Downloads ] && [ -z "$(ls ~/Downloads)" ] && rmdir ~/Downloads/

# ZSH Configurations
unsetopt autocd               # Change directory just by typing its name (hurts performance)
setopt interactivecomments    # Allow comments in interactive mode
setopt complete_aliases       # Allows auto-completion with aliases
setopt magicequalsubst        # Enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch              # Hide error message if there is no match for the pattern
setopt notify                 # Report the status of background jobs immediately
setopt numericglobsort        # Sort filenames numerically when it makes sense
setopt promptsubst            # Enable command substitution in prompt
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
unsetopt ksharrays # 0-indexing arrays breaks highlighting

# vi mode
bindkey -v
bindkey -M vicmd -r ":"
export KEYTIMEOUT=1

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

## ALIASES ##

# The rice repo
alias config='git --git-dir $HOME/repos/dotfiles/ --work-tree=$HOME'

# WSL
alias wclip='/mnt/c/Windows/System32/clip.exe'
alias wclipget='/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -c Get-Clipboard'

alias s='sudo ' # Allow aliases to be passed to sudo
alias pypr='sh -c pypr'
alias asciiquarium='asciiquarium -t'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias python='python3'
alias xournal='xournalpp'
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'
alias sxiv='nsxiv'
alias blueman='blueman-manager'
alias spotify='dlkiller spotify'
alias zoom='dlkiller zoom'
alias tor='torbrowser-launcher'
alias emax="devour emacsclient -c -a 'emacs' 1>/dev/null"
alias em="emacsclient -nw -a 'emacs -nw'"

# Colorful output
alias ls='LC_COLLATE=C ls --color=auto --group-directories-first -hN -A'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias gcc='grc gcc'
alias ifconfig='grc ifconfig'
alias make='grc make'
alias netstat='grc netstat'
alias nmap='grc nmap'
alias ping='grc ping'
alias ping='grc ping'
alias uptime='grc uptime'

## FUNCTIONS ##

function colors {
    for i in {0..255}; do 
        print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$"\n"}; 
    done
}

function increase_opacity {
    printf "\033]11;rgba:00/00/00/ff\007"
}
function decrease_opacity {
    printf "\033]11;rgba:00/00/00/00\007"
}

function pwdterm {
    # New terminal in the current working directory
    setsid -f $TERMINAL -e $SHELL >/dev/null 2>&1 &
}

function ya() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function lfcd {
    tmp="$(mktemp)"
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}

function nix-clean {
    nix-env --delete-generations old
    nix-store --gc
    nix-channel --update
    nix-env -u --always
    for link in /nix/var/nix/gcroots/auto/*
    do
        rm $(readlink "$link")
    done
    nix-collect-garbage -d
}

# This script was automatically generated by the broot program
# More information can be found in https://github.com/Canop/broot
# This function starts broot and executes the command
# it produces, if any.
# It's needed because some shell commands, like `cd`,
# have no useful effect if executed in a subshell.
function br {
    local cmd cmd_file code
    cmd_file=$(mktemp)
    if broot --outcmd "$cmd_file" "$@"; then
        cmd=$(<"$cmd_file")
        command rm -f "$cmd_file"
        eval "$cmd"
    else
        code=$?
        command rm -f "$cmd_file"
        return "$code"
    fi
}

function nix_shell_menu {
    shell_dir="$HOME/shells"
    shells=$(ls "$shell_dir")
    selection=$(echo "$shells" | rofi -dmenu)
    nix-shell "$shell_dir/$selection" --run "
        export name=${selection%.*};
        $([ "$1" = "fhs" ] && echo "fhs-run ")$([ "$1" = "sudo" ] && echo "sudo ")$SHELL
    "
}

function nixstore () {
    cd "$(dirname $(readlink -f $(which "$1")))"
}

# function man () {
#     emacsclient -nw --eval '(progn (man "'$1'"))'
# }

## KEYBINDS ##

zle -N increase_opacity
zle -N decrease_opacity
bindkey '^[s' decrease_opacity
bindkey '^[a' increase_opacity

bindkey -s '^e' 'ya\n'
bindkey -s '^n' 'nix_shell_menu'

zle -N pwdterm
bindkey '^[^M' pwdterm

# Enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

# Remove green background of simlinks
LS_COLORS+=':ow=01;33' 

# Don't consider certain characters part of the word
WORDCHARS=${WORDCHARS//\/} 

# History configurations
export HISTFILE=~/.local/share/history
HISTSIZE=1000
SAVEHIST=2000
alias history="history 0"     # force zsh to show the complete history

export GPG_TTY=$(tty)

if [ ! -z "$(grep nixos /etc/os-release)" ]; then
    # Shell niceties
    source /run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    # Use zsh as default nix build shell
    source /run/current-system/sw/share/zsh-nix-shell/nix-shell.plugin.zsh
    nix-shell-name() {
        # If hopping into a pkg subshell, the shell name should reflect the
        # package linked. (i.e.: 'nix-shell -p nyancat' => 'export name=nyancat')
        if [ "$1" = "-p" ]; then
            nix-shell "$@" --command "export name='$2'"
        else
            nix-shell "$@"
        fi
    }
    alias nix-shell=nix-shell-name
else
    source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
fi

source ~/.config/zsh/.zshhighlighting

if [ -f  ~/.config/zsh/.zshpersonalrc ]; then
    source ~/.config/zsh/.zshpersonalrc
fi

accent_color="$(cat $HOME/.config/colors/accent)"
starship config format "'''[╭──\([\$username@\$hostname](bold $accent_color)\)-\[\$directory\](-\[\$git_branch\$git_metrics\$git_status\])(-\[\$nix_shell\])]($accent_color) \$cmd_duration
[╰─]($accent_color)[\$shell](bold $accent_color) '''"
eval "$(starship init zsh)"
