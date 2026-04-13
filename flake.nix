{
  description = "bemenu wrapper for pinentry";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f
          (import nixpkgs { inherit system; }));

    in {
      packages = forAllSystems (pkgs:
        let
          pinentry-bemenu = pkgs.stdenvNoCC.mkDerivation {
          pname = "pinentry-bemenu";
          version = "unstable";
          src = ./.;
          dontUnpack = true;

          installPhase = ''
            install -Dm755 "$src/pinentry-bemenu" "$out/bin/pinentry-bemenu"
            ln -s "$out/bin/pinentry-bemenu" "$out/bin/pinentry"
          '';

          meta.mainProgram = "pinentry-bemenu";
        };

        in {
        default = pinentry-bemenu;
        inherit pinentry-bemenu;
      });

      apps = forAllSystems (pkgs: {
        default = {
        type = "app";
        program = "${self.packages.${pkgs.system}.default}/bin/pinentry-bemenu";
      };

      pinentry-bemenu = {
        type = "app";
        program = "${self.packages.${pkgs.system}.pinentry-bemenu}/bin/pinentry-bemenu";
      };
    });
  };
}
