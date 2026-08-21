#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH="$HOME/.local/bin:$PATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

export BROWSER=firefox

#if uwsm check may-start && uwsm select; then
# uwsm start default
#fi

# Start Mango

if uwsm check may-start; then
  uwsm start mango
fi
