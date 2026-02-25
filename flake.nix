{
  description = "My bash scripts with automatic dependency wrapping";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems (system: import nixpkgs { inherit system; });
    in
    {
      packages = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = forAllSystems.${system};
          scriptBuilder =
            {
              lib,
              stdenv,
              makeWrapper,
              bash,
              git,
              gnutar,
              unzip,
              zip,
              jq,
              wl-clipboard,
              xclip,
              withWayland ? stdenv.isLinux,
              withX11 ? stdenv.isLinux,
            }:
            let
              myDeps = [
                bash
                git
                gnutar
                unzip
                zip
                jq
              ]
              ++ (if withWayland then [ wl-clipboard ] else [ ])
              ++ (if withX11 then [ xclip ] else [ ]);
            in
            stdenv.mkDerivation {
              pname = "my-bash-scripts";
              version = "1.0.0";
              src = ./.;

              nativeBuildInputs = [ makeWrapper ];
              buildInputs = myDeps;

              installPhase = ''
                mkdir -p $out/bin
                binPath="${lib.makeBinPath myDeps}"

                for script in $src/*.sh; do
                  name=$(basename "$script" .sh)
                  dest="$out/bin/$name"
                  cp "$script" "$dest"
                  chmod +x "$dest"
                  wrapProgram "$dest" --prefix PATH : "$binPath"
                done
              '';
            };
        in
        {
          default = pkgs.callPackage scriptBuilder { };
        }
      );
    };
}
