{ lib, makeWrapper, npmlock2nix, nodejs, chromium, src, robot-task }:

npmlock2nix.v1.build rec {
 inherit src;
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -a node_modules $out/lib
    cp -a cli.js $out/bin/bpmn-to-image
    cp -a index.js $out/lib
    cp -a skeleton.html $out/lib
    cp ${robot-task}/dist/module-iife.js $out/lib/robot-task.js
    substituteInPlace $out/bin/bpmn-to-image \
      --replace "'./'" \
                "'$out/lib'"
    substituteInPlace $out/lib/index.js \
      --replace "puppeteer.launch();" \
                "puppeteer.launch({executablePath: '${chromium}/bin/chromium'});" \
      --replace "await loadScript(viewerScript);"\
                "await loadScript(viewerScript); await loadScript('$out/lib/robot-task.js')"
    substituteInPlace $out/lib/skeleton.html \
      --replace "container: '#canvas'" \
                "container: '#canvas', additionalModules: [ RobotTaskModule ]"
    wrapProgram $out/bin/bpmn-to-image \
      --set PATH ${lib.makeBinPath [ nodejs ]} \
      --set NODE_PATH $out/lib/node_modules
  '';
  buildInputs = [ makeWrapper ];
  buildCommands = [];
  node_modules_attrs = {
    PUPPETEER_SKIP_DOWNLOAD = "true";
  };
}
