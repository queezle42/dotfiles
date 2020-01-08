{ pkgs }:
{
  neovim = pkgs.neovim.override {
    configure = {
      customRC = ''
        inoremap fd <Esc>
        vnoremap fd <Esc>

        set shiftwidth=2
        set expandtab
        set shiftround

        set smartindent
        filetype plugin indent on
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ vim-sneak ];
        opt = [ ];
      };
    };
  };
}