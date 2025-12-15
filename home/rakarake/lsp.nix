{ pkgs, outputs, ...}: {
  # LSP packages
  home.packages = with pkgs; [
    ripgrep                        # Needed for telescope's grep functionality
    vscode-langservers-extracted   # HTML / CSS / JSON / ESLint language server
    ccls                           # A C/C++ language server # C / C++
    haskell-language-server        # Haskell
    nil                            # Nix??? 😲
    rustfmt                        # Rust
    rust-analyzer                  # Rust language server
    lua-language-server            # Lua
    gopls                          # Go
    (agda.withPackages [ agdaPackages.standard-library ]) # Agda
    tinymist                                              # Typst
    wgsl-analyzer                                         # WGSL
    omnisharp-roslyn                                      # C#
    erlang-language-platform
    pyright                                               # Python
    outputs.packages.${pkgs.system}.gdshader-lsp          # Godot shading language
    zls                                                   # Zig
    glsl_analyzer
  ];
}
