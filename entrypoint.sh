#!/bin/bash -x

# sets the default shell prompt for interactive shells
# prompt placeholders:
#  \u → current username
#  \h → hostname (up to first dot)
#  \W → current working directory (basename only)
#  \$ → shows # if root, $ if non-root
# export PS1="[\u@\h \W]\$ "

# disable command echo
set +x

echo "Start entrypoint.sh $@"

# get home path and trim it with pattern removal
DIR=$(ls -d /home/*)
USER=${DIR##*/}

# UserId and GroupId from the host system
DIR_GID=$(stat -c '%g' $DIR)
DIR_UID=$(stat -c '%g' $DIR)

service ssh start

export HOME=${DIR}
export USER=${USER}

cd ${DIR}
if [ $(grep -c "\[docker\]" .bashrc) -eq 0 ]; then
cat <<'EOF' >> .bashrc

# Enable color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Custom colored prompt
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# sets the default shell prompt
if [ "$color_prompt" = yes ]; then
    PS1='[docker] \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='[docker] \u@\h:\w\$ '
fi
EOF
fi

set -x

# service ssh start, forward the .sh parameters
# exec gosu ${USER} tail -f /dev/null
exec gosu ${USER} $@

echo "End entrypoint.sh"
