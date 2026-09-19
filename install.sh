#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VIM_FROM_SOURCE="${VIM_FROM_SOURCE:-true}"
TMUX_FROM_SOURCE="${TMUX_FROM_SOURCE:-true}"
INSTALL_VIM_PLUGINS="${INSTALL_VIM_PLUGINS:-true}"
INSTALL_ZSH="${INSTALL_ZSH:-true}"
INSTALL_OH_MY_ZSH="${INSTALL_OH_MY_ZSH:-true}"
INSTALL_NVM="${INSTALL_NVM:-true}"
CHANGE_DEFAULT_SHELL="${CHANGE_DEFAULT_SHELL:-true}"
INSTALL_EXTRA_TOOLS="${INSTALL_EXTRA_TOOLS:-true}"
INSTALL_COMPLETION_TOOLS="${INSTALL_COMPLETION_TOOLS:-true}"
INSTALL_DOCKER="${INSTALL_DOCKER:-prompt}"
INSTALL_CONDA="${INSTALL_CONDA:-prompt}"
INSTALL_MAMBA="${INSTALL_MAMBA:-true}"
INSTALL_NERD_FONT="${INSTALL_NERD_FONT:-prompt}"
NERD_FONT_REFRESH="${NERD_FONT_REFRESH:-false}"
CONFIGURE_TERMINAL_FONT="${CONFIGURE_TERMINAL_FONT:-prompt}"
OFFLINE_MODE="${OFFLINE_MODE:-false}"

VIM_REF="${VIM_REF:-v9.2.0782}"
TMUX_REF="${TMUX_REF:-3.5a}"
NVM_REF="${NVM_REF:-master}"
NERD_FONT_NAME="${NERD_FONT_NAME:-JetBrainsMono}"
NERD_FONT_FAMILY="${NERD_FONT_FAMILY:-JetBrainsMono Nerd Font Mono}"
NERD_FONT_SIZE="${NERD_FONT_SIZE:-14}"
SRC_ROOT="${SRC_ROOT:-$REPO_DIR/sources}"
VIM_SRC_DIR="${VIM_SRC_DIR:-$SRC_ROOT/vim}"
TMUX_SRC_DIR="${TMUX_SRC_DIR:-$SRC_ROOT/tmux}"
NERD_FONT_SRC_DIR="${NERD_FONT_SRC_DIR:-$SRC_ROOT/nerd-fonts}"
VIM_PLUG_SRC_DIR="${VIM_PLUG_SRC_DIR:-$SRC_ROOT/vim-plug}"
NVM_SRC_DIR="${NVM_SRC_DIR:-$SRC_ROOT/nvm}"
CONDA_ZSH_COMPLETION_SRC_DIR="${CONDA_ZSH_COMPLETION_SRC_DIR:-$SRC_ROOT/conda-zsh-completion}"
ZSH_SYNTAX_HIGHLIGHTING_SRC_DIR="${ZSH_SYNTAX_HIGHLIGHTING_SRC_DIR:-$SRC_ROOT/zsh-syntax-highlighting}"
VIM_PREFIX="${VIM_PREFIX:-/usr/local}"
TMUX_PREFIX="${TMUX_PREFIX:-/usr/local}"
VIM_CONFIG_DIR="${VIM_CONFIG_DIR:-$HOME/.vim}"
NVIM_CONFIG_DIR="${NVIM_CONFIG_DIR:-$HOME/.config/nvim}"
TMUX_CONFIG_ROOT="${TMUX_CONFIG_ROOT:-$HOME}"
USER_FONT_DIR="${USER_FONT_DIR:-$HOME/.local/share/fonts/$NERD_FONT_NAME}"
INSTALL_USER="${INSTALL_USER:-${SUDO_USER:-$(id -un)}}"
CONDA_DIR="${CONDA_DIR:-$HOME/miniconda3}"
CONDA_CHANNEL="${CONDA_CHANNEL:-https://repo.anaconda.com/pkgs/main}"
MAMBA_CHANNEL="${MAMBA_CHANNEL:-conda-forge}"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if command -v sudo >/dev/null 2>&1 && [ "$(id -u)" -ne 0 ]; then
    SUDO=sudo
else
    SUDO=
fi

is_wsl() {
    grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null ||
        grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease 2>/dev/null
}

