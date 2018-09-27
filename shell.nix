{ compiler ? import ./nix/ghc.nix }:

let
  pkgs = import ./nix/nixpkgs-pinned {};
in
  pkgs.stdenv.mkDerivation rec {
    name = "hs-ffi-sandbox";

    buildInputs = [
      pkgs.gcc
      pkgs.ncurses # Needed by the bash-prompt.sh script
      (pkgs.haskell.packages."${compiler}".ghcWithPackages (pkgs: with pkgs; [
        cabal-install
        hsc2hs
        c2hs
      ]))
    ];

    shellHook = builtins.readFile ./nix/bash-prompt.sh + ''
      source ${pkgs.git.out}/etc/bash_completion.d/git-prompt.sh
      source ${pkgs.git.out}/etc/bash_completion.d/git-completion.bash
    '';
  }
