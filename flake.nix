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
      packages = nixpkgs.lib.genAttrs systems (system: {
        default =
          let
            pkgs = forAllSystems.${system};

            myDeps =
              with pkgs;
              [
                bash
                git
                gnutar
                unzip
                zip
                jq
              ]
              ++ (
                if stdenv.isLinux then
                  [
                    wl-clipboard
                    xclip
                  ]
                else
                  [ ]
              );

          in
          pkgs.stdenv.mkDerivation {
            pname = "my-bash-scripts";
            version = "1.0.0";
            src = ./.;

            nativeBuildInputs = [ pkgs.makeWrapper ];
            buildInputs = myDeps;

            installPhase = ''
              mkdir -p $out/bin

              binPath="${nixpkgs.lib.makeBinPath myDeps}"

              for script in $src/*.sh; do
                name=$(basename "$script" .sh)
                dest="$out/bin/$name"
                
                cp "$script" "$dest"
                chmod +x "$dest"
                
                wrapProgram "$dest" --prefix PATH : "$binPath"
              done
            '';
          };
      });
    };
}