set_wsl_conf_value() {
    local section="$1"
    local key="$2"
    local value="$3"
    local tmp

    tmp="$(mktemp)"
    if [ -f /etc/wsl.conf ]; then
        awk -v section="$section" -v key="$key" -v value="$value" '
            BEGIN {
                in_section = 0
                section_seen = 0
                key_set = 0
            }
            /^[[:space:]]*\[/ {
                if (in_section && !key_set) {
                    print key " = " value
                    key_set = 1
                }
                in_section = ($0 == "[" section "]")
                if (in_section) {
                    section_seen = 1
                    key_set = 0
                }
            }
            {
                if (in_section && $0 ~ "^[[:space:]]*" key "[[:space:]]*=") {
                    print key " = " value
                    key_set = 1
                    next
                }
                print
            }
            END {
                if (!section_seen) {
                    print ""
                    print "[" section "]"
                    print key " = " value
                } else if (in_section && !key_set) {
                    print key " = " value
                }
            }
        ' /etc/wsl.conf > "$tmp"
    else
        {
            printf '[%s]\n' "$section"
            printf '%s = %s\n' "$key" "$value"
        } > "$tmp"
    fi

    $SUDO install -m 0644 "$tmp" /etc/wsl.conf
    rm -f "$tmp"
}

configure_wsl() {
    local usbip_path
    local windows_profile
    local windows_workspace

    if ! is_wsl; then
        return
    fi

    echo "Configuring WSL integration..."
    apt_install_available linux-tools-virtual hwdata usbutils systemd systemd-sysv
    if [ -f /etc/wsl.conf ] && [ ! -e /etc/wsl.conf.bak ]; then
        $SUDO cp -a /etc/wsl.conf /etc/wsl.conf.bak
    fi

    if ! command -v usbip >/dev/null 2>&1; then
        usbip_path="$(find /usr/lib/linux-tools -path '*/usbip' -type f 2>/dev/null | sort -V | tail -n 1 || true)"
        if [ -n "$usbip_path" ]; then
            $SUDO update-alternatives --install /usr/local/bin/usbip usbip "$usbip_path" 20
        else
            echo "usbip command not found; install linux-tools-virtual manually if this Ubuntu release does not provide it."
        fi
    fi

    set_wsl_conf_value boot systemd true
    set_wsl_conf_value user default "$INSTALL_USER"
    set_wsl_conf_value automount enabled true
    set_wsl_conf_value automount root /mnt/
    set_wsl_conf_value automount options '"metadata,umask=022,fmask=011,case=dir"'
    set_wsl_conf_value automount mountFsTab true
    set_wsl_conf_value network generateHosts true
    set_wsl_conf_value network generateResolvConf true
    set_wsl_conf_value interop enabled true
    set_wsl_conf_value interop appendWindowsPath true
    set_wsl_conf_value time useWindowsTimezone true

    $SUDO systemctl enable ssh.service
    if [ "$(ps -p 1 -o comm=)" = systemd ]; then
        $SUDO systemctl restart ssh.service
    fi

    if command -v cmd.exe >/dev/null 2>&1 && command -v wslpath >/dev/null 2>&1; then
        windows_profile="$(cmd.exe /c '<nul set /p =%USERPROFILE%' 2>/dev/null | tr -d '\r')"
        windows_profile="$(wslpath -u "$windows_profile" 2>/dev/null || true)"
        if [ -n "$windows_profile" ] && [ -d "$windows_profile" ]; then
            windows_workspace="$windows_profile/workspace"
            mkdir -p "$windows_workspace"
            if [ ! -e "$HOME/windows-workspace" ] && [ ! -L "$HOME/windows-workspace" ]; then
                ln -s "$windows_workspace" "$HOME/windows-workspace"
            fi
            echo "Windows workspace: $HOME/windows-workspace"
        fi
    fi

    echo "WSL USB/IP Windows-side setup still needs PowerShell:"
    echo "  winget install --interactive --exact dorssel.usbipd-win"
    echo "  usbipd list"
    echo "  usbipd bind --busid <busid>"
    echo "  usbipd attach --wsl --busid <busid>"
    echo "Then restart WSL with: wsl --shutdown"
}

apt_install() {
    $SUDO env DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends "$@"
}

update_apt_lists() {
    if $SUDO apt-get update; then
        echo "Upgrading installed packages..."
        $SUDO env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
        return
    fi

    echo "apt-get update failed; continuing with the available package lists." >&2
}

apt_install_available() {
    local packages=()
    local package

    for package in "$@"; do
        if [ "$OFFLINE_MODE" = true ]; then
            packages+=("$package")
        elif apt-cache show "$package" >/dev/null 2>&1; then
            packages+=("$package")
        else
            echo "Package $package not found; skipping"
        fi
    done
    if [ "${#packages[@]}" -gt 0 ]; then
        apt_install "${packages[@]}"
    fi
}

ensure_en_us_utf8_locale() {
    if locale -a 2>/dev/null | grep -Eiq '^en_US\.utf-?8$'; then
        return
    fi

    echo "Generating en_US.UTF-8 locale..."
    if [ -f /etc/locale.gen ]; then
        $SUDO sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
    fi
    if command -v locale-gen >/dev/null 2>&1; then
        $SUDO locale-gen en_US.UTF-8
    fi
    if command -v update-locale >/dev/null 2>&1; then
        $SUDO update-locale LANG=en_US.UTF-8
    fi
}

find_source_file() {
    local name="$1"

    [ -d "$SRC_ROOT" ] || return 1
    find "$SRC_ROOT" -type f -name "$name" -print -quit
}

install_config_file() {
    local source="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"
    if { [ -e "$dest" ] || [ -L "$dest" ]; } &&
        ! cmp -s "$source" "$dest" &&
        { [ ! -e "$dest.bak" ] && [ ! -L "$dest.bak" ]; }; then
        cp -a -- "$dest" "$dest.bak"
        echo "Backed up $dest to $dest.bak"
    fi
    rsync -ah -- "$source" "$dest"
}

normalize_repo_url() {
    local repo="$1"

    repo="${repo#https://github.com/}"
    repo="${repo#http://github.com/}"
    repo="${repo#git@github.com:}"
    printf '%s\n' "${repo%.git}"
}

find_source_checkout() {
    local repo="$1"
    local git_dir
    local checkout
    local remote

    [ -d "$SRC_ROOT" ] || return 1
    while IFS= read -r -d '' git_dir; do
        checkout="${git_dir%/.git}"
        remote="$(git -C "$checkout" remote get-url origin 2>/dev/null || true)"
        if [ "$(normalize_repo_url "$remote")" = "$(normalize_repo_url "$repo")" ]; then
            printf '%s\n' "$checkout"
            return
        fi
    done < <(find "$SRC_ROOT" -type d -name .git -print0)
    return 1
}

add_user_to_group() {
    local user="$1"
    local group="$2"

    if [ -z "$user" ] || ! id "$user" >/dev/null 2>&1; then
        return
    fi
    if ! getent group "$group" >/dev/null 2>&1; then
        return
    fi
    if id -nG "$user" | tr ' ' '\n' | grep -qx "$group"; then
        return
    fi
    echo "Adding $user to $group group"
    $SUDO usermod -aG "$group" "$user"
}

ask_yes_no() {
    local prompt="$1"
    local default_answer="$2"
    local reply
    local suffix

    if [ "$default_answer" = yes ]; then
        suffix="[Y/n]"
    else
        suffix="[y/N]"
    fi

    read -r -p "$prompt $suffix " reply
    case "${reply:-$default_answer}" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

should_run() {
    local setting="$1"
    local prompt="$2"
    local default_answer="$3"

    case "$setting" in
        true) return 0 ;;
        false) return 1 ;;
        prompt)
            if [ -t 0 ]; then
                ask_yes_no "$prompt" "$default_answer"
            elif [ "$default_answer" = yes ]; then
                echo "$prompt [non-interactive: yes]"
                return 0
            else
                echo "$prompt [non-interactive: no]"
                return 1
            fi
            ;;
        *)
            echo "Unsupported toggle value: $setting" >&2
            echo "Use true, false, or prompt." >&2
            exit 1
            ;;
    esac
}

