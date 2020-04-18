{ pkgs }:

pkgs.neovim.override {
  configure = {
    customRC = ''
      inoremap fd <Esc>
      vnoremap fd <Esc>

      " Configure colorscheme
      let g:gruvbox_contrast_dark='hard'
      colorscheme gruvbox
      "hi ColorMagenta guifg='#f92672' guibg=132 guibg='NONE' ctermbg='NONE' gui='NONE' cterm='NONE'
      "hi! link haskellOperators ColorMagenta

      set termguicolors

      " Enable line numbers
      set number

      set shiftwidth=2
      set expandtab
      set shiftround

      set hidden

      set smartindent
      filetype plugin indent on

      " Search case-insensitive by default but switch to case-sensitive when using uppercase letters.
      set ignorecase
      set smartcase

      " Full mouse support
      set mouse=a

      " Yank to primary selection.
      " I want to use clipboard=autoselect, when it is implemented: https://github.com/neovim/neovim/pull/3708
      set clipboard=unnamed

      " Configure completion: First <tab> completes to the longest common string and also opens the completion menu, following <Tab>s complete the next matches.
      set wildmode=longest:full,full

      " Save with Ctrl-S (if file has changed)
      noremap <c-s> <Cmd>update<CR>

      " Always show the sign column (to prevent jumps when loading git- or the language client)
      " Disabled because it also adds a sign column to NERDTree
      "set signcolumn=yes

      " NERDTree
      " Show hidden files by default
      let g:NERDTreeShowHidden = 1
      " Automaticaly close nvim if NERDTree is only thing left open
      autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
      " Toggle with Alt-b
      nnoremap <a-b> <Cmd>NERDTreeToggle<CR>

      " Airline

      let g:highlightedyank_highlight_duration = 200

      filetype on

      " Load filetype plugins
      "autocmd FileType nix :packadd vim-nix

      " Configure language client
      let g:LanguageClient_serverCommands = { 'haskell': ['hie-wrapper', '--lsp'] }

      " Use deoplete for autocompletion.
      let g:deoplete#enable_at_startup = 1
    '';
    packages.myVimPackage = with pkgs.vimPlugins; {
      start = [
        # Colorscheme
        gruvbox-community

        # Basics (VSCodeVim compatible)
        # Changes 's<char><char>' to motion that finds the next combination of the given characters (similar to 'f<char>')
        vim-sneak
        # Various commands that add, change and remove brackets, quotes and tags.
        vim-surround
        # Jump to any location by showing helper marks.
        vim-easymotion

        # Provides hook that allows other plugins to register repeat actions ('.')
        vim-repeat
        # Increment and decrement dates and times with <Ctrl-A> and <Ctrl-X>
        vim-speeddating

        vim-grepper

        fzfWrapper
        fzf-vim

        # Language server support
        LanguageClient-neovim
        deoplete-nvim

        # Improved folder navigation
        #vim-vinegear

        vim-highlightedyank

        # A Vim plugin which shows a git diff in the 'gutter' (sign column).
        vim-gitgutter

        # NERDTree
        nerdtree

        # Better status bar
        vim-airline
        vim-bufferline

        # Nix syntax highlighting
        vim-nix

        # Haskell syntax highlighting
        haskell-vim
      ];
      opt = [
      ];
    };
  };
}
