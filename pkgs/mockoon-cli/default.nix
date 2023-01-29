{ lib, makeWrapper, npmlock2nix, nodejs }:

npmlock2nix.v2.build rec {
  src = ./.;
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -a node_modules $out/lib
    ln -s $out/lib/node_modules/@mockoon/cli/bin/run $out/bin/mockoon-cli
    wrapProgram $out/bin/mockoon-cli \
      --set PATH ${lib.makeBinPath [ nodejs ]} \
      --set NODE_PATH $out/lib/node_modules
  '';
  buildInputs = [ makeWrapper ];
  buildCommands = [];
}
