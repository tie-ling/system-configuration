{
  description = "NixOS configuration with flakes";
  # https://github.com/NixOS/nixpkgs/commits/nixos-unstable/?author=K900
  inputs.nixpkgs.url = "nixpkgs/f8c05a483c77538ab945d0bc40d9995543f1466c";
  # https://github.com/nixos/nixos-hardware
  outputs =
    { self, nixpkgs }@inputs:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      nixosConfigurations.yinzhou = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./laptop/configuration.nix
          ./laptop/hardware-configuration.nix
        ];
      };
      nixosConfigurations.dell-7300 = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./dell-7300/configuration.nix
          ./dell-7300/hardware-configuration.nix
        ];
      };
      nixosConfigurations.hp-840g3 = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hp-840g3/configuration.nix
          ./hp-840g3/hardware-configuration.nix
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
