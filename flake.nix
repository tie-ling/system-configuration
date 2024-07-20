{
  description = "NixOS configuration with flakes";
  # https://hydra.nixos.org/job/nixos/release-24.05/tested#tabs-status
  inputs.nixpkgs.url = "nixpkgs/3f35c2c40fbadf5cba8b45bbeec19879e144262c";
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
          ./configuration.nix
          ./hardware-configuration.nix
          # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen4
        ];
      };
    };
}
