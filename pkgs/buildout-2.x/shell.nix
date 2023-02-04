{ nixpkgs, system }:

let

  overlay = _: pkgs: {
    python2 = pkgs.python2.override {
      packageOverrides = self: super: {
        # Patch Python distribution to base on setuptools 51.3.3,
        # which is the good known version of setuptools for zc.buildout 2.x
        bootstrapped-pip = self.callPackage ./pkgs/bootstrapped-pip {
          inherit (self)
          setuptools;
          inherit (super)
          pip
          pipInstallHook
          python
          setuptoolsBuildHook
          wheel;
        };
        setuptools = pkgs.callPackage ./pkgs/setuptools {
          inherit (self)
          bootstrapped-pip;
          inherit (super)
          buildPythonPackage
          pipInstallHook
          python
          setuptoolsBuildHook
          wrapPython;
        };
        # Override hook to avoid conflicting paths
        pytestCheckHook = super.pytestCheckHook.override { pytest = self.pytest; };
        # plone pins
        cryptography_vectors = self.callPackage ./pkgs/cryptography/vectors.nix {
          inherit (super)
          buildPythonPackage
          cryptography
          fetchPypi;
        };
        cryptography = self.callPackage ./pkgs/cryptography {
          inherit (super)
          cryptography_vectors
          buildPythonPackage
          fetchPypi;
        };
        ipaddress = self.callPackage ./pkgs/ipaddress {
          inherit (super)
          buildPythonPackage
          fetchPypi;
        };
        docutils = self.callPackage ./pkgs/docutils {
          inherit (super)
          buildPythonPackage
          fetchPypi;
        };
        zc_buildout_nix = self.callPackage ./pkgs/buildout {
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
    config = {
      permittedInsecurePackages = [
        "python2.7-Pillow-6.2.2"
#       Known issues:
#        - CVE-2020-10177
#        - CVE-2020-10378
#        - CVE-2020-10379
#        - CVE-2020-10994
#        - CVE-2020-11538
#        - CVE-2020-35653
#        - CVE-2020-35654
#        - CVE-2020-35655
#        - CVE-2021-25289
#        - CVE-2021-25290
#        - CVE-2021-25291
#        - CVE-2021-25292
#        - CVE-2021-25293
#        - CVE-2021-27921
#        - CVE-2021-27922
#        - CVE-2021-27923
      ];
    };
  };

in

pkgs.mkShell {
  buildInputs = [
    pkgs.black
    (pkgs.python2.withPackages(ps: [
      # Packages that need to come from nixpkgs
#     ps.cryptography
      ps.lxml
      ps.pillow
      ps.setuptools
      # Buildout patched to prioritize nixpkgs
      ps.zc_buildout_nix
    ]))
    pkgs.pcre
  ];
}