clone_or_update() {
    local repo="$1"
    local dest="$2"
    local ref="$3"
    local name
    local owner
    local repo_path
    local offline_source

    repo_path="${repo#*github.com/}"
    repo_path="${repo_path%.git}"
    owner="${repo_path%%/*}"
    name="${repo_path##*/}"
    name="${name%.git}"
    if [ "$owner" = "$name" ]; then
        offline_source="$SRC_ROOT/$name"
    else
        offline_source="$SRC_ROOT/$owner-$name"
    fi
    if [ "$OFFLINE_MODE" = true ]; then
        offline_source="$(find_source_checkout "$repo" || printf '%s' "$offline_source")"
    fi

    if [ -d "$dest/.git" ]; then
        if [ "$OFFLINE_MODE" = true ]; then
            echo "Using offline checkout: $dest"
            return
        fi
        if [ -n "$(git -C "$dest" status --porcelain)" ]; then
            echo "Preserving modified checkout: $dest"
            return
        fi
        git -C "$dest" remote set-url origin "$repo" ||
            git -C "$dest" remote add origin "$repo"
        git -C "$dest" fetch --depth 1 origin "$ref" 2>/dev/null ||
            git -C "$dest" fetch --depth 1 origin
        if [ "$(git -C "$dest" rev-parse HEAD)" = "$(git -C "$dest" rev-parse 'FETCH_HEAD^{commit}')" ]; then
            echo "Using existing checkout: $dest"
        else
            git -C "$dest" checkout --detach FETCH_HEAD
        fi
    elif [ -e "$dest" ]; then
        echo "Source path exists and is not a git checkout: $dest" >&2
        exit 1
    elif [ "$OFFLINE_MODE" = true ]; then
        if [ -d "$offline_source/.git" ]; then
            mkdir -p "$(dirname "$dest")"
            git clone "$offline_source" "$dest"
        else
            echo "Missing offline Git checkout: $dest" >&2
            echo "Also checked: $offline_source" >&2
            exit 1
        fi
    else
        if [ "$ref" = master ]; then
            git clone --depth 1 "$repo" "$dest"
        else
            git clone --depth 1 --single-branch --branch "$ref" "$repo" "$dest" ||
                git clone --depth 1 "$repo" "$dest"
        fi
    fi
}

install_fzf() {
    local artifact
    local artifact_arch
    local download_url
    local tmp_dir

    case "$(uname -m)" in
        x86_64) artifact_arch=amd64 ;;
        aarch64 | arm64) artifact_arch=arm64 ;;
        *)
            echo "fzf is not supported on architecture $(uname -m)" >&2
            exit 1
            ;;
    esac

    if [ -x "$HOME/.local/bin/fzf" ]; then
        echo "fzf artifact already installed"
        return
    fi

    echo "Installing fzf release artifact..."
    artifact="$(find_source_file "fzf-*-linux_${artifact_arch}.tar.gz" || true)"
    tmp_dir="$(mktemp -d)"
    if [ -z "$artifact" ]; then
        if [ "$OFFLINE_MODE" = true ]; then
            echo "Offline fzf installation requires fzf-*-linux_${artifact_arch}.tar.gz in sources/" >&2
            exit 1
        fi
        download_url="$(curl -fsSL https://api.github.com/repos/junegunn/fzf/releases/latest |
            python3 -c 'import json, sys; print(next(asset["browser_download_url"] for asset in json.load(sys.stdin)["assets"] if asset["name"].endswith("linux_" + sys.argv[1] + ".tar.gz")))' "$artifact_arch")"
        artifact="$tmp_dir/fzf.tar.gz"
        curl -fL "$download_url" -o "$artifact"
    fi

    tar -xzf "$artifact" -C "$tmp_dir"
    mkdir -p "$HOME/.local/bin"
    install -m 0755 "$tmp_dir/fzf" "$HOME/.local/bin/fzf"
    rm -rf "$tmp_dir"
}

