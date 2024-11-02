#!/bin/bash
set -e

VIM_FROM_SOURCE=true # Set to false to install Vim using apt
VIM_CONFIG_DIR=~/.vim
NVIM_CONFIG_DIR=~/.configs/nvim
TMUX_CONFIG_ROOT=~/

# Install dependencies
echo "Updating package lists..."
sudo apt update

echo "Installing basic utilities..."
sudo apt-get install -y tmux zsh universal-ctags cowsay fortune
sudo apt-get remove vim

if $VIM_FROM_SOURCE; then
    # Install VIM build dependencies
    echo "Installing VIM build dependencies..."
    sudo apt install -y \
        git \
        build-essential \
        ncurses-dev \
        python3-dev \
        python3-pip \
        ruby-dev \
        lua5.3-dev \
        libgtk-3-dev \
        libxt-dev \
        libperl-dev \
        libclang-dev \
        libx11-dev \
        libxpm-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libgif-dev \
        libgtk2.0-dev \
        libgpm-dev \
        checkinstall

    # Clone Vim and install from source
    echo "Cloning Vim repository..."
    git clone https://github.com/vim/vim.git
    cd vim

    echo "Configuring Vim..."
    ./configure --with-features=huge \
                --enable-multibyte \
                --enable-rubyinterp=yes \
                --enable-pythoninterp=yes \
                --enable-python3interp=yes \
                --enable-perlinterp=yes \
                --enable-luainterp=yes \
                --enable-cscope \
                --prefix=/usr/local

    echo "Compiling Vim..."
    make -j$(nproc)

    echo "Installing Vim..."
    sudo checkinstall --install=yes --fstrans=no --pkgname=vim --default
    cd ..
    rm -rf vim
else
    # Install Vim using apt
    echo "Installing Vim using apt..."
    sudo apt install -y vim
fi

# Verify Vim installation
echo "Verifying Vim installation..."
vim --version

# Install fzf
echo "Cloning fzf..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
echo "Installing fzf..."
sudo ~/.fzf/install

# Replace zshrc's user home folder path with the current user
echo "Updating zsh configuration..."
sed -i -e "s/$USER/$(whoami)/g" ~/.zshrc

# Install oh-my-zsh
echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set zsh as the default shell
chsh -s $(which zsh)

# Copy configs
echo "Copying configuration files..."
rsync -ahv .vimrc .zshrc ~/
sudo rsync -ahv .tmux.conf $TMUX_CONFIG_ROOT/

mkdir -p $NVIM_CONFIG_DIR
rsync -ahv .vimrc $NVIM_CONFIG_DIR/init.vim

# Copy vim theme
echo "Copying Vim theme..."
mkdir -p ~/.vim/colors
rsync -ahv themes/molokai.vim $VIM_CONFIG_DIR/colors
rsync -ahv themes/molokai.vim $NVIM_CONFIG_DIR/colors

# Clone Vundle
echo "Cloning Vundle..."
git clone https://github.com/VundleVim/Vundle.vim.git $VIM_CONFIG_DIR/bundle/Vundle.vim

# Install vim plugins with Vundle
echo "Installing Vim plugins with Vundle..."
vim +PlugInstall +qall
if command -v nvim &> /dev/null; then
    nvim +PlugInstall +qall
fi

# Configure git
echo "Configuring Git..."
git config --global diff.tool vimdiff

echo "Installation complete!"
