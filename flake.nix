{
  outputs = { nixpkgs, ... }:
  let
    lib = nixpkgs.lib;

    # Currently creating this for setting up a pkgs instance. I tried using `forAllSystems`
    # here, but it was creating an attrset that was different systems at top-level, which
    # isn't what I need. I dislike creating unnecessary pkgs instances, but I don't see
    # an obvious workaround here, so it'll do. Let me know if there's a better way!
    pkgs = nixpkgs.legacyPackages.x86_64-linux;


    # Imports all custom functions in myLib automatically
    # We use laziness to rely on myLib, while creating myLib. Nix is magic
    myLib =
    let
      utils = { inherit lib nixpkgs myLib; };
    in lib.packagesFromDirectoryRecursive
    {
      # Create an instance of callPackage, but with more things importable
      callPackage = lib.callPackageWith (pkgs // utils );

      directory = ./lib;
    };
  in
  {
    lib = myLib; # Only output we give, so consumers can use myLib functions.
  };


}