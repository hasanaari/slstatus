{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages.${system} = {
      slstatus = pkgs.slstatus.overrideAttrs (old: {
        src = ./.;

        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.makeWrapper];

        postInstall = ''
          wrapProgram $out/bin/slstatus \
            --prefix PATH : ${pkgs.lib.makeBinPath [
            pkgs.wireplumber
            pkgs.gawk
          ]}
        '';
      });

      default = self.packages.${system}.slstatus;
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        pkg-config
        libX11
        wireplumber
        gawk
      ];
    };
  };
}
