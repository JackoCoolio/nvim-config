{
  description = "My Neovim config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/x86_64-linux";
  };

  outputs =
    {
      nixpkgs,
      systems,
      treefmt-nix,
      ...
    }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    in
    rec {
      packages = eachSystem (pkgs: {
        default = import ./default.nix { inherit pkgs; };
      });

      devShells = eachSystem (pkgs: {
        default = import ./shell.nix {
          inherit pkgs;
          formatter = formatter.${pkgs.system};
        };
      });

      formatter = eachSystem (pkgs: (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper);
    };
}
