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

  # Systems
  outputs = { self, nixpkgs, flake-utils, ... }@args: flake-utils.lib.eachDefaultSystem (system: let pkgs = nixpkgs.legacyPackages.${system}; in {

    apps = {
      cmndseven-cli = args.cmndseven-cli.apps.${system}.default;
      rcc = { type = "app"; program = self.packages.${system}.rcc + "/bin/rcc"; };
      # ZEEBE_LOG_PATH=$(pwd) ZEEBE_BROKER_DATA_DIRECTORY=$(pwd) nix run .#zeebe --impure
      zeebe = { type = "app"; program = self.packages.${system}.zeebe + "bin/broker"; };
    };

    # Packages
    packages = {
      camunda-modeler = pkgs.callPackage ./pkgs/camunda-modeler { src = args.camunda-modeler; version = "5.7.0"; };
      cmndseven-cli = args.cmndseven-cli.packages.${system}.default;
      mockoon = pkgs.callPackage ./pkgs/mockoon { version = "1.22.0"; };
      parrot-rcc = args.parrot-rcc.packages.${system}.default;
      rcc = pkgs.callPackage ./pkgs/rcc/rcc.nix { src = args.rcc; version = "v11.36.5"; };
      rccFHSUserEnv = pkgs.callPackage ./pkgs/rcc { src = args.rcc; version = "v11.36.5"; };
      zbctl = pkgs.callPackage ./pkgs/zbctl { src = args.zbctl; version = "v8.1.6"; };
      zeebe = pkgs.callPackage ./pkgs/zeebe { src = args.zeebe; version = "8.1.6"; };
      zeebe-play = pkgs.callPackage ./pkgs/zeebe-play { src = args.zeebe-play; version = "1.2.0"; };
      zeebe-simple-monitor = pkgs.callPackage ./pkgs/zeebe-simple-monitor { src = args.zeebe-simple-monitor; version = "2.4.1"; };
    };

    # Overlay
    overlays.default = final: prev: {
      inherit (self.packages.${system})
      camunda-modeler
      cmndseven-cli
      mockoon
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
        self.packages.${system}.camunda-modeler
        self.packages.${system}.cmndseven-cli
        self.packages.${system}.mockoon
        self.packages.${system}.parrot-rcc
        self.packages.${system}.rccFHSUserEnv
        self.packages.${system}.zbctl
        self.packages.${system}.zeebe-play
        self.packages.${system}.zeebe-simple-monitor
      ];
    };
  });
}
