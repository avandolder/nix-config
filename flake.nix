{
  description = "nixos-adam flake configuration";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    firefox.url = "github:nix-community/flake-firefox-nightly";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
  };

  outputs = {
    self,
    nixpkgs,
    nix-formatter-pack,
    ...
  } @ inputs: let
    inherit (self) outputs;

    system = "x86_64-linux";
    formatterPackArgs = {
      inherit nixpkgs system;
      checkFiles = [./.];

      config.tools = {
        alejandra.enable = true;
        deadnix.enable = true;
        statix.enable = true;
      };
    };
  in {
    checks.${system}.nix-formatter-pack-check = nix-formatter-pack.lib.mkCheck formatterPackArgs;
    formatter.${system} = nix-formatter-pack.lib.mkFormatter formatterPackArgs;

    overlays = import ./overlays {inherit inputs;};

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      nixos-adam = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./configuration.nix];
      };
    };
  };
}
