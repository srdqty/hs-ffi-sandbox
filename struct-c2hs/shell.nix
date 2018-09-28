import ../shell.nix {
  otherBuildInputs = (pkgs: [pkgs.pcre pkgs.pkgconfig]);
  otherHaskellPackages = (pkgs: hpkgs: [
    hpkgs.bytestring
    hpkgs.text
  ]);
}
