{ callPackage, fetchurl, dart }:

#  https://github.com/NixOS/nixpkgs/tree/master/pkgs/development/compilers/flutter

let
  mkFlutter = opts: callPackage (import ./flutter.nix opts) { };

  getPatches = dir:
    let files = builtins.attrNames (builtins.readDir dir);
    in map (f: dir + ("/" + f)) files;

  flutterDart = dart.override {
    version = "2.19.1";
    sources = let
        base = "https://storage.googleapis.com/dart-archive/channels";
        x86_64 = "x64";
        i686 = "ia32";
        aarch64 = "arm64";
        # Make sure that if the user overrides version parameter they're
        # also need to override sources, to avoid mistakes
        version = "2.19.1";
      in
      {
        "${version}-aarch64-darwin" = fetchurl {
          url = "${base}/stable/release/${version}/sdk/dartsdk-macos-${aarch64}-release.zip";
          sha256 = "1b6bxny91iczpybqy01jkka1hqfm3nl75il5qc6cgrs2v4bnzhfy";
        };
        "${version}-x86_64-darwin" = fetchurl {
          url = "${base}/stable/release/${version}/sdk/dartsdk-macos-${x86_64}-release.zip";
          sha256 = "0cl6szlcm7rp8zi023dmgqyf9s48rw6dv5k2x34kkxz079g5aagc";
        };
        "${version}-x86_64-linux" = fetchurl {
          url = "${base}/stable/release/${version}/sdk/dartsdk-linux-${x86_64}-release.zip";
          sha256 = "0qw2j92zzy8vwiawii39gxwpcm14nv45r1kf0cinr3mb7miap40k";
        };
        "${version}-i686-linux" = fetchurl {
          url = "${base}/stable/release/${version}/sdk/dartsdk-linux-${i686}-release.zip";
          sha256 = "0svrfivnq9fpziyk9sxw1hzy9bxd0rcrl1wfvv99s4zc0531k38h";
        };
        "${version}-aarch64-linux" = fetchurl {
          url = "${base}/stable/release/${version}/sdk/dartsdk-linux-${aarch64}-release.zip";
          sha256 = "sha256-Bt18brbJA/XfiyP5o197HDXMuGm+a1AZx92Thoriv78=";
        };
      };
  };

  flutterDrv = { version, pname, hash, patches }: mkFlutter {
    inherit version pname patches;
    dart = flutterDart;
    src = fetchurl {
      url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${version}-stable.tar.xz";
      sha256 = hash;
    };
  };

in flutterDrv {
  pname = "flutter";
  version = "3.7.1";
  hash = "1rf230ylif8hpwa4by4lvn2zi26mp50nlrka17lxpnmwg05p6prl";
  patches = getPatches ./patches;
}
