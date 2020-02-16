#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMUX_CONF_DIR=$HOME/.tmux
TMUX_CONF_FILE=$HOME/.tmux.conf

main() {
    need_cmd mv
    need_cmd ln
    need_cmd git

    backup_if_exists $TMUX_CONF_FILE
    backup_if_exists $TMUX_CONF_DIR

    info "Installing Tmux Plugin Manager"
    ensure git clone https://github.com/tmux-plugins/tpm $TMUX_CONF_DIR/plugins/tpm

    ensure ln -s $SCRIPT_DIR/tmux.conf $TMUX_CONF_FILE
    ensure ln -s $SCRIPT_DIR/yank.sh $TMUX_CONF_DIR/yank.sh
    ensure ln -s $SCRIPT_DIR/renew_env.sh $TMUX_CONF_DIR/renew_env.sh

    # Install tpm plugins
    info "Installing plugins"
    sh $TMUX_CONF_DIR/plugins/tpm/bin/install_plugins

    ok "Configuration complete"
}

backup_if_exists() {
    if [ -e "$1" ]; then
        info "Found existing $1, creating backup.."
        current_time=$(date "+%Y_%m_%d-%H_%M_%S")
        local backup_file="$0"__"$current_time".backup
        ensure mv "$1" "$1__$current_time.backup"
        info "Created backup at $backup_dir"
    fi
}

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

check_cmd() {
    command -v "$1" > /dev/null 2>&1
}

need_cmd() {
    if ! check_cmd "$1"; then
        fail "need '$1' (command not found)"
    fi
}

# Run a command that should never fail. If the command fails execution
# will immediately terminate with an error showing the failing
# command.
ensure() {
    if ! "$@"; then fail "command failed: $*"; fi
}

main "$@" || exit 1