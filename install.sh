#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VIM_FROM_SOURCE="${VIM_FROM_SOURCE:-true}"
TMUX_FROM_SOURCE="${TMUX_FROM_SOURCE:-true}"
INSTALL_VIM_PLUGINS="${INSTALL_VIM_PLUGINS:-true}"
INSTALL_ZSH="${INSTALL_ZSH:-true}"
INSTALL_OH_MY_ZSH="${INSTALL_OH_MY_ZSH:-true}"
CHANGE_DEFAULT_SHELL="${CHANGE_DEFAULT_SHELL:-true}"
INSTALL_EXTRA_TOOLS="${INSTALL_EXTRA_TOOLS:-true}"
INSTALL_DOCKER="${INSTALL_DOCKER:-prompt}"
INSTALL_CONDA="${INSTALL_CONDA:-prompt}"
INSTALL_MAMBA="${INSTALL_MAMBA:-true}"
INSTALL_NERD_FONT="${INSTALL_NERD_FONT:-true}"
NERD_FONT_REFRESH="${NERD_FONT_REFRESH:-false}"
CONFIGURE_TERMINAL_FONT="${CONFIGURE_TERMINAL_FONT:-true}"
OFFLINE_MODE="${OFFLINE_MODE:-false}"

VIM_REF="${VIM_REF:-v9.2.0782}"
TMUX_REF="${TMUX_REF:-3.5a}"
NERD_FONT_NAME="${NERD_FONT_NAME:-JetBrainsMono}"
NERD_FONT_FAMILY="${NERD_FONT_FAMILY:-JetBrainsMono Nerd Font Mono}"
NERD_FONT_SIZE="${NERD_FONT_SIZE:-14}"
NERD_FONT_URL="${NERD_FONT_URL:-https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${NERD_FONT_NAME}.zip}"
SRC_ROOT="${SRC_ROOT:-$REPO_DIR/sources}"
VIM_SRC_DIR="${VIM_SRC_DIR:-$SRC_ROOT/vim}"
TMUX_SRC_DIR="${TMUX_SRC_DIR:-$SRC_ROOT/tmux}"
VIM_CONFIG_DIR="${VIM_CONFIG_DIR:-$HOME/.vim}"
NVIM_CONFIG_DIR="${NVIM_CONFIG_DIR:-$HOME/.config/nvim}"
TMUX_CONFIG_ROOT="${TMUX_CONFIG_ROOT:-$HOME}"
USER_FONT_DIR="${USER_FONT_DIR:-$HOME/.local/share/fonts/$NERD_FONT_NAME}"
INSTALL_USER="${INSTALL_USER:-${SUDO_USER:-$(id -un)}}"
CONDA_DIR="${CONDA_DIR:-$HOME/miniforge3}"
CONDA_INSTALLER_URL="${CONDA_INSTALLER_URL:-https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh}"
NERD_FONT_ARCHIVE="${NERD_FONT_ARCHIVE:-$SRC_ROOT/${NERD_FONT_NAME}.zip}"
CONDA_INSTALLER="${CONDA_INSTALLER:-$SRC_ROOT/Miniforge3-Linux-$(uname -m).sh}"

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

    if ! is_wsl; then
        return
    fi

    echo "Configuring WSL integration..."
    apt_install_available linux-tools-virtual hwdata usbutils

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

    echo "WSL USB/IP Windows-side setup still needs PowerShell:"
    echo "  winget install --interactive --exact dorssel.usbipd-win"
    echo "  usbipd list"
    echo "  usbipd bind --busid <busid>"
    echo "  usbipd attach --wsl --busid <busid>"
    echo "Then restart WSL with: wsl --shutdown"
}

