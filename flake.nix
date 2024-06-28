{
  description = "NixOS configuration with flakes";
  inputs.nixpkgs.url = "nixpkgs/release-24.05";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.yinzhou = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        ./configuration.nix
	./hardware-configuration.nix
        # add your model from this list: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen4
      ];
    };
  };
}

