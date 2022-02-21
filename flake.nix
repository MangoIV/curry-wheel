{
  description = "curry-wheel, an alternative to statusbars";

  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-2111";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
      let
        comp = "ghc8107";
        overlays = [ haskellNix.overlay
        (final: prev: {
          # This overlay adds our project to pkgs
          curry-wheel =
            final.haskell-nix.project' {
              src = pkgs.haskell-nix.haskellLib.cleanGit { 
                src = ./.;
                name = "curry-wheel";
              };
              compiler-nix-name = comp;
              shell = rec {
                tools = {
                  cabal = "3.6.2.0";
                  haskell-language-server = {
                    version = "latest";
                    compiler-nix-name = comp;
                  };
                };

                buildInputs = [
                  pkgs.nixpkgs-fmt
                ];
                crossPlatform = [];

                withHoogle = true;
              };
            };
          }) 
        ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.curry-wheel.flake { crossPlatforms = p: []; };
      package = flake.packages."curry-wheel:exe:curry-wheel";

      in flake // {
        defaultPackage = package;
      }
      );
}
