{
  description = "Solitaire, written in Haskell, for my own edification";

  inputs = {
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, emacs-overlay, flake-utils, nixpkgs }:
    {
      overlay = nixpkgs.lib.composeManyExtensions (nixpkgs.lib.attrValues self.overlays);

      overlays = {
        haskellPackages = final: prev: {
          haskellPackages = prev.haskellPackages.override {
            overrides = hfinal: hprev: {
              hsolitaire = hprev.callCabal2nix "hsolitaire" self { };
            };
          };
        };
        myEmacs = nixpkgs.lib.composeExtensions emacs-overlay.overlay (final: prev: {
          myEmacs = prev.emacsWithPackagesFromUsePackage {
            alwaysEnsure = true;
            config = ./emacs.el;
          };
        });
      };
    } // flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          overlays = [ self.overlay ];
          inherit system;
        };
      in
      {
        apps.hsolitaire = flake-utils.lib.mkApp {
          drv = pkgs.haskell.lib.justStaticExecutables self.defaultPackage.${system};
        };
        defaultApp = self.apps.${system}.hsolitaire;
        defaultPackage = self.packages.${system}.hsolitaire;
        devShell = pkgs.mkShell {
          FONTCONFIG_FILE = pkgs.makeFontsConf {
            fontDirectories = [ pkgs.iosevka ];
          };

          buildInputs = with pkgs; [
            cabal-install
            direnv
            ghcid
            haskell-language-server
            haskellPackages.ormolu
            haskellPackages.pointfree
            hlint
            myEmacs
            nix-direnv
            nixpkgs-fmt
            rnix-lsp
          ] ++ self.defaultPackage.${system}.env.nativeBuildInputs;
        };
        packages = { inherit (pkgs.haskellPackages) hsolitaire; };
      });
}
