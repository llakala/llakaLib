{ lib, llakaLib }:
# From https://noogle.dev/f/lib/packagesFromDirectoryRecursive#create-a-scope-for-the-nix-files-found-in-a-directory
# For convenience in flake with custom packages relying on each other
# We also let custom packages rely on llakaLib functions

let
  utils = { inherit llakaLib; };
in
{ directory, pkgs }: # Function arguments
lib.makeScope pkgs.newScope
(
  selfPkgs: lib.packagesFromDirectoryRecursive # selfPkgs are internally-defined packages we find along the way
  {
    callPackage = lib.callPackageWith (selfPkgs // pkgs // utils ); # Rely on custom packages, `pkgs`, and `llakaLib`
    inherit directory;
  }
)