apt_install() {
    DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y --no-install-recommends "$@"
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

fetch_file() {
    local url="$1"
    local source="$2"
    local dest="$3"
    local discovered

    if [ ! -f "$source" ]; then
        discovered="$(find_source_file "$(basename "$source")" || true)"
        if [ -n "$discovered" ]; then
            source="$discovered"
        fi
    fi
    if [ ! -f "$source" ]; then
        if [ "$OFFLINE_MODE" = true ]; then
            if [ -f "$dest" ]; then
                echo "Using offline file: $dest"
                return
            fi
            echo "Missing offline file: $source" >&2
            exit 1
        fi
        mkdir -p "$(dirname "$source")"
        curl -fL "$url" -o "$source"
    fi
    cp "$source" "$dest"
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
        git -C "$dest" fetch --depth 1 origin "$ref" ||
            git -C "$dest" fetch --depth 1 origin
        git -C "$dest" checkout --detach FETCH_HEAD
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
        git clone --depth 1 --single-branch --branch "$ref" "$repo" "$dest" ||
            git clone --depth 1 "$repo" "$dest"
    fi
}

install_fzf() {
    local fzf_binary

    echo "Installing fzf..."
    clone_or_update https://github.com/junegunn/fzf.git "$HOME/.fzf" master
    if [ "$OFFLINE_MODE" = true ] && [ ! -x "$HOME/.fzf/bin/fzf" ]; then
        fzf_binary="$(find_source_file fzf || true)"
        if [ -n "$fzf_binary" ]; then
            mkdir -p "$HOME/.fzf/bin"
            cp "$fzf_binary" "$HOME/.fzf/bin/fzf"
            chmod 755 "$HOME/.fzf/bin/fzf"
        else
            echo "Offline fzf requires an fzf executable in sources/" >&2
            exit 1
        fi
    fi
    "$HOME/.fzf/install" --all --no-update-rc
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

install_nerd_font() {
    local tmp_zip

    if [ "$NERD_FONT_REFRESH" != true ] &&
        command -v fc-match >/dev/null 2>&1 &&
        fc-match "$NERD_FONT_FAMILY:charset=e0b0" | grep -qi "$NERD_FONT_NAME"; then
        echo "$NERD_FONT_FAMILY already installed"
        return
    fi

    echo "Installing $NERD_FONT_FAMILY..."
    mkdir -p "$USER_FONT_DIR"
    tmp_zip="$(mktemp)"
    fetch_file "$NERD_FONT_URL" "$NERD_FONT_ARCHIVE" "$tmp_zip"
    unzip -qo "$tmp_zip" -d "$USER_FONT_DIR"
    rm -f "$tmp_zip"

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
    local rc
    local marker_start="# >>> configs conda shortcuts >>>"
    local marker_end="# <<< configs conda shortcuts <<<"

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
alias cnew='mamba create -n'
alias cinst='mamba install'
alias cup='mamba update'
alias cclean='conda clean -a'
$marker_end
EOF
    done
}

install_conda() {
    local tmp_installer

    if [ -x "$CONDA_DIR/bin/conda" ]; then
        echo "Conda already installed at $CONDA_DIR"
    else
        echo "Installing Miniforge to $CONDA_DIR..."
        tmp_installer="$(mktemp)"
        fetch_file "$CONDA_INSTALLER_URL" "$CONDA_INSTALLER" "$tmp_installer"
        bash "$tmp_installer" -b -p "$CONDA_DIR"
        rm -f "$tmp_installer"
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
            "$CONDA_DIR/bin/conda" install -n base -c conda-forge -y mamba
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
            elif ask_yes_no "Install Miniforge, mamba, and shell shortcuts at $CONDA_DIR?" no; then
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
    $SUDO apt-get update
fi

echo "Installing common utilities..."
apt_install \
    ca-certificates \
    curl \
    git \
    fd-find \
    ripgrep \
    rsync \
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
    patch \
    socat \
    texinfo \
    wget \
    xz-utils \
    zstd

ensure_en_us_utf8_locale

configure_wsl

if should_run "$INSTALL_EXTRA_TOOLS" "Install extra command-line tools?" yes; then
    echo "Installing extra command-line tools..."
    apt_install_available \
        htop \
        jq \
        lsof \
        minicom \
        net-tools \
        picocom \
        ranger \
        shellcheck \
        silversearcher-ag \
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
    apt_install zsh universal-ctags cowsay fortune-mod
fi

if [ "$VIM_FROM_SOURCE" = true ]; then
    echo "Installing Vim build dependencies..."
    apt_install \
        autoconf \
        libncurses-dev \
        python3-dev \
        ruby-dev \
        liblua5.3-dev \
        lua5.3 \
        libperl-dev \
        libacl1-dev \
        libgpm-dev

    echo "Building Vim from source..."
    mkdir -p "$SRC_ROOT"
    clone_or_update https://github.com/vim/vim.git "$VIM_SRC_DIR" "$VIM_REF"
    make -C "$VIM_SRC_DIR" distclean >/dev/null 2>&1 || true
    (
        cd "$VIM_SRC_DIR"
        ./configure \
            --with-features=huge \
            --enable-multibyte \
            --with-python3-command="$(command -v python3)" \
            --with-python3-config-dir="$(python3-config --configdir)" \
            --enable-rubyinterp=yes \
            --enable-python3interp=yes \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --with-lua-prefix=/usr \
            --enable-cscope \
            --disable-gui \
            --prefix=/usr/local
        make -j"$(nproc)"
        $SUDO make install
    )
    if ! vim --version | grep -q '+python3'; then
        echo "Vim was built without +python3; UltiSnips requires Python 3 support." >&2
        exit 1
    fi
else
    echo "Installing Vim from apt..."
    apt_install vim
fi

if [ "$TMUX_FROM_SOURCE" = true ]; then
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
    make -C "$TMUX_SRC_DIR" distclean >/dev/null 2>&1 || true
    (
        cd "$TMUX_SRC_DIR"
        sh autogen.sh
        ./configure --prefix=/usr/local
        make -j"$(nproc)"
        $SUDO make install
    )
else
    echo "Installing tmux from apt..."
    apt_install tmux
fi

install_fzf

echo "Copying configuration files..."
rsync -ah "$REPO_DIR/.vimrc" "$REPO_DIR/.zshrc" "$HOME/"
rsync -ah "$REPO_DIR/.tmux.conf" "$TMUX_CONFIG_ROOT/"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.tmux/bin" "$HOME/.tmux/themes"
clone_or_update https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm" master
install_tmux_plugins_from_config

mkdir -p "$VIM_CONFIG_DIR/colors" "$VIM_CONFIG_DIR/bin" "$NVIM_CONFIG_DIR/colors"
rsync -ah "$REPO_DIR/themes/"*.vim "$VIM_CONFIG_DIR/colors/"
rsync -ah "$REPO_DIR/.vimrc" "$NVIM_CONFIG_DIR/init.vim"
rsync -ah "$REPO_DIR/themes/"*.vim "$NVIM_CONFIG_DIR/colors/"

echo "Installing vim-plug..."
mkdir -p "$VIM_CONFIG_DIR/autoload"
fetch_file https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    "$SRC_ROOT/plug.vim" "$VIM_CONFIG_DIR/autoload/plug.vim"

if should_run "$INSTALL_VIM_PLUGINS" "Install Vim plugins with vim-plug?" yes; then
    install_vim_plugins_from_config
    echo "Installing Vim plugins..."
    vim +'PlugInstall --sync' +qa
    if command -v nvim >/dev/null 2>&1; then
        nvim +'PlugInstall --sync' +qa
    fi
fi

if command -v zsh >/dev/null 2>&1 && should_run "$INSTALL_OH_MY_ZSH" "Install or update oh-my-zsh?" yes; then
    echo "Installing oh-my-zsh..."
    clone_or_update https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" master
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
