# Table of Contents

- [Introduction](#introduction)
- [Vim Configuration](#vim-configuration)
  - [Custom Shortcuts](#custom-shortcuts)
  - [Plugin-Specific Shortcuts](#plugin-specific-shortcuts)
  - [Project Completion](#project-completion)
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
This repository contains Vim, tmux, zsh, and fzf configuration. Run `install.sh` to install the configuration and its dependencies.

Run `select-config` to select terminal fonts and zsh, Vim, or tmux themes. Use Left to go back, Right or Enter to select, and `p` to preview.

Optional machine-specific settings can be added to `~/.zshrc.local` and `~/.vimrc.local`. They are loaded after the repository configuration and are not overwritten by the installer.

# Vim Configuration

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
- `<F3>` – Toggle Tagbar (provides a file structure view)
- `<A-h>`, `<A-j>`, `<A-k>`, `<A-l>` – Switch between Vim splits and tmux panes
- `<A-Left>`, `<A-Down>`, `<A-Up>`, `<A-Right>` – Arrow-key equivalents for Vim/tmux pane navigation

### Terminal Management
- `<C-t>` – Toggle floating terminal window (requires vim-floaterm plugin)

## Plugin-Specific Shortcuts

### EasyMotion
- `<Leader>h`, `<Leader>j`, `<Leader>k`, `<Leader>l` – EasyMotion mappings for linewise navigation
- `<Leader><Leader>` – EasyMotion prefix key for jump navigation

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
- `:ClangFormatFix` – Format the current C or C++ buffer with clang-format
- `:ClangTidyFix` – Apply clang-tidy fixes using the project compilation database

## Project Completion

Projects opt in by placing `.vim-project.json` at their root. Run `configure-vim-project` there to generate a profile. Python completion, signatures, and diagnostics use Zuban through vim-lsp. C and C++ use clangd through ALE when a compilation database is configured, and Gutentags provides tag completion.

- `Tab` / `Shift+Tab` – Complete forward/backward; snippets take priority
- `:ProjectInfo` – Show the active project profile
- `:ProjectCompletionToggle` – Toggle completion for the current buffer
- `:GutentagsToggleEnabled` – Toggle tag generation
- `K` – Show documentation for the symbol under the cursor
- `gd` / `gr` – Go to a definition or list references

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
- Default fallback: `colorscheme molokai`
- Run `~/.vim/bin/select-vim-theme` after install to preview and save a theme.
- The selected theme is written to `~/.vim/theme.vim`.
- Bundled theme: `molokai`.
- Popular colorschemes are managed through vim-plug; run `:PlugInstall` if they are not listed.
- The picker uses a curses UI. Use `/` to search, `p` to preview, `Right` or `Enter` to save, and `i` to run `PlugInstall --sync` when curated themes are missing.

# WSL Configuration

- `install.sh` enables systemd and OpenSSH inside WSL. SSH, SCP, and rsync-over-SSH become available after restarting WSL.
- Windows drives use DrvFS metadata and per-directory case sensitivity. `%USERPROFILE%\workspace` is available as `~/windows-workspace`.
- Run `windows/setup-wsl-usbip.ps1` from elevated PowerShell to install or update WSL, enable mirrored networking and Windows DNS/proxy integration, allow inbound SSH on port 22, and configure USB/IP.
- Mirrored networking requires Windows 11 22H2 or newer. Restart WSL once with `wsl --shutdown` after configuration changes.
- Linux builds are faster under the WSL filesystem. Use `~/windows-workspace` only when the repository must live on the Windows filesystem.
- `-InstallDockerDesktop` installs Docker Desktop and makes the selected distro the default. Confirm its integration in Docker Desktop settings.
- Git for Windows and Credential Manager integration are configured by default.
- A Windows Ed25519 key is created or reused, authorized in WSL, and SSH password authentication is disabled by default.
- Windows elevation uses native `sudo.exe` inline on Windows 11 24H2 or newer. Windows 10 and older Windows 11 releases use `gsudo.exe` in the current terminal.
- `-WslMemory 8GB -WslProcessors 4 -WslSwap 4GB` sets optional WSL resource limits.
- Windows commands can be launched directly from WSL, for example `explorer.exe .`, `notepad.exe file.txt`, or `powershell.exe -NoProfile -Command Get-Date`.
- Linux `sudo` only elevates Linux processes. Elevate a Windows process with `sudo.exe <command>` on Windows 11 24H2 or `gsudo.exe <command>` on earlier releases.
- Imported distributions, including a Yocto root filesystem, can launch Windows executables when WSL interop, Windows PATH appending, and drive mounting are enabled. Git integration also requires Git in the distribution; SSH setup requires a POSIX shell and OpenSSH server. The Ubuntu `install.sh` package setup does not apply to Yocto images.

# Tmux Configuration

## Important Tmux Options
- `set-window-option -g mode-keys vi` - Enables Vi key bindings in Tmux copy mode
- `set-window-option -g automatic-rename` - Automatically renames windows based on the running command
- `bind {c|v|s} new-window {-c|-h -c|-v -c} "#{pane_current_path}"` - Opens new windows and panes in the current working directory
- `set -g history-limit 50000` - Expands the scrollback buffer size.
- `setw -g mouse on` - Allows mouse interactions for pane selection and resizing
- `setw -g monitor-activity on` and `set -g visual-activity on` - Provides visual cues for activity within panes

## Tmux Theme

- Run `~/.tmux/bin/select-tmux-theme` after install to open the ranger-style theme picker.
- The selected theme is written to `~/.tmux/theme.conf`.
- Previews use an isolated tmux socket and do not modify existing tmux sessions.
- The picker uses columns for theme family, variant, and details. Use arrows or `h/j/k/l`, `p` to preview, `Enter` to save, and `q` to quit.
- Yossi's theme is the bundled Molokai-based theme with `Plain` and `Powerline` variants.
- Upstream TPM theme families: `Catppuccin`, `Tokyo Night`, `Dracula`, `Gruvbox`, `Nord`, `OneDark`, `Rose Pine`, and `Solarized`.
- Catppuccin variants: `Latte`, `Frappe`, `Macchiato`, `Mocha`.
- Tokyo Night variants: `Night`, `Storm`, `Moon`, `Day`.
- Yossi's Powerline variant keeps the centered status layout. Upstream themes use their plugin defaults.
- Powerline and upstream icon widgets require the terminal emulator profile to use a Nerd Font, such as `JetBrainsMono Nerd Font Mono`.
- Truecolor is enabled for new tmux clients. Open a new terminal tab/window or detach and reattach tmux after changing terminal/font settings.
- Tmux themes only control tmux UI colors. The main terminal pane background still comes from the terminal emulator profile unless the theme uses transparent/default backgrounds.
- `install.sh` installs `JetBrainsMono Nerd Font Mono` by default and configures GNOME Terminal when `gsettings` is available. Set `INSTALL_NERD_FONT=false` or `CONFIGURE_TERMINAL_FONT=false` to skip those steps.

## Tmux Shortcuts and Plugin Usage

### Prefix Key
- **Default Prefix**: `Ctrl+b`

### Key Bindings
- **Navigation**:
  - `M-Left`, `M-Down`, `M-Up`, `M-Right`: Navigate between panes using Alt + arrow keys. If in Vim, sends the corresponding Vim navigation command.
  - `M-h`, `M-j`, `M-k`, `M-l`: Navigate between panes using Alt + Vim direction keys. If in Vim, sends the corresponding Vim navigation command.
  - `Prefix + h/j/k/l` and `Prefix + arrows`: Navigate between panes after the tmux prefix.
  - `Shift + Left` / `Shift + Right`: Switch to the previous or next tmux window.

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
