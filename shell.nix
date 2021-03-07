let
  sources = import ./nix/sources.nix;
  nivPkgs = import sources.niv {};

  overlay = _: pkgs:
    { niv = nivPkgs.niv; };

  pkgs = import sources.nixpkgs
    { overlays = [ overlay ]; };

  toOsxFuse = (pkg:
    if pkg.name == pkgs.fuse.name
    then pkgs.osxfuse
    else pkg
  );

  tup-osx = pkgs.tup.overrideAttrs(props: {
    buildInputs = builtins.map toOsxFuse props.buildInputs;
  });

  lua-blade = pkgs.stdenv.mkDerivation rec {
    pname = "blade";
    version = "1.9.0";
    src = pkgs.fetchurl {
      url = "https://github.com/otm/blade/releases/download/v${version}/blade_darwin_amd64";
      sha256 = "1bslx1gf7qkk3lv6lx572jb2aijlgrcc3aga1pp7iz6wa9p4420n";
    };

    phases = [
      "installPhase"
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/blade
      chmod +x $out/bin/blade
    '';
  };
in

pkgs.mkShell {
  buildInputs = [
    pkgs.niv
    tup-osx
    lua-blade
  ];
}
