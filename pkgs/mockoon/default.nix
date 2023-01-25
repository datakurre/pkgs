{ version, appimageTools, fetchurl }:

appimageTools.wrapType2 rec {
  name = "mockoon";
  inherit version;
  src = fetchurl {
    url = "https://github.com/mockoon/mockoon/releases/download/v${version}/mockoon-${version}.AppImage";
    sha256 = "sha256-HYGXKo1OV+2Buccb+hZikV+AenzinpoA4z95leh5U1I=";
  };
  extraPkgs = pkgs: with pkgs; [ ];
}
