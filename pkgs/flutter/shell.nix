{ pkgs, flutter, sdk }:

let

  android-sdk = (sdk (ps: [
    ps.cmdline-tools-latest
    ps.build-tools-29-0-2
    ps.build-tools-30-0-3
    ps.tools
    ps.patcher-v4
    ps.platform-tools
    ps.platforms-android-31
    ps.platforms-android-33
    ps.system-images-android-31-default-x86-64
    ps.emulator
  ]));

  vscode-flutter = (pkgs.vscode-with-extensions.override {
    vscodeExtensions = [
      pkgs.vscode-extensions.bbenoist.nix
      pkgs.vscode-extensions.dart-code.flutter
      pkgs.vscode-extensions.dart-code.dart-code
      pkgs.vscode-extensions.ms-vscode.makefile-tools
      pkgs.vscode-extensions.redhat.vscode-yaml
      pkgs.vscode-extensions.redhat.vscode-xml
      pkgs.vscode-extensions.vscodevim.vim
    ];
  });

in pkgs.mkShell {
  buildInputs = [
    # Flutter
    flutter
    vscode-flutter
    pkgs.git

    # Android
    android-sdk
    pkgs.jdk11
    pkgs.unzip

    # Web
    pkgs.chromium

    # Linux
    pkgs.at-spi2-core.dev
    pkgs.clang
    pkgs.cmake
    pkgs.dbus.dev
    pkgs.gtk3
    pkgs.libepoxy
    pkgs.glib
    pkgs.libpng
    pkgs.fontconfig
    pkgs.libdatrie
    pkgs.libdeflate
    pkgs.libepoxy.dev
    pkgs.libffi
    pkgs.libjpeg
    pkgs.libselinux
    pkgs.libsepol
    pkgs.libthai
    pkgs.libxkbcommon
    pkgs.ninja
    pkgs.pcre
    pkgs.pcre2.dev
    pkgs.pkg-config
    pkgs.util-linux.dev
    pkgs.xorg.libXdmcp
    pkgs.xorg.libXtst
  ];
  shellHook = ''
    export ANDROID_SDK_HOME="$(pwd)"
    export ANDROID_SDK_ROOT="${android-sdk}/share/android-sdk/"
    export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=${android-sdk}/share/android-sdk/build-tools/32.0.0/aapt2"
    export CHROME_EXECUTABLE="${pkgs.chromium}/bin/chromium"
    echo 'TODO: avdmanager create avd -n "Android" -k "system-images;android-31;default;x86_64"'
  '';
}
