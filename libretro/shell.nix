import ../shell.nix {
  otherBuildInputs = (pkgs: [pkgs.pkgconfig]);
#  otherHaskellPackages = (pkgs: hpkgs: [
#    hpkgs.bytestring
#    hpkgs.text
#  ]);
}
