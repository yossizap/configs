VIM_CONFIG_DIR=~/.vim
NVIM_CONFIG_DIR=~/.configs/nvim
TMUX_CONFIG_ROOT=~/

# Install dependencies
sudo apt-get install vim tmux zsh exuberant-ctags

# Replace zshrc's user home folder path with the current user
sed -i .zshrc -e "s/yossi/$(whoami)/g"

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Copy configs
rsync -ahv .vimrc .zshrc ~/

mkdir -p $NVIM_CONFIG_DIR
rsync -ahv .vimrc $NVIM_CONFIG_DIR/init.vim

sudo rsync -ahv tmux.conf $TMUX_CONFIG_ROOT/tmux.conf

# Copy vim theme
mkdir -p ~/.vim/colors
rsync -ahv themes/molokai.vim $VIM_CONFIG_DIR/colors
rsync -ahv themes/molokai.vim $NVIM_CONFIG_DIR/colors

# Clone Vundle
git clone https://github.com/VundleVim/Vundle.vim.git $VIM_CONFIG_DIR/bundle/Vundle.vim

# Install vim plugins with Vundle
vim +PluginInstall +qall
if [ -x "$(command -v nvim)" ]; then
  nvim +PluginInstall +qall
fi

# Clone tpm for tmux resurrect
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
