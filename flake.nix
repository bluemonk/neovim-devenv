{
  description = "Neovim base devenv";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      rtDeps = with pkgs; [
        nerd-fonts.jetbrains-mono
        noto-fonts-color-emoji
        stylua # lua code formatter
        nixfmt-rfc-style # nix code formatter
        ripgrep # for telescope
        fd # for telescope
        curl # for blink.cmp
        git # for blink.cmp
	nixd # nix language server

      ];

      neovim-wrapped = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
        autowrapRuntimeDeps = true;
        viAlias = true;
        vimAlias = true;

        luaRcContent = ''
          ${builtins.readFile ./init.lua}
          ${builtins.readFile ./plugins.lua}
          ${builtins.readFile ./keymaps.lua}
        '';

        plugins = with pkgs.vimPlugins; [
          luasnip
          lazydev-nvim
          plenary-nvim
          onenord-nvim
          lualine-nvim
          guess-indent-nvim
          which-key-nvim
          gitsigns-nvim
          nvim-lspconfig
          nvim-autopairs
          telescope-nvim
          telescope-zf-native-nvim
          telescope-ui-select-nvim
          nvim-web-devicons
          conform-nvim
          blink-cmp
          mini-nvim
          vim-nix
          (nvim-treesitter.withPlugins (p: [
            p.tree-sitter-vim
            p.tree-sitter-nix
          ]))
        ];
      };

      neovim = neovim-wrapped.overrideAttrs (oldAttrs: {
        runtimeDeps = oldAttrs.runtimeDeps ++ rtDeps;
      });

    in
    {
      packages.${system}.default = neovim;

      devShells.${system}.default = pkgs.mkShell {
        packages = [ neovim ] ++ rtDeps;
        shellHook = "exec fish";
      };

    };
}
