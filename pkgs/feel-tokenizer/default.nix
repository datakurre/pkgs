{ pkgs, npmlock2nix, src }:

(import npmlock2nix { inherit pkgs; }).v2.build {
  inherit src;
  installPhase = ''
    mkdir -p $out/bin $out/lib $out/lib/lezer-feel/lezer-feel
    cp -a package.json $out/lib/lezer-feel/lezer-feel
    cp -a dist $out/lib/lezer-feel/lezer-feel
    cp -a node_modules $out/lib
    cat > $out/bin/feel-tokenizer << EOF
#!/usr/bin/env node
const classHighlighter = require("@lezer/highlight").classHighlighter;
const highlightTree = require("@lezer/highlight").highlightTree;
const parser = require('lezer-feel').parser;
const source = require('fs').readFileSync(0, 'utf-8');
console.log(JSON.stringify(((source, tree) => {
  const children = [];
  let index = 0;
  highlightTree(tree, classHighlighter, (from, to, classes) => {
    if (from > index) {
      children.push({
        type: "text",
        index: index,
        value: source.slice(index, from)
      })
    }
    children.push({
      type: classes.replace(/tok-/g, ""),
      index: from,
      children: [{
        type: "text",
        index: from,
        value: source.slice(from, to)
      }]
    });
    index = to;
  });
  if (index < source.length) {
    children.push({
      type: "text",
      index: index,
      value: source.slice(index)
    });
  }
  return children;
})(source, parser.parse(source))));
EOF
    chmod u+x $out/bin/feel-tokenizer
    wrapProgram $out/bin/feel-tokenizer \
      --set PATH ${pkgs.lib.makeBinPath [ pkgs.nodejs ]} \
      --set NODE_PATH $out/lib/lezer-feel:$out/lib/node_modules
  '';
  buildInputs = [ pkgs.makeWrapper ];
  buildCommands = [ "npm run build" ];
  node_modules_attrs = {
    preBuild = ''
      cp package.json x; rm package.json; mv x package.json
      substituteInPlace package.json \
        --replace "run-s build" "echo run-s build"
    '';
  };
}
