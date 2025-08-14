{
  pkgs ? import <nixpkgs> { },
  formatter,
}:
pkgs.mkShell {
  packages = with pkgs; [
    lua-language-server
    stylua
    formatter
  ];
}
