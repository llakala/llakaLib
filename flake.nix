{
  outputs = { nixpkgs, ... }:
  let
    lib = nixpkgs.lib;

    # Systems which I can assume will probably work fine. If they ever don't, let me know!
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64_linux" "aarch64-darwin" ];

    forAllSystems = function: lib.genAttrs
      supportedSystems
      (system: function nixpkgs.legacyPackages.${system});

    # Pure lib functions without any reliance on `pkgs`
    # We use laziness to rely on pureLlakaLib, while *creating* pureLlakaLib. Nix is magic
    llakaLib =
    let
      utils = { inherit lib nixpkgs llakaLib; };
    in lib.packagesFromDirectoryRecursive
    {
      callPackage = lib.callPackageWith utils;

      directory = ./lib;
    };

    # Impure lib functions that need `pkgs` to function
    # Actually defined as a function that *creates* impureLlakaLib after inputting `pkgs`
    # `pkgs` can be inputted by instantiating `forAllSystems`
    mkImpureLlakaLib = pkgs: llakaLib.collectDirectoryPackages
    {
      inherit pkgs;

      directory = ./packages;
      extras = { inherit llakaLib; };
    };
  in
  {
    # If you need everything to be system-independent
    pureLib = llakaLib;

    # Only impure functions
    legacyPackages = forAllSystems
    ( pkgs: mkImpureLlakaLib pkgs );

    # Merges pure/impure lib functions, if you're okay with passing in system
    fullLib = forAllSystems
    (
      pkgs: llakaLib // (mkImpureLlakaLib pkgs)
    );
  };


}