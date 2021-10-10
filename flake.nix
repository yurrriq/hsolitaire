{
  description = "Solitaire, written in Haskell, for my own edification";

  inputs = {
    emacs-overlay = {
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
      url = "github:nix-community/emacs-overlay";
    };
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.05";
    pre-commit-hooks-nix = {
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
      url = "github:cachix/pre-commit-hooks.nix";
    };
    treefmt-nix = {
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:numtide/treefmt-nix";
    };
  };

  outputs = inputs@{ emacs-overlay, flake-parts, flake-utils, nixpkgs, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        overlays = {
          default = final: prev:
            nixpkgs.lib.composeManyExtensions
              (builtins.attrValues (removeAttrs self.overlays [ "default" ]))
              final
              prev;

          haskellPackages = _final: prev: {
            haskellPackages = prev.haskellPackages.override {
              overrides = _hfinal: hprev: {
                hsolitaire = hprev.callCabal2nix "hsolitaire" self { };
              };
            };
          };

          myEmacs = nixpkgs.lib.composeExtensions emacs-overlay.overlay (_final: prev: {
            myEmacs = prev.emacsWithPackagesFromUsePackage {
              alwaysEnsure = true;
              config = ./emacs.el;
            };
          });

          treefmt = _final: prev: {
            treefmt = prev.treefmt1;
          };
        };
      };

      imports = [
        inputs.pre-commit-hooks-nix.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
      ];

      perSystem = { config, pkgs, self', system, ... }: {
        _module.args.pkgs = import nixpkgs {
          overlays = [
            self.overlays.default
          ];
          inherit system;
        };

        apps = {
          default = self'.apps.hsolitaire;

          hsolitaire = flake-utils.lib.mkApp {
            drv = pkgs.haskell.lib.justStaticExecutables self'.packages.hsolitaire;
          };
        };

        devShells = {
          default = pkgs.mkShell {
            FONTCONFIG_FILE = pkgs.makeFontsConf {
              fontDirectories = [
                (pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; })
              ];
            };

            inputsFrom = [
              config.pre-commit.devShell
              self'.packages.hsolitaire.env
            ];

            nativeBuildInputs = with pkgs; [
              cabal-install
              direnv
              ghcid
              haskell-language-server
              haskellPackages.ormolu
              haskellPackages.pointfree
              hlint
              myEmacs
              nixd
            ];
          };
        };

        packages = {
          default = self'.packages.hsolitaire;
          inherit (pkgs.haskellPackages) hsolitaire;
        };

        pre-commit.settings.hooks = {
          editorconfig-checker.enable = true;
          treefmt.enable = true;
        };

        treefmt = {
          projectRootFile = ./flake.nix;
          programs = {
            deadnix.enable = true;
            hlint.enable = true;
            nixpkgs-fmt.enable = true;
            ormolu.enable = true;
            prettier.enable = true;
          };
        };
      };
    };
}
