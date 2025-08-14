{
  pkgs ? import <nixpkgs> { },
}:
pkgs.callPackage ./nvim.nix { }