install_nvm() {
    echo "Installing nvm $NVM_REF..."
    clone_or_update https://github.com/nvm-sh/nvm.git "$NVM_SRC_DIR" "$NVM_REF"
    mkdir -p "$NVM_DIR"
    rsync -ah --exclude .git "$NVM_SRC_DIR/" "$NVM_DIR/"

    export NVM_DIR
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
    if [ "$OFFLINE_MODE" = true ]; then
        if ! nvm version default >/dev/null 2>&1; then
            echo "Offline nvm installation requires a default Node version in $NVM_DIR." >&2
            exit 1
        fi
    else
        nvm install --lts
        nvm alias default 'lts/*'
    fi
    nvm use --silent default
}

install_zsh_plugins() {
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    echo "Installing zsh plugins..."
    clone_or_update https://github.com/esc/conda-zsh-completion.git \
        "$CONDA_ZSH_COMPLETION_SRC_DIR" master
    clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_SYNTAX_HIGHLIGHTING_SRC_DIR" master

    mkdir -p \
        "$custom_dir/plugins/conda-zsh-completion" \
        "$custom_dir/plugins/zsh-syntax-highlighting"
    rsync -ah --exclude .git \
        "$CONDA_ZSH_COMPLETION_SRC_DIR/" \
        "$custom_dir/plugins/conda-zsh-completion/"
    rsync -ah --exclude .git \
        "$ZSH_SYNTAX_HIGHLIGHTING_SRC_DIR/" \
        "$custom_dir/plugins/zsh-syntax-highlighting/"
}

install_zuban() {
    local wheel
    local pip_args=(--user --upgrade)

    if command -v zuban >/dev/null 2>&1; then
        echo "Zuban already installed"
        return
    fi
    if python3 -m pip install --help 2>/dev/null | grep -q -- '--break-system-packages'; then
        pip_args+=(--break-system-packages)
    fi
    if [ "$OFFLINE_MODE" = true ]; then
        wheel="$(find_source_file 'zuban-*.whl' || true)"
        if [ -z "$wheel" ]; then
            echo "Offline Zuban install requires a zuban-*.whl file in sources/" >&2
            exit 1
        fi
        python3 -m pip install "${pip_args[@]}" --no-index "$wheel"
    else
        python3 -m pip install "${pip_args[@]}" zuban
    fi
}

install_json_language_server() {
    if command -v vscode-json-language-server >/dev/null 2>&1; then
        echo "JSON language server already installed"
        return
    fi
    if ! command -v npm >/dev/null 2>&1; then
        echo "npm is required to install the JSON language server" >&2
        exit 1
    fi
    if [ "$OFFLINE_MODE" = true ]; then
        npm install --global --offline vscode-langservers-extracted
    else
        npm install --global vscode-langservers-extracted
    fi
}

verify_vim_features() {
    local feature
    local function_name
    local vim_bin="$1"
    local version

    version="$("$vim_bin" --version)"
    for feature in \
        autocmd channel cscope insert_expand job lambda lua menu multi_byte \
        perl popupwin python3 quickfix ruby terminal termguicolors textprop timers; do
        if ! grep -Eq "(^|[[:space:]])[+]$feature([[:space:]]|$)" <<<"$version"; then
            echo "Vim is missing +$feature, required by the configured plugins" >&2
            exit 1
        fi
    done
    for function_name in complete_info json_decode popup_create; do
        if ! "$vim_bin" --clean -Nu NONE -n -es \
            "+if !exists('*$function_name') | cquit | endif" +qa; then
            echo "Vim is missing $function_name(), required by the configured plugins" >&2
            exit 1
        fi
    done
    if ! "$vim_bin" --clean -Nu NONE -n -es \
        '+if !exists("+completepopup") | cquit | endif' +qa; then
        echo "Vim is missing the completepopup option" >&2
        exit 1
    fi
}

install_vim_plugins_from_config() {
    local line
    local repo
    local name
    local ref
    local as_name

    mkdir -p "$VIM_CONFIG_DIR/plugged"
    while IFS= read -r line; do
        repo="${line#Plug \'}"
        repo="${repo%%\'*}"
        name="${repo##*/}"
        name="${name%.git}"
        as_name="$name"
        ref="master"
        if [[ "$line" == *"'as': '"* ]]; then
            as_name="${line#*"'as': '"}"
            as_name="${as_name%%\'*}"
        fi
        if [[ "$line" == *"'tag': '"* ]]; then
            ref="${line#*"'tag': '"}"
            ref="${ref%%\'*}"
        fi
        clone_or_update "https://github.com/$repo.git" "$VIM_CONFIG_DIR/plugged/$as_name" "$ref"
    done < <(grep "^Plug '" "$REPO_DIR/.vimrc")
}

install_tmux_plugins_from_config() {
    local line
    local repo
    local name

    mkdir -p "$HOME/.tmux/plugins"
    while IFS= read -r line; do
        repo="${line#set -g @plugin \'}"
        repo="${repo%%\'*}"
        name="${repo##*/}"
        name="${name%.git}"
        clone_or_update "https://github.com/$repo.git" "$HOME/.tmux/plugins/$name" master
    done < <(grep "^set -g @plugin '" "$REPO_DIR/.tmux.conf")
}

install_tmux_theme_plugins() {
    local repo
    local name

    mkdir -p "$HOME/.tmux/theme-plugins"
    while IFS= read -r repo; do
        [ -n "$repo" ] || continue
        name="${repo//\//-}"
        name="${name%.git}"
        clone_or_update "https://github.com/$repo.git" "$HOME/.tmux/theme-plugins/$name" master
    done < <("$REPO_DIR/bin/select-tmux-theme" --repos)
}

