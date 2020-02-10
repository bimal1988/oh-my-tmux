#!/usr/bin/env bash

ok() {
    printf "\e[0;32m[ OK ]\e[0m\t$1\n"
}

fail() {
    printf "\e[0;31m[FAIL]\e[0m\t$1\n"
    exit 1
}

info() {
    printf "[INFO]\t$1\n"
}

backupIfExisting() {
    if [ -e "$1" ]; then
        info "'$1' already exists - creating backup"
        current_time=$(date "+%Y_%m_%d-%H_%M_%S")
        mv "$1" "$1__$current_time.backup"
    fi
}

createLink() {
    ln -s -f $1 $2

    if [ "$?" -ne 0 ]; then
        fail "Unable to create link $1 --> $2"
    fi
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMUX_CONF_DIR=$HOME/.tmux
TMUX_CONF_FILE=$HOME/.tmux.conf

backupIfExisting $TMUX_CONF_DIR
backupIfExisting $TMUX_CONF_FILE

# Install tpm- Tmux Plugin Manager
info "Installing Tmux Plugin Manager"
git clone https://github.com/tmux-plugins/tpm $TMUX_CONF_DIR/plugins/tpm

createLink $SCRIPT_DIR/tmux.conf $TMUX_CONF_FILE
createLink $SCRIPT_DIR/yank.sh $TMUX_CONF_DIR/yank.sh
createLink $SCRIPT_DIR/renew_env.sh $TMUX_CONF_DIR/renew_env.sh

# Install tpm plugins
info "Installing plugins"
sh $TMUX_CONF_DIR/plugins/tpm/bin/install_plugins

info "Plugins installed"
ok "Configuration complete"
