{
  description = "DSSAT Cropping System Model";

  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
          buildTesting = pkgs.targetPlatform.isx86_64;
        in
        rec
        {
          packages.default = pkgs.stdenv.mkDerivation {
            name = "dssat-csm-os";
            src = self;

            dontUseCmakeConfigure = true;
            nativeBuildInputs = with pkgs; [ cmake makeWrapper ];
            binutils = pkgs.binutils-unwrapped;

            buildInputs = with pkgs; [ gfortran glibc.static ];

            buildPhase = ''
              mkdir -p build
              cd build
              cmake -DCMAKE_BUILD_TYPE=RELEASE ..
              make
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp bin/dscsm047 $out/bin/
            '';
          };

          devShells.default = pkgs.stdenv.mkDerivation {
            name = "dssat-csm-os-env";
            nativeBuildInputs = packages.default.nativeBuildInputs;

            buildInputs = packages.default.buildInputs;
          };
        }
      );
}