install_nerd_font() {
    local font_source

    if [ "$NERD_FONT_REFRESH" != true ] &&
        command -v fc-match >/dev/null 2>&1 &&
        fc-match "$NERD_FONT_FAMILY:charset=e0b0" | grep -qi "$NERD_FONT_NAME"; then
        echo "$NERD_FONT_FAMILY already installed"
        return
    fi

    echo "Installing $NERD_FONT_FAMILY..."
    if [ -d "$NERD_FONT_SRC_DIR/.git" ]; then
        if [ "$OFFLINE_MODE" = true ]; then
            echo "Using offline checkout: $NERD_FONT_SRC_DIR"
        elif [ -z "$(git -C "$NERD_FONT_SRC_DIR" status --porcelain)" ]; then
            git -C "$NERD_FONT_SRC_DIR" fetch --depth 1 origin master
            git -C "$NERD_FONT_SRC_DIR" checkout --detach FETCH_HEAD
        else
            echo "Preserving modified checkout: $NERD_FONT_SRC_DIR"
        fi
    elif [ -e "$NERD_FONT_SRC_DIR" ]; then
        echo "Source path exists and is not a git checkout: $NERD_FONT_SRC_DIR" >&2
        exit 1
    elif [ "$OFFLINE_MODE" = true ]; then
        echo "Missing offline Git checkout: $NERD_FONT_SRC_DIR" >&2
        exit 1
    else
        git clone --depth 1 --filter=blob:none --no-checkout \
            https://github.com/ryanoasis/nerd-fonts.git "$NERD_FONT_SRC_DIR"
    fi

    git -C "$NERD_FONT_SRC_DIR" sparse-checkout init --cone
    git -C "$NERD_FONT_SRC_DIR" sparse-checkout set "patched-fonts/$NERD_FONT_NAME"
    git -C "$NERD_FONT_SRC_DIR" checkout
    font_source="$NERD_FONT_SRC_DIR/patched-fonts/$NERD_FONT_NAME"
    if ! find "$font_source" -type f -iname '*NerdFontMono*.ttf' -print -quit |
        grep -q .; then
        echo "No $NERD_FONT_FAMILY files found in $font_source" >&2
        exit 1
    fi

    mkdir -p "$USER_FONT_DIR"
    find "$font_source" -type f -iname '*NerdFontMono*.ttf' \
        -exec cp -f -t "$USER_FONT_DIR" {} +

    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$USER_FONT_DIR"
    fi
}

configure_terminal_font() {
    local font_spec="$NERD_FONT_FAMILY $NERD_FONT_SIZE"
    local default_profile
    local profile_path

    if ! command -v gsettings >/dev/null 2>&1; then
        echo "gsettings not found; skipping terminal font configuration"
        return
    fi

    if gsettings list-schemas | grep -qx 'org.gnome.desktop.interface'; then
        echo "Setting GNOME monospace font to $font_spec"
        gsettings set org.gnome.desktop.interface monospace-font-name "$font_spec" || true
    fi

    if ! gsettings list-schemas | grep -qx 'org.gnome.Terminal.ProfilesList'; then
        echo "GNOME Terminal schema not found; skipping terminal profile font"
        return
    fi

    default_profile="$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")"
    if [ -z "$default_profile" ]; then
        echo "GNOME Terminal default profile not found; skipping terminal profile font"
        return
    fi

    profile_path="/org/gnome/terminal/legacy/profiles:/:$default_profile/"
    echo "Setting GNOME Terminal font to $font_spec"
    gsettings set "org.gnome.Terminal.Legacy.Profile:$profile_path" use-system-font false || true
    gsettings set "org.gnome.Terminal.Legacy.Profile:$profile_path" font "$font_spec" || true
}

install_conda_shortcuts() {
    local package_command=conda
    local rc
    local marker_start="# >>> configs conda shortcuts >>>"
    local marker_end="# <<< configs conda shortcuts <<<"

    if [ -x "$CONDA_DIR/bin/mamba" ]; then
        package_command=mamba
    fi

    for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
        touch "$rc"
        sed -i "/^$marker_start$/,/^$marker_end$/d" "$rc"
        cat >>"$rc" <<EOF
$marker_start
if [ -r "$CONDA_DIR/etc/profile.d/conda.sh" ]; then
    . "$CONDA_DIR/etc/profile.d/conda.sh"
fi
alias cenv='conda env list'
alias cact='conda activate'
alias cdeact='conda deactivate'
alias cnew='$package_command create -n'
alias cinst='$package_command install'
alias cup='$package_command update'
alias cclean='conda clean -a'
$marker_end
EOF
    done
}

install_conda() {
    local archive
    local filename
    local repodata
    local subdir
    local tmp_dir

    if [ -x "$CONDA_DIR/bin/conda" ]; then
        echo "Conda already installed at $CONDA_DIR"
    else
        case "$(uname -m)" in
            x86_64) subdir=linux-64 ;;
            aarch64 | arm64) subdir=linux-aarch64 ;;
            *)
                echo "Conda is not supported on architecture $(uname -m)" >&2
                exit 1
                ;;
        esac

        archive="$(find_source_file 'conda-standalone-*_single_*.conda' || true)"
        if [ -z "$archive" ]; then
            archive="$(find_source_file 'conda-standalone-*_single_*.tar.bz2' || true)"
        fi
        tmp_dir="$(mktemp -d)"
        if [ -z "$archive" ]; then
            if [ "$OFFLINE_MODE" = true ]; then
                echo "Missing conda-standalone archive under $SRC_ROOT" >&2
                exit 1
            fi

            repodata="$tmp_dir/current_repodata.json"
            curl -fL "$CONDA_CHANNEL/$subdir/current_repodata.json" -o "$repodata"
            filename="$(python3 - "$repodata" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as source:
    repodata = json.load(source)

