{ lib, makeWrapper, npmlock2nix, nodejs, chromium, src }:

npmlock2nix.v1.build rec {
  inherit src;
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -a node_modules $out/lib
    cp -a cli.js $out/bin/dmn-to-html
    cp -a index.js $out/lib
    cp -a skeleton.html $out/lib
    substituteInPlace $out/bin/dmn-to-html \
      --replace "'./'" \
                "'$out/lib'"
    substituteInPlace $out/lib/index.js \
      --replace "puppeteer.launch();" \
                "puppeteer.launch({executablePath: '${chromium}/bin/chromium'});"
    wrapProgram $out/bin/dmn-to-html \
      --set PATH ${lib.makeBinPath [ nodejs ]} \
      --set NODE_PATH $out/lib/node_modules
  '';
  buildInputs = [ makeWrapper ];
  buildCommands = [];
  node_modules_attrs = {
    PUPPETEER_SKIP_DOWNLOAD = "true";
  };
}
