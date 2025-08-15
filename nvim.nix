let
  name = "jvim";
in
{
  lib,
  vimPlugins,
  runCommandLocal,
  symlinkJoin,
  neovim-unwrapped,
  makeWrapper,

  # runtime dependencies
  fd, # fzf
  ripgrep, # fzf
  bat, # fzf
  ...
}:
let
  startPlugins = with vimPlugins; [
    # autopairs
    mini-pairs

    # diagnostics
    trouble-nvim

    # fuzzy find
    fzf-lua

    # formatting
    conform-nvim

    # treesitter
    nvim-treesitter.withAllGrammars

    # oil
    oil-nvim
    mini-icons

    # lsp
    nvim-lspconfig
    blink-cmp

    # statusline
    lualine-nvim

    # colorscheme
    catppuccin-nvim
    sonokai
    kanagawa-nvim
  ];

  withDeps = builtins.foldl' (
    acc: next: acc ++ [ next ] ++ (withDeps (next.dependencies or [ ]))
  ) [ ];

  startPluginsWithDeps = lib.unique (withDeps startPlugins);

  packpath = runCommandLocal "packpath" { } ''
    mkdir -p $out/pack/${name}/{start,opt}

    mkdir -p $out/pack/${name}/start/jtwam
    ln -vsfT ${./lua} $out/pack/${name}/start/jtwam/lua

    ${lib.concatMapStringsSep "\n" (
      plugin: "ln -vsfT ${plugin} $out/pack/${name}/start/${lib.getName plugin}"
    ) startPluginsWithDeps}
  '';

  path = lib.concatStringsSep ":" (
    map (pkg: "${lib.getBin pkg}/bin") [
      fd
      ripgrep
      bat
    ]
  );
in
symlinkJoin {
  name = "nvim";
  paths = [ neovim-unwrapped ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = # sh
    ''
      wrapProgram $out/bin/nvim \
        --set-default NVIM_APPNAME "${name}" \
        --prefix PATH ":" "${path}" \
        --add-flags -u \
        --add-flags "${./init.lua}" \
        --add-flags --cmd \
        --add-flags "'set packpath^=${packpath} | set runtimepath^=${packpath}'"

      ln -s $out/bin/nvim $out/bin/vim
    '';

  passthru = { inherit packpath path; };
}

# Adapted from https://ayats.org/blog/neovim-wrapper