candidates = [
    (metadata.get("timestamp", 0), filename)
    for packages in (repodata.get("packages", {}), repodata.get("packages.conda", {}))
    for filename, metadata in packages.items()
    if metadata.get("name") == "conda-standalone"
    and "_single_" in metadata.get("build", "")
]
if not candidates:
    raise SystemExit("conda-standalone was not found in current_repodata.json")
print(max(candidates)[1])
PY
)"
            archive="$tmp_dir/$filename"
            curl -fL "$CONDA_CHANNEL/$subdir/$filename" -o "$archive"
        fi

        echo "Creating Conda environment at $CONDA_DIR..."
        case "$archive" in
            *.conda)
                unzip -q "$archive" 'pkg-*.tar.zst' -d "$tmp_dir"
                unzstd -c "$tmp_dir"/pkg-*.tar.zst | tar -xf - -C "$tmp_dir"
                ;;
            *.tar.bz2)
                tar -xjf "$archive" -C "$tmp_dir"
                ;;
        esac
        "$tmp_dir/standalone_conda/conda.exe" create -y \
            --prefix "$CONDA_DIR" \
            --override-channels \
            --channel "$CONDA_CHANNEL" \
            conda python pip
        rm -rf "$tmp_dir"
    fi

    if [ "$INSTALL_MAMBA" = true ]; then
        if [ -x "$CONDA_DIR/bin/mamba" ]; then
            echo "Mamba already installed at $CONDA_DIR"
        elif [ "$OFFLINE_MODE" = true ]; then
            echo "Mamba is missing and cannot be installed from conda-forge in offline mode." >&2
            echo "Use an installer that includes mamba, or install once online before going offline." >&2
            exit 1
        else
            echo "Installing mamba into the base conda environment..."
            "$CONDA_DIR/bin/conda" install -n base -c "$MAMBA_CHANNEL" -y mamba
        fi
    fi

    install_conda_shortcuts
    echo "Conda shortcuts added to .zshrc and .bashrc"
}

maybe_install_conda() {
    case "$INSTALL_CONDA" in
        true)
            install_conda
            ;;
        false)
            echo "Skipping conda install"
            ;;
        prompt)
            if [ ! -t 0 ]; then
                echo "Skipping conda prompt in non-interactive shell"
                return
            fi
            if [ -x "$CONDA_DIR/bin/conda" ]; then
                if ask_yes_no "Conda already exists at $CONDA_DIR. Update mamba and shell shortcuts?" yes; then
                    install_conda
                fi
            elif ask_yes_no "Install Conda, mamba, and shell shortcuts at $CONDA_DIR?" no; then
                install_conda
            else
                echo "Skipping conda install"
            fi
            ;;
        *)
            echo "Unsupported INSTALL_CONDA value: $INSTALL_CONDA" >&2
            echo "Use true, false, or prompt." >&2
            exit 1
            ;;
    esac
}

if [ "$OFFLINE_MODE" = true ]; then
    echo "Offline mode enabled; skipping apt-get update"
else
    echo "Updating package lists..."
    update_apt_lists
fi

echo "Installing common utilities..."
apt_install \
    ca-certificates \
    curl \
    git \
    fd-find \
    fzf \
    ripgrep \
    rsync \
    openssh-server \
    net-tools \
    python3 \
    unzip \
    fontconfig \
    ncurses-term \
    fonts-powerline \
    build-essential \
    bzip2 \
    chrpath \
    pkg-config \
    cmake \
    cpio \
    debianutils \
    diffstat \
    file \
    gawk \
    iputils-arping \
    iputils-ping \
    libacl1 \
    lz4 \
    locales \
    python3-dev \
    python3-git \
    python3-jinja2 \
    python3-pexpect \
    python3-pip \
    python3-subunit \
    python3-venv \
    universal-ctags \
    patch \
    socat \
    texinfo \
    wget \
    xz-utils \
    zstd

if should_run "$INSTALL_COMPLETION_TOOLS" "Install completion and language-server tools?" yes; then
    apt_install_available clangd clang-format clang-tidy
    install_zuban
fi

ensure_en_us_utf8_locale

configure_wsl

if should_run "$INSTALL_EXTRA_TOOLS" "Install extra command-line tools?" yes; then
    echo "Installing extra command-line tools..."
    apt_install_available \
        bat \
        htop \
        jq \
        lsof \
        minicom \
        picocom \
        ranger \
        shellcheck \
        silversearcher-ag \
        sl \
        tree
fi

if should_run "$INSTALL_DOCKER" "Install Docker and add $INSTALL_USER to the docker group?" yes; then
    if is_wsl; then
        echo "WSL detected: Docker Desktop integration is usually preferable to installing docker.io inside WSL."
        echo "Continuing because INSTALL_DOCKER is enabled."
    fi
    echo "Installing Docker..."
    apt_install_available docker.io docker-compose-v2
    add_user_to_group "$INSTALL_USER" docker
    if command -v systemctl >/dev/null 2>&1; then
        $SUDO systemctl enable --now docker >/dev/null 2>&1 || true
    else
        $SUDO service docker start >/dev/null 2>&1 || true
    fi
