{

  inputs =
  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    llakaLib =
    {
      url = "github:llakala/llakaLib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... } @ inputs:
  let
    lib = nixpkgs.lib;
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];


    forAllSystems = function: lib.genAttrs
      supportedSystems
      (system: function nixpkgs.legacyPackages.${system});
  in
  {
    legacyPackages = forAllSystems
    (
      pkgs: let llakaLib = inputs.llakaLib.fullLib.${pkgs.system}; # My custom lib functions
      in llakaLib.collectDirectoryPackages
      {
        inherit pkgs;
        directory = ./packages;

        extras = { inherit llakaLib; }; # Lets the packages rely on llakaLib
      }
    );

    devShells = forAllSystems
    (
      pkgs:
      {
        default = pkgs.mkShellNoCC
        {
          # Expose all packages provided by the flake, using collect to recurse into subfolders.
          # We filter for derivations, since the output of collectDirectoryPackages leaves some
          # functions in the packages list, which we filter out by only grabbing derivations.
          packages = lib.collect (lib.isDerivation) self.legacyPackages.${pkgs.system};
        };
      }
    );


  };
}
