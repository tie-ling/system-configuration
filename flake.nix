{
  description = "NixOS configuration with flakes";
  # https://hydra.nixos.org/job/nixos/release-24.05/tested#tabs-status
  inputs.nixpkgs.url = "nixpkgs/e4509b3a560c87a8d4cb6f9992b8915abf9e36d8";
  # https://github.com/nixos/nixos-hardware
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/3980e7816c99d9e4da7a7b762e5b294055b73b2f";
  inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote/b627ccd97d0159214cee5c7db1412b75e4be6086";

    # Optional but recommended to limit the size of your system closure.
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      lanzaboote,
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
          lanzaboote.nixosModules.lanzaboote
        ];
      };
    };
}