fi

add_user_to_group "$INSTALL_USER" dialout
add_user_to_group "$INSTALL_USER" plugdev
if is_wsl; then
    echo "WSL detected: use usbipd attach from Windows before accessing USB serial devices here."
fi

if should_run "$INSTALL_NERD_FONT" "Install the configured Nerd Font?" yes; then
    install_nerd_font
fi

if should_run "$CONFIGURE_TERMINAL_FONT" "Set GNOME Terminal to $NERD_FONT_FAMILY $NERD_FONT_SIZE?" yes; then
    if is_wsl; then
        echo "WSL detected; skipping GNOME Terminal font configuration. Set the font in Windows Terminal instead."
    else
        configure_terminal_font
    fi
fi

if should_run "$INSTALL_ZSH" "Install zsh and zsh helper packages?" yes; then
    apt_install zsh cowsay fortune-mod fortunes
fi

if [ "$VIM_FROM_SOURCE" = true ]; then
    lua_version=
    for candidate in 5.4 5.3; do
        if apt-cache show "lua$candidate" >/dev/null 2>&1 &&
            apt-cache show "liblua$candidate-dev" >/dev/null 2>&1; then
            lua_version="$candidate"
            break
        fi
    done
    if [ -z "$lua_version" ]; then
        echo "No supported Lua interpreter and development package found." >&2
        exit 1
    fi

    vim_head_before="$(git -C "$VIM_SRC_DIR" rev-parse HEAD 2>/dev/null || true)"
    echo "Installing Vim build dependencies..."
    apt_install \
        autoconf \
        libncurses-dev \
        python3-dev \
        perl \
        libperl-dev \
        ruby \
        ruby-dev \
        libruby \
        "liblua$lua_version-dev" \
        "lua$lua_version" \
        libacl1-dev \
        libgpm-dev

    lua_command="$(command -v lua || command -v "lua$lua_version" || true)"
    if [ -z "$lua_command" ]; then
        echo "Lua $lua_version was installed without a usable interpreter." >&2
        exit 1
    fi
    perl_command="$(command -v perl || true)"
    ruby_command="$(command -v ruby || true)"
    if [ -z "$perl_command" ] || [ -z "$ruby_command" ]; then
        echo "Perl and Ruby interpreters are required to build Vim." >&2
        exit 1
    fi

    echo "Building Vim from source..."
    mkdir -p "$SRC_ROOT"
    clone_or_update https://github.com/vim/vim.git "$VIM_SRC_DIR" "$VIM_REF"
    vim_head_after="$(git -C "$VIM_SRC_DIR" rev-parse HEAD)"
    vim_configure_state="$SRC_ROOT/.vim-configure"
    vim_configure_options="$(
        printf '%s\n' \
            "--enable-fail-if-missing" \
            "--with-features=huge" \
            "--enable-multibyte" \
            "--with-python3-command=$(command -v python3)" \
            "--with-lua-command=$lua_command" \
            "--with-perl-command=$perl_command" \
            "--with-ruby-command=$ruby_command" \
            "--enable-rubyinterp=yes" \
            "--enable-python3interp=yes" \
            "--enable-perlinterp=yes" \
            "--enable-luainterp=yes" \
            "--with-lua-prefix=/usr" \
            "--enable-cscope" \
            "--disable-gui" \
            "--prefix=$VIM_PREFIX"
    )"
    vim_reconfigure=false
    if [ ! -f "$VIM_SRC_DIR/src/auto/config.mk" ] ||
        [ "$vim_head_before" != "$vim_head_after" ] ||
        [ ! -f "$vim_configure_state" ] ||
        [ "$(cat "$vim_configure_state")" != "$vim_configure_options" ]; then
        vim_reconfigure=true
    fi
    (
        cd "$VIM_SRC_DIR"
        if [ "$vim_reconfigure" = true ]; then
            rm -f src/auto/config.cache
            vi_cv_path_plain_lua="$lua_command" \
                vi_cv_path_perl="$perl_command" \
                ./configure \
                --enable-fail-if-missing \
                --with-features=huge \
                --enable-multibyte \
                --with-python3-command="$(command -v python3)" \
                --with-ruby-command="$ruby_command" \
                --enable-rubyinterp=yes \
                --enable-python3interp=yes \
                --enable-perlinterp=yes \
                --enable-luainterp=yes \
                --with-lua-prefix=/usr \
                --enable-cscope \
                --disable-gui \
                --prefix="$VIM_PREFIX"
            printf '%s\n' "$vim_configure_options" > "$vim_configure_state"
        else
            echo "Reusing existing Vim configuration"
        fi
        make -j"$(nproc)"
        $SUDO make install
    )
    vim_bin="$VIM_PREFIX/bin/vim"
    hash -r
    if [ ! -x "$vim_bin" ]; then
        echo "Vim was not installed at $vim_bin" >&2
        exit 1
    fi
else
    echo "Installing Vim with language support from apt..."
    apt_install vim-nox
    vim_bin="$(command -v vim)"
fi

verify_vim_features "$vim_bin"

