#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

bash -n .bashrc install.sh tests/install-in-docker.sh tests/lint.sh user-install.sh
zsh -n .zshrc
shellcheck install.sh tests/install-in-docker.sh tests/lint.sh

socket="lint-$$"
lint_home="$(mktemp -d)"
trap 'tmux -L "$socket" kill-server 2>/dev/null || true; rm -rf "$lint_home"' EXIT
mkdir -p "$lint_home/.vim/autoload" "$lint_home/.vim/colors"
cp autoload/configs_project.vim "$lint_home/.vim/autoload/"
cp themes/molokai.vim "$lint_home/.vim/colors/"
HOME="$lint_home" vim -Nu .vimrc -n -es +qa
TMUX_THEME_PREVIEW=1 tmux -L "$socket" -f .tmux.conf start-server
