{
  description = "NixOS configuration with flakes";
  # https://hydra.nixos.org/job/nixos/release-24.05/tested#tabs-status
  inputs.nixpkgs.url = "nixpkgs/cd3e8833d70618c4eea8df06f95b364b016d4950";
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
