{
  description = "NixOS configuration with flakes";
  # https://channels.nixos.org/nixos-24.11/git-revision
  # https://channels.nixos.org/nixos-unstable/git-revision
  inputs.nixpkgs.url = "nixpkgs/d70bd19e0a38ad4790d3913bf08fcbfc9eeca507";
  inputs.disko.url = "github:nix-community/disko/latest";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      self,
      nixpkgs,
      disko,
    }@inputs:
    let
      mkLaptop = (
        laptopList:
        (builtins.listToAttrs (
          map (laptopName: {
            name = laptopName;
            value = (
              nixpkgs.lib.nixosSystem {
                specialArgs = {
                  # used for   nix.registry.nixpkgs.flake = inputs.nixpkgs;
                  inherit inputs;
                };
                modules = [
                  disko.nixosModules.disko
                  ./systems/laptop/configuration.nix
                  ./systems/laptop/disko/${laptopName}.nix
                ];
              }
            );
          }) laptopList
        ))
      );
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      nixosConfigurations = {
        vps = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # You can get this file from here: https://github.com/nix-community/disko/blob/master/example/gpt-bios-compat.nix
            ./systems/vps/gpt-bios-compat.nix
            disko.nixosModules.disko
            (
              { config, ... }:
              {
                # shut up state version warning
                system.stateVersion = config.system.nixos.version;
                # Adjust this to your liking.
                # WARNING: if you set a too low value the image might be not big enough to contain the nixos installation
                disko.devices.disk.main.imageSize = "9G";
              }
            )
          ];
        };

        tieling = nixpkgs.lib.nixosSystem {
          specialArgs = {
            # used for   nix.registry.nixpkgs.flake = inputs.nixpkgs;
            inherit inputs;
          };

          modules = [
            disko.nixosModules.disko
            ./systems/server/configuration.nix
            ./systems/server/disko.nix
          ];
        };
        player = nixpkgs.lib.nixosSystem {
          specialArgs = {
            # used for   nix.registry.nixpkgs.flake = inputs.nixpkgs;
            inherit inputs;
          };

          modules = [
            disko.nixosModules.disko
            ./systems/player/configuration.nix
            ./systems/player/disko.nix
          ];
        };
      } // (mkLaptop [ "hp-840g3" "dell-7370" "dell-7300" "thinkpad-t530" ]);

    };
}
