# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

bindkey -e
bindkey '^H' backward-kill-word

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/kielar/.zshrc'
zstyle ':completion:*' completer _expand_alias _complete _ignored
zstyle ':completion:*' regular true

autoload -Uz compinit
compinit
# End of lines added by compinstall

unsetopt BEEP

eval "$(oh-my-posh init zsh --config ~/.poshthemes/default-vpn.omp.json)"
enable_poshtooltips
enable_poshtransientprompt

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ls='ls -CF --color=auto --group-directories-first'
alias ll='ls -lah'
alias cdwin='cd /mnt/c/Users/$USER/\b'

hostip() {
  export HOST_IP=$(ipconfig.exe | grep 'vEthernet (WSL)' -A4 | cut -d":" -f 2 | tail -n1 | sed -e 's/\s*//g')
}

display() {
  export DISPLAY=$HOST_IP:0.0
  export PULSE_SERVER=$HOST_IP
  export LIBGL_ALWAYS_INDIRECT=1
  export NO_AT_BRIDGE=1
  echo " * HOST_IP: $HOST_IP"
  echo " * DISPLAY: $DISPLAY"
  if nc -zw1 $HOST_IP 6000; then
    export X_SERVER=on
  else
    unset  X_SERVER
  fi
  echo " * X_SERVER: ${X_SERVER:-off}"
}

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
  export VPN=on
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
  unset VPN
  echo " * VPN: ${VPN:-off}"
}

vpn() {
  echo " * Checking for VPN connection..."
  wget -q -T 1 --spider google.com
  #ping -w 1 192.168.1.1 > /dev/null
  if [ $? -ne 0 ]; then
    vpnon
  else
    vpnoff
  fi
  hostip
  display
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

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi
