{
  outputs = { nixpkgs, ... }:
  let
    lib = nixpkgs.lib;

    # Systems which I can assume will probably work fine. If they ever don't, let me know!
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

    forAllSystems = function: lib.genAttrs
      supportedSystems
      (system: function nixpkgs.legacyPackages.${system});

    # So files can import `llakaLib`, not pureLib
    # We rely on pureLib for all functions, even impure ones,
    # because impureLib currently doesn't contain any of the pure functions
    # we only merge them in the outputs. This means impure functions
    # currently can't depend on each other (unless they use the newScope behavior)
    llakaLib = pureLib;

    # Pure lib functions without any reliance on `pkgs`
    # We use laziness to rely on pureLib, while *creating* pureLib. Nix is magic
    pureLib =
    let
      utils = { inherit lib nixpkgs llakaLib; };
    in lib.packagesFromDirectoryRecursive
    {
      callPackage = lib.callPackageWith utils;

      directory = ./lib;
    };

    # Impure lib functions that need `pkgs` to function
    # We make a single value here, wrapped in forAllSystems
    # We then access different parts of it in the outputs,
    # to avoid reinstantiating as much as possible. See
    # discourse.nixos.org/t/using-nixpkgs-legacypackages-system-vs-import/17462/8
    # tldr, calling a function with the same arguments twice isn't optimized, but
    # accessing the same VALUE is, so we try not to repeatedly call functions
    # where possible.
    impureLib = forAllSystems
    (
      pkgs: pureLib.collectDirectoryPackages
      {
        inherit pkgs;

        directory = ./impureLib;
        extras = { inherit llakaLib; };
      }
    );
  in
  {
    # If you only want pure functions and no reliance on system parameter
    inherit pureLib;

    # Merges pure/impure lib functions, if you're okay with passing in system
    # For each system, we merge pureLib with impureLib for that given system
    # This means all systems get an instance of fullLib, while avoiding unnecessary
    # calling of functions and saving on eval time
    fullLib = forAllSystems
    (
      pkgs: pureLib //
        (impureLib.${pkgs.system})
    );

    templates.default =
    {
      path = ./template;
      description = "nix flake init --template llakala/llakaLib";
    };
  };


}
