{
  description = "Nix Package Repository and Overlay";

  # Cachix
  nixConfig = {
    extra-trusted-public-keys = "datakurre.cachix.org-1:ayZJTy5BDd8K4PW9uc9LHV+WCsdi/fu1ETIYZMooK78=";
    extra-substituters = "https://datakurre.cachix.org";
  };

  inputs = {

    # Flakes
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    poetry2nix = { url = "github:nix-community/poetry2nix"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };

    # Android
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    android-nixpkgs = { url = "github:tadfisher/android-nixpkgs/stable"; inputs.nixpkgs.follows = "nixpkgs-unstable"; inputs.flake-utils.follows = "flake-utils"; };

    # Tools
    npmlock2nix = { url = "github:nix-community/npmlock2nix"; flake = false; };

    # Packages
    parrot-rcc = { url = "github:datakurre/parrot-rcc/main"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    cmndseven-cli = { url = "github:datakurre/cmndseven-cli/main"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };

    # Sources
    bpmn-to-image = { url = "github:bpmn-io/bpmn-to-image"; flake = false; };
    dmn-to-html = { url = "github:datakurre/dmn-to-html"; flake = false; };
    form-js-to-image = { url = "github:datakurre/form-js-to-image"; flake = false; };
    lezer-feel = { url = "github:nikku/lezer-feel"; flake = false; };
    rcc = { url = "github:robocorp/rcc/c687438a726bd417437f4fbffae9db61f0010a87"; flake = false; }; # v11.36.5
    robot-task = { url = "github:datakurre/camunda-modeler-robot-plugin"; flake = false; };
    zbctl = { url = "github:camunda/zeebe/clients/go/v8.1.6"; flake = false; };

    # Releases
    camunda-modeler = { url = "https://github.com/camunda/camunda-modeler/releases/download/v5.7.0/camunda-modeler-5.7.0-linux-x64.tar.gz"; flake = false; };
    zeebe = { url = "https://github.com/camunda/zeebe/releases/download/8.1.6/camunda-zeebe-8.1.6.tar.gz"; flake = false; };
    zeebe-play = { url = "https://github.com/camunda-community-hub/zeebe-play/releases/download/1.2.0/zeebe-play-1.2.0.zip"; flake = false; };
    zeebe-simple-monitor = { url = "https://github.com/camunda-community-hub/zeebe-simple-monitor/releases/download/2.4.1/zeebe-simple-monitor-2.4.1.zip"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs: flake-utils.lib.eachDefaultSystem (system: let pkgs = import nixpkgs { inherit system; overlays = [ inputs.poetry2nix.overlay (final: prev: { npmlock2nix = import inputs.npmlock2nix { pkgs = final; }; }) ]; }; pkgs-android = import inputs.nixpkgs-unstable { inherit system; config = { android_sdk.accept_license = true; allowUnfree = true; }; }; in {

    # Apps not equal to package name
    apps = {
      cmndseven-cli = inputs.cmndseven-cli.apps.${system}.default;
      rcc = { type = "app"; program = self.packages.${system}.rcc + "/bin/rcc"; };
      # ZEEBE_LOG_PATH=$(pwd) ZEEBE_BROKER_DATA_DIRECTORY=$(pwd) nix run .#zeebe --impure
      zeebe = { type = "app"; program = self.packages.${system}.zeebe + "bin/broker"; };
    };

    # Packages
    packages = {
      bpmn-to-image = pkgs.callPackage ./pkgs/bpmn-to-image { src = inputs.bpmn-to-image; inherit (inputs) robot-task; };
      camunda-modeler = pkgs.callPackage ./pkgs/camunda-modeler { src = inputs.camunda-modeler; version = "5.7.0"; };
      cmndseven-cli = inputs.cmndseven-cli.packages.${system}.default;
      dmn-to-html = pkgs.callPackage ./pkgs/dmn-to-html { src = inputs.dmn-to-html; };
      flutter = pkgs-android.callPackage ./pkgs/flutter {};
      feel-tokenizer = pkgs.callPackage ./pkgs/feel-tokenizer { src = inputs.lezer-feel; };
      form-js-to-image = pkgs.callPackage ./pkgs/form-js-to-image { src = inputs.form-js-to-image; };
      mockoon = pkgs.callPackage ./pkgs/mockoon { version = "1.22.0"; };
      mockoon-cli = pkgs.callPackage ./pkgs/mockoon-cli {};
      parrot-rcc = inputs.parrot-rcc.packages.${system}.default;
      rcc = pkgs.callPackage ./pkgs/rcc/rcc.nix { src = inputs.rcc; version = "v11.36.5"; };
      rccFHSUserEnv = pkgs.callPackage ./pkgs/rcc { src = inputs.rcc; version = "v11.36.5"; };
      zbctl = pkgs.callPackage ./pkgs/zbctl { src = inputs.zbctl; version = "v8.1.6"; };
      zeebe = pkgs.callPackage ./pkgs/zeebe { src = inputs.zeebe; version = "8.1.6"; };
      zeebe-play = pkgs.callPackage ./pkgs/zeebe-play { src = inputs.zeebe-play; version = "1.2.0"; };
      zeebe-simple-monitor = pkgs.callPackage ./pkgs/zeebe-simple-monitor { src = inputs.zeebe-simple-monitor; version = "2.4.1"; };
    };

    # Overlay
    overlays.default = final: prev: {
      inherit (pkgs)
      npmlock2nix
      poetry2nix;
      inherit (self.packages.${system})
      bpmn-to-image
      camunda-modeler
      cmndseven-cli
      dmn-to-html
      feel-tokenizer
      form-js-to-image
      mockoon
      mockoon-cli
      parrot-rcc
      rccFHSUserEnv
      zbctl
      zeebe
      zeebe-play
      zeebe-simple-monitor
      ;
    };

    # Shells
    devShells.default = pkgs.mkShell {
      buildInputs = [
        self.packages.${system}.bpmn-to-image
        self.packages.${system}.camunda-modeler
        self.packages.${system}.cmndseven-cli
        self.packages.${system}.dmn-to-html
        self.packages.${system}.feel-tokenizer
        self.packages.${system}.form-js-to-image
        self.packages.${system}.mockoon
        self.packages.${system}.mockoon-cli
        self.packages.${system}.parrot-rcc
        self.packages.${system}.rccFHSUserEnv
        self.packages.${system}.zbctl
        self.packages.${system}.zeebe-play
        self.packages.${system}.zeebe-simple-monitor
      ];
    };
    devShells.plone = pkgs.callPackage ./pkgs/buildout/shell.nix { inherit nixpkgs system; python = "python3"; };
    devShells.plone-python2 = pkgs.callPackage ./pkgs/buildout-2.x/shell.nix { inherit nixpkgs system; };
    devShells.plone-python3 = pkgs.callPackage ./pkgs/buildout/shell.nix { inherit nixpkgs system; python = "python3"; };
    devShells.plone-python39 = pkgs.callPackage ./pkgs/buildout/shell.nix { inherit nixpkgs system; python = "python39"; };
    devShells.plone-python310 = pkgs.callPackage ./pkgs/buildout/shell.nix { inherit nixpkgs system; python = "python310"; };
#   devShells.plone-python311 = pkgs.callPackage ./pkgs/buildout/shell.nix { inherit nixpkgs system; python = "python311"; };
    devShells.flutter = pkgs-android.callPackage ./pkgs/flutter/shell.nix { inherit (self.packages.${system}) flutter; sdk = inputs.android-nixpkgs.sdk.${system}; };
  });
}