if [ "$TMUX_FROM_SOURCE" = true ]; then
    tmux_head_before="$(git -C "$TMUX_SRC_DIR" rev-parse HEAD 2>/dev/null || true)"
    echo "Installing tmux build dependencies..."
    apt_install \
        autoconf \
        automake \
        bison \
        flex \
        libevent-dev \
        libncurses-dev

    echo "Building tmux from source..."
    mkdir -p "$SRC_ROOT"
    clone_or_update https://github.com/tmux/tmux.git "$TMUX_SRC_DIR" "$TMUX_REF"
    tmux_head_after="$(git -C "$TMUX_SRC_DIR" rev-parse HEAD)"
    tmux_configure_state="$SRC_ROOT/.tmux-configure"
    tmux_configure_options="--prefix=$TMUX_PREFIX"
    tmux_reconfigure=false
    if [ ! -f "$TMUX_SRC_DIR/Makefile" ] ||
        [ "$tmux_head_before" != "$tmux_head_after" ] ||
        [ ! -f "$tmux_configure_state" ] ||
        [ "$(cat "$tmux_configure_state")" != "$tmux_configure_options" ]; then
        tmux_reconfigure=true
    fi
    (
        cd "$TMUX_SRC_DIR"
        if [ "$tmux_reconfigure" = true ]; then
            rm -f config.cache
            sh autogen.sh
            ./configure --prefix="$TMUX_PREFIX"
            printf '%s\n' "$tmux_configure_options" > "$tmux_configure_state"
        else
            echo "Reusing existing tmux configuration"
        fi
        make -j"$(nproc)"
        $SUDO make install
    )
else
    echo "Installing tmux from apt..."
    apt_install tmux
fi

install_fzf

echo "Copying configuration files..."
install_config_file "$REPO_DIR/.bashrc" "$HOME/.bashrc"
install_config_file "$REPO_DIR/.vimrc" "$HOME/.vimrc"
install_config_file "$REPO_DIR/.zshrc" "$HOME/.zshrc"
install_config_file "$REPO_DIR/.tmux.conf" "$TMUX_CONFIG_ROOT/.tmux.conf"
mkdir -p "$HOME/.local/bin"
rsync -ah "$REPO_DIR/bin/select-config" "$HOME/.local/bin/"
rsync -ah "$REPO_DIR/bin/configure-vim-project" "$HOME/.local/bin/"
rsync -ah "$REPO_DIR/bin/picker_ui.py" "$HOME/.local/bin/"
mkdir -p "$HOME/.tmux/bin" "$HOME/.tmux/themes"
rsync -ah "$REPO_DIR/bin/select-tmux-theme" "$HOME/.tmux/bin/"
rsync -ah "$REPO_DIR/bin/picker_ui.py" "$HOME/.tmux/bin/"
rsync -ah "$REPO_DIR/themes/tmux/"*.conf "$HOME/.tmux/themes/"
clone_or_update https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm" master
install_tmux_plugins_from_config
install_tmux_theme_plugins

mkdir -p "$VIM_CONFIG_DIR/colors" "$VIM_CONFIG_DIR/bin" "$NVIM_CONFIG_DIR/colors"
mkdir -p "$VIM_CONFIG_DIR/autoload"
rsync -ah "$REPO_DIR/autoload/configs_project.vim" "$VIM_CONFIG_DIR/autoload/"
rsync -ah "$REPO_DIR/themes/"*.vim "$VIM_CONFIG_DIR/colors/"
install_config_file "$REPO_DIR/.vimrc" "$NVIM_CONFIG_DIR/init.vim"
rsync -ah "$REPO_DIR/themes/"*.vim "$NVIM_CONFIG_DIR/colors/"
rsync -ah "$REPO_DIR/bin/select-vim-theme" "$VIM_CONFIG_DIR/bin/"
rsync -ah "$REPO_DIR/bin/picker_ui.py" "$VIM_CONFIG_DIR/bin/"

echo "Installing vim-plug..."
mkdir -p "$VIM_CONFIG_DIR/autoload"
clone_or_update https://github.com/junegunn/vim-plug.git "$VIM_PLUG_SRC_DIR" master
rsync -ah "$VIM_PLUG_SRC_DIR/plug.vim" "$VIM_CONFIG_DIR/autoload/plug.vim"

if should_run "$INSTALL_VIM_PLUGINS" "Install Vim plugins with vim-plug?" yes; then
    install_vim_plugins_from_config
    echo "Installing Vim plugins..."
    "$vim_bin" -Nu "$HOME/.vimrc" -n -es +'PlugInstall --sync' +qa
    if command -v nvim >/dev/null 2>&1; then
        nvim --headless -u "$NVIM_CONFIG_DIR/init.vim" +'PlugInstall --sync' +qa
    fi
fi

if command -v zsh >/dev/null 2>&1 && should_run "$INSTALL_OH_MY_ZSH" "Install or update oh-my-zsh?" yes; then
    echo "Installing oh-my-zsh..."
    clone_or_update https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" master
    install_zsh_plugins
fi

if should_run "$INSTALL_NVM" "Install nvm and the latest Node LTS?" yes; then
    install_nvm
fi

if should_run "$INSTALL_COMPLETION_TOOLS" "Install completion and language-server tools?" yes; then
    install_json_language_server
fi

if command -v zsh >/dev/null 2>&1 && should_run "$CHANGE_DEFAULT_SHELL" "Make zsh the default login shell?" yes; then
    if [ "$(basename "${SHELL:-}")" != zsh ]; then
        chsh -s "$(command -v zsh)" || true
    fi
fi

echo "Configuring Git..."
git config --global diff.tool vimdiff

echo "Checking conda setup..."
maybe_install_conda

echo "Verifying installs..."
vim --version | head -n 1
tmux -V

echo "Installation complete!"
