# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

bindkey -e
bindkey '^H' backward-kill-word
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey ';5D' backward-word
bindkey ';5C' forward-word

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/kielar/.zshrc'
zstyle ':completion:*' completer _expand_alias _complete _ignored
zstyle ':completion:*' regular true

autoload -Uz compinit
compinit
# End of lines added by compinstall

#unsetopt BEEP

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

alias ls='ls -aCF --color=auto --group-directories-first'
alias ll='ls -lh'
alias cdwin='cd /mnt/c/Users/$USER/\b'
alias proxy='. $HOME/proxy/proxy'
alias proxyon='. $HOME/proxy/proxyon'
alias proxyoff='. $HOME/proxy/proxyoff'

hostip() {
  export HOST_IP=$(ipconfig.exe | grep 'vEthernet (WSL)' -A4 | cut -d":" -f 2 | tail -n1 | sed -e 's/\s*//g')
  echo "  Host IP: $HOST_IP"
}

display() {
  export PULSE_SERVER=$HOST_IP
  export LIBGL_ALWAYS_INDIRECT=1
  export NO_AT_BRIDGE=1
  if nc -zw1 $HOST_IP 6000; then
    export DISPLAY=$HOST_IP:0.0
  else
    unset  DISPLAY
  fi
  echo "  Display: ${DISPLAY:-off}"
}

pogoda() {
  param=$(echo $* | sed 's/ /+/g')
  curl "wttr.in/${param:-Dobroszyce}?n&lang=pl"
}

hibernate() {
  for i in $(seq $1 -1 1); do
    echo $i
    sleep 1
  done
  echo "⏻ Hibernating in $1 seconds..."
  return 0
}

echo "  Starting wsl-vpnkit... "
wsl.exe -d wsl-vpnkit service wsl-vpnkit start

hostip
display

source "/home/kielar/.rover/env"
#echo -n "Starting Docker service..."
sudo service docker start

echo "  Eval minikube docker-env..."
eval $(minikube -p minikube docker-env)

SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {
    echo "  Initialising new SSH agent..."
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

export PATH="$HOME/.local/bin:$PATH"

