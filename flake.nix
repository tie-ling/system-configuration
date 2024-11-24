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
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      nixosConfigurations.hp-840g3 = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          disko.nixosModules.disko
          ./hp-840g3/configuration.nix
          ./hp-840g3/disko.nix
        ];
      };

      nixosConfigurations.vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # You can get this file from here: https://github.com/nix-community/disko/blob/master/example/gpt-bios-compat.nix
          ./vps/gpt-bios-compat.nix
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

      nixosConfigurations.tieling = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          disko.nixosModules.disko
          ./server/configuration.nix
          ./server/disko.nix
        ];
      };
      nixosConfigurations.player = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          disko.nixosModules.disko
          ./player/configuration.nix
          ./player/disko.nix
        ];
      };
    };
}
