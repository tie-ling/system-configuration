{
  description = "NixOS configuration with flakes";
  # https://hydra.nixos.org/job/nixos/release-24.05/tested#tabs-status
  inputs.nixpkgs.url = "nixpkgs/f1bad50880bae73ff2d82fafc22010b4fc097a9c";
  # https://github.com/nixos/nixos-hardware
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/3980e7816c99d9e4da7a7b762e5b294055b73b2f";
  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
    }@inputs:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      nixosConfigurations.yinzhou = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./laptop/configuration.nix
          ./laptop/hardware-configuration.nix
          # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen4
        ];
      };
      nixosConfigurations.tieling = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./server/configuration.nix
          ./server/hardware-configuration.nix
        ];
      };
      nixosConfigurations.player = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./player/configuration.nix
          ./player/hardware-configuration.nix
        ];
      };
    };
}
