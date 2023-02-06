{ nixpkgs, system, python }:

let

  overlay = _: pkgs: {
    "${python}" = (builtins.getAttr python pkgs).override {
      packageOverrides = self: super: {
        zc_buildout_nix = self.callPackage ./. {
          inherit (super)
          buildPythonPackage
          fetchPypi
          pip
          wheel;
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
    # Python
    ((builtins.getAttr python pkgs).withPackages(ps: [
      # Packages that need to come from nixpkgs
      ps.cryptography
      ps.lxml
      ps.pillow
      ps.setuptools
      # Buildout patched to prioritize nixpkgs
      ps.zc_buildout_nix  # support packages from nixpkgs
      # Tox for obtemplates.plone
      ps.tox
    ]))
    # Tools
    pkgs.black
    pkgs.pcre
  ];
}
