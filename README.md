# Table of Contents

- [Introduction](#introduction)
- [Vim Configuration](#vim-configuration)
  - [Custom Shortcuts](#custom-shortcuts)
  - [Plugin-Specific Shortcuts](#plugin-specific-shortcuts)
  - [Important Vim Options](#important-vim-options)
  - [Useful Commands](#useful-commands)
  - [Theme](#theme)
- [Tmux Configuration](#tmux-configuration)
  - [Important Tmux Options](#important-tmux-options)
  - [Tmux Shortcuts and Plugin Usage](#tmux-shortcuts-and-plugin-usage)
- [Contributing](#contributing)
- [License](#license)

# Introduction

---
This repository provides configurations for Vim and tmux to create a productive, distraction-free environment. 
The setups maintain default behaviors while adding quality-of-life enhancements. 
You can easily install everything using the `install.sh` script, which configures `.bashrc`, `.zshrc`, `fzf`, and `.vimrc` with all necessary dependencies.

# Vim Configuration

Custom key mappings are minimal and intuitive, focused on improving productivity without disrupting familiar Vim workflows.

This configuration uses [vim-plug](https://github.com/junegunn/vim-plug) as the plugin manager. To install plugins, use:

- `:PlugInstall` – Install new plugins
- `:PlugUpdate` – Update installed plugins

## Custom Shortcuts

### General Key Mappings
- `jj` – Exit insert mode
- `<C-W>z` – Toggle zoom for the current pane
- `<F8>` – Toggle spell check
- `<Leader>s` – Start a search-and-replace with confirmation (ZZWrap function)
- `:w!!` – Save the file with sudo privileges
- `:Man` – Open Unix man pages in Vim
- `cs[char][char]` – Easily change surrounding characters (requires vim-surround plugin)
- `\cs` and `\c<space>` – Comments and uncomments selected code (requires NERD Commenter plugin)

### Pane and Window Management
- `<F4>` – Toggle NERDTree sidebar file explorer
- `<F3>` – Toggle Tagbar (provides a file structure view)
- `<A-h>`, `<A-j>`, `<A-k>`, `<A-l>` – Switch between splits (works with Tmux if vim-tmux-navigator is installed)

### Terminal Management
- `<C-t>` – Toggle floating terminal window (requires vim-floaterm plugin)

## Plugin-Specific Shortcuts

### EasyMotion
- `<Leader>h`, `<Leader>j`, `<Leader>k`, `<Leader>l` – EasyMotion mappings for linewise navigation
- `<F>` – EasyMotion prefix key for jump navigation

### UltiSnips
- `<C-j> / <C-k>` – Navigate forward/backward within a snippet
- `:UltiSnipsEdit` – Open snippet editor

### FZF
- `<C-p>` – Open FZF file navigator
- `<C-f>` – Search file content via FZF with ripgrep (`Rg` command)

### ALE (Asynchronous Linting)
- `let g:ale_echo_cursor = 1` – Show errors when hovering over highlighted text
- Custom error formatting:
  - Error: `>>`
  - Warning: `--`

### vim-fugitive
- `<C-g>` – Open Git interface (type `g?` for help)

### Autoformatting
- `<Leader>f` – Autoformat code in visual mode (requires vim-autoformat plugin)

## Important Vim Options

### Interface Settings
- `set number` – Show line numbers
- `set relativenumber` – Show relative line numbers
- `set ruler` – Display cursor position
- `set cmdheight=1` – Set command line height to one line

### Indentation and Tabs
- `set expandtab` – Convert tabs to spaces
- `set shiftwidth=4` – Indentation width
- `set softtabstop=4` – Set tab spacing

### Search
- `set ignorecase` – Ignore case in search patterns
- `set smartcase` – Override ignorecase if search pattern has uppercase letters

### Miscellaneous
- `set hidden` – Keep buffers open in the background
- `set lazyredraw` – Optimize screen redraws during macros
- `set scrolloff=1` – Keep 1 line of context around the cursor when scrolling

## Useful Commands

- `:ContextToggle` – Show/hide function context (requires context.vim plugin)
- `:Goyo` – Enter distraction-free mode (requires goyo.vim plugin)
- `:Limelight` – Dim surrounding text to focus on the current line (requires limelight.vim plugin)
- `:AutoFormat` – Run autoformat on current selection or entire file
- `:ClangFormat` – Apply clang-format to current selection or entire file

## Theme

- `set background=dark`
- `colorscheme molokai`

# Tmux Configuration

## Important Tmux Options
- `set-window-option -g mode-keys vi` - Enables Vi key bindings in Tmux copy mode
- `set-window-option -g automatic-rename` - Automatically renames windows based on the running command
- `bind {c|v|s} new-window {-c|-h -c|-v -c} "#{pane_current_path}"` - Opens new windows and panes in the current working directory
- `set -g history-limit 50000` - Expands the scrollback buffer size.
- `setw -g mouse on` - Allows mouse interactions for pane selection and resizing
- `setw -g monitor-activity on` and `set -g visual-activity on` - Provides visual cues for activity within panes

## Tmux Shortcuts and Plugin Usage

### Prefix Key
- **Default Prefix**: `Ctrl+b`

### Key Bindings
- **Navigation**:
  - `M-Left`, `M-Down`, `M-Up`, `M-Right`: Navigate between panes using Alt + arrow keys. If in Vim, sends the corresponding Vim navigation command.
  - `C-h`, `C-j`, `C-k`, `C-l`: Navigate between panes using Ctrl + arrow keys. Sends Vim commands if applicable.

- **Window and Pane Management**:
  - `c`: Create a new window in the current directory.
  - `v`: Split the current pane horizontally in the same directory.
  - `s`: Split the current pane vertically in the same directory.
  - `r`: Reload the Tmux configuration file.

- **Copy Mode**:
  - `Prefix + [`: Start copy mode.
  - `v`: Begin selection in copy mode.
  - `y`: Copy the selected text and exit copy mode.
  - `Prefix + ]`: Paste from copy mode clipboard

### Plugins
- **Tmux Plugin Manager (TPM)**:
  - `Prefix + I`: Install plugins defined in the configuration.
  
- **Tmux Resurrect**:
  - Automatically saves and restores sessions. Use `Prefix + Ctrl + s` to save and `Prefix + Ctrl + r` to restore.

- **Fuzzy Search**:
  - `Prefix + f`: Open a fuzzy search for commands in Tmux history.

- **Tmux Jump**:
  - `Prefix + j`: Use Easymotion-style jumps to quickly move between panes.

- **Tmux Logging**:
  - `Prefix + Alt + Shift + p`: Save complete history in the current pane.
  - `Prefix + Shift + p`: Toggle logging in the current pane.

- **Tmux FZF**
  - `Prefix + F`: Open a menu to manage your tmux environment and sessions
 
- **Extrakto**
  - `Prefix + TAB` - Opens a menu that allows you to use command completions from your window history
  
### Miscellaneous
- **Show list of shortcuts**: `Prefix + ?` – Display a list of key bindings.
- **Reload configuration**: `Prefix + :` followed by `source ~/.tmux.conf` – Reload the tmux configuration file.

# Contributing

Feel free to submit issues or pull requests for further improvements to this configuration.

# License

This configuration is open source and available under the MIT License.
