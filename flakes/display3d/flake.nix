{
  description = "display3d";

  #version = "v4.4.142";

  inputs = {
    nixpkgs = {
      type = "indirect";
      id = "nixpkgs";
    };

    display3d = {
      type = "git";
      url = "https://github.com/redpenguinyt/display3d";
      flake = false;
      submodules = true;
    };

  };

  outputs = { self, nixpkgs, display3d }: {
    packages.x86_64-linux.display3d =
      with import nixpkgs { system = "x86_64-linux"; };
      let pkgs = nixpkgs.legacyPackages."x86_64-linux"; in
      pkgs.rustPlatform.buildRustPackage {
        pname = "display3d";
        version = "0.1.3";
        src = display3d;
        cargoBuildFlags = "";

        cargoLock = {
          lockFile = ./Cargo.lock;
          allowBuiltinFetchGit = true;
        };

        cargoPatches = [
          # a patch file to add/update Cargo.lock in the source code
          ./add-Cargo.lock.patch
        ];

        nativeBuildInputs = [ pkgs.pkg-config ];
        PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
      };

    packages.x86_64-linux.default = self.packages.x86_64-linux.display3d;
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.display3d;
  };
}
