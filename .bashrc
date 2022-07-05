# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=10000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM=auto
export GIT_PS1_STATESEPARATOR=''
export GIT_PS1_SHOWCOLORHINTS=1

if [ "$color_prompt" = yes ]; then
   # $WSL_DISTR_NAME <> $HOST_IP
   PS1='$(if [[ "$VPN" == "true" ]]; then echo "vpn "; fi)${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@$WSL_DISTRO_NAME\[\033[00m\] \[\033[01;34m\]\w\[\033[0m\]$(__git_ps1 " \e[1;33m┢%s")\[\033[0m\]$(if [[ $? == 0 ]]; then echo " $"; else echo -e " \e[31m$\e[0m"; fi) '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@$WSL_DISTRO_NAME:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@$WSL_DISTRO_NAME: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alFh'
alias la='ls -Ah'
alias l='ls -CFh'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

vpnon() {
  # setup apt proxy
  cp -f ~/vpn/proxy ~/vpn/proxy.conf
  # setup env proxy
  # export PROXY=http://10.144.1.10:8080
  export PROXY=http://87.254.212.120:8080
  export proxy=$PROXY
  export HTTP_PROXY=$PROXY
  export http_proxy=$PROXY
  export HTTPS_PROXY=$PROXY
  export https_proxy=$PROXY
  export NO_PROXY=.nokia.net,.alcatel-lucent.com,localhost,127.0.0.1,192.168.59.0/24,192.168.39.0/24,192.168.49.0/24,10.96.0.0/12
  export no_proxy=$NO_PROXY
  echo " * PROXY: set"
  export VPN=true
  # setup DISPLAY
  #HOST_NAME=N-20HEPF0XGEPG.nsn-intra.net
  #HOST_IP=$(host N-20HEPF0XGEPG.nsn-intra.net | awk '{ print $4 }')
  HOST_IP=$(pwsh.exe -Command "& {Get-NetAdapter |  Where-Object InterfaceDescription -like \"*AnyConnect*Virtual*Adapter*\" |   Get-NetIPAddress -AddressFamily IPv4 |  Select-Object -ExpandProperty IPAddress}")
  export HOST_IP=$(echo -n ${HOST_IP::-1})
  export DISPLAY=$HOST_IP:0.0
  export PULSE_SERVER=tcp:$HOST_IP
  export LIBGL_ALWAYS_INDIRECT=1
  export NO_AT_BRIDGE=1
  echo " * HOST_IP: $HOST_IP"
  echo " * DISPLAY: $DISPLAY"
  echo " * VPN: $VPN"
}

vpnoff() {
  # unset apt proxy
  cp -f ~/vpn/no-proxy ~/vpn/proxy.conf
  # unset env proxy
  unset PROXY
  unset proxy
  unset HTTP_PROXY
  unset http_proxy
  unset HTTPS_PROXY
  unset https_proxy
  unset NO_PROXY
  unset no_proxy
  echo " * PROXY: unset"
  export VPN=false
  # setup DISPLAY
  #export DISPLAY=host.docker.internal:0.0
  #HOST_IP=$(pwsh.exe -Command "& {Get-NetAdapter |  Where-Object InterfaceDescription -like \"*AnyConnect*Virtual*Adapter*\" |   Get-NetIPAddress -AddressFamily IPv4 |  Select-Object -ExpandProperty IPAddress}")
  #HOST_IP=$(echo -n ${HOST_IP::-1})
  export HOST_IP=host.docker.internal
  export DISPLAY=host.docker.internal:0.0
  export PULSE_SERVER=tcp:host.docker.internal
  export LIBGL_ALWAYS_INDIRECT=1
  export NO_AT_BRIDGE=1
  echo " * HOST_IP: $HOST_IP" 
  echo " * DISPLAY: $DISPLAY"
  echo " * VPN: $VPN"
}

vpn() {
  echo " * Checking for VPN connection..."
  #wget -q -T 1 --spider google.com
  ping -w 1 192.168.1.1 > /dev/null
  if [ $? -ne 0 ]; then
    vpnon
  else
    vpnoff
  fi
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#sudo ip link set dev eth0 mtu 1350


alias idea='~/idea-IU-212.5080.55/bin/idea.sh 2> ~/.idea/stderr 1> ~/.idea/stdout &'
alias pycharm='~/pycharm-community-2021.2.1/bin/pycharm.sh 2> ~/.pycharm/stderr 1> ~/.pycharm/stdout &'
alias mora='~/mora/mora.sh'
alias hostip='echo $HOST_IP'

export WINHOME=/mnt/c/Users/$USER
cdh() {
  cd $WINHOME/"$@"
}

echo " * Starting wsl-vpnkit... "
wsl.exe -d wsl-vpnkit service wsl-vpnkit start

vpn

source "/home/kielar/.rover/env"

#echo -n "Starting Docker service..."
sudo service docker start

echo " * Eval minikube docker-env..."
eval $(minikube -p minikube docker-env)

SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {
    echo " * Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

. ~/.git/git-completion.bash

