{ nixpkgs, system }:

let

  overlay = _: pkgs: {
    python3 = pkgs.python3.override {
      packageOverrides = self: super: {
        zc_buildout_nix = self.callPackage ./. {
          inherit (super)
          buildPythonPackage
          fetchPypi;
        };
      };
    };
  };

  pkgs = import nixpkgs {
    inherit system;
    overlays = [ overlay ];
    config = {};
  };

in

pkgs.mkShell {
  buildInputs = [
    pkgs.black
    (pkgs.python3.withPackages(ps: [
      # Packages that need to come from nixpkgs
      ps.cryptography
      ps.lxml
      ps.pillow
      ps.setuptools
      # And
      ps.tox  # for bobtemplates.plone
      ps.zc_buildout_nix  # support packages from nixpkgs
    ]))
    pkgs.pcre
  ];
}
