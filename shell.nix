{ compiler ? import ./nix/ghc.nix
, otherBuildInputs ? (pkgs: [])
, otherHaskellPackages ? (pkgs: haskellPackages: [])
}:

let
  pkgs = import ./nix/nixpkgs-pinned {};
in
  pkgs.stdenv.mkDerivation rec {
    name = "hs-ffi-sandbox";

    buildInputs = otherBuildInputs pkgs ++ [
      pkgs.gcc
      pkgs.ncurses # Needed by the bash-prompt.sh script
      (pkgs.haskell.packages."${compiler}".ghcWithPackages (hpkgs: [
        hpkgs.cabal-install
        hpkgs.hsc2hs
        hpkgs.c2hs
      ] ++ otherHaskellPackages pkgs hpkgs))
    ];

    shellHook = builtins.readFile ./nix/bash-prompt.sh + ''
      source ${pkgs.git.out}/etc/bash_completion.d/git-prompt.sh
      source ${pkgs.git.out}/etc/bash_completion.d/git-completion.bash
    '';
  }
