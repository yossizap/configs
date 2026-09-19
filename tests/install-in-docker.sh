#!/usr/bin/env bash
set -euo pipefail

ubuntu_version="${1:?usage: $0 UBUNTU_VERSION}"
case "$ubuntu_version" in
    22.04 | 24.04 | 26.04) ;;
    *)
        echo "Unsupported Ubuntu test version: $ubuntu_version" >&2
        exit 2
        ;;
esac

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# The continued lines belong to the script passed to the container's shell.
# shellcheck disable=SC1004
docker run --rm \
    --volume "$repo_dir:/source:ro" \
    "ubuntu:$ubuntu_version" \
    bash -euxo pipefail -c '
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get install -y --no-install-recommends ca-certificates rsync
        cp -a /source /tmp/configs
        cd /tmp/configs
        env \
            VIM_FROM_SOURCE=false \
            TMUX_FROM_SOURCE=false \
            INSTALL_VIM_PLUGINS=false \
            INSTALL_OH_MY_ZSH=false \
            INSTALL_NVM=false \
            INSTALL_COMPLETION_TOOLS=false \
            INSTALL_DOCKER=false \
            INSTALL_CONDA=false \
            INSTALL_NERD_FONT=false \
            CONFIGURE_TERMINAL_FONT=false \
            CHANGE_DEFAULT_SHELL=false \
            ./install.sh
        command -v vim
        command -v tmux
        command -v fzf
        command -v batcat
        bash -n .bashrc install.sh
        zsh -n .zshrc
        tmux -f .tmux.conf start-server
        vim -Nu .vimrc -n -es +qa
    '
