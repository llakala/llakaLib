{ lib }:
# From https://noogle.dev/f/lib/packagesFromDirectoryRecursive#create-a-scope-for-the-nix-files-found-in-a-directory
# For convenience in flake with custom packages relying on each other
# Doesn't insert llakaLib by default, you can do that on your own via `extras`

{ directory, pkgs, extras ? {} }: # Function arguments
lib.makeScope pkgs.newScope
(
  selfPkgs: lib.packagesFromDirectoryRecursive # selfPkgs are internally-defined packages we find along the way
  {
    callPackage = lib.callPackageWith (selfPkgs // pkgs // extras ); # Rely on custom packages, `pkgs`, and `llakaLib`
    inherit directory;
  }
)
