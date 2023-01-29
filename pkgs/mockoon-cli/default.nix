{ pkgs, npmlock2nix }:

(import npmlock2nix { inherit pkgs; }).v2.build rec {
  src = ./.;
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -a node_modules $out/lib
    ln -s $out/lib/node_modules/@mockoon/cli/bin/run $out/bin/mockoon-cli
    wrapProgram $out/bin/mockoon-cli \
      --set PATH ${pkgs.lib.makeBinPath [ pkgs.nodejs ]} \
      --set NODE_PATH $out/lib/node_modules
  '';
  buildInputs = [ pkgs.makeWrapper ];
  buildCommands = [];
}
