{ lib }:
# From https://noogle.dev/f/lib/packagesFromDirectoryRecursive#create-a-scope-for-the-nix-files-found-in-a-directory
# For convenience in flake with custom packages relying on each other
# Doesn't insert llakaLib by default, you can do that on your own via `extras`

{ directory, pkgs, extras ? {} }: # Function arguments
lib.makeScope pkgs.newScope
(
  # `localPackages` are internally-defined packages we find along the way
  # We use a wrapping set to grab `localPackages` as a file input, and prevent `pkgs` shadowing
  # from grabbing individual discovered packages locally
  localPackages: let localWrapper = { inherit localPackages; }; in
  lib.packagesFromDirectoryRecursive
  {
    callPackage = lib.callPackageWith (localWrapper // pkgs // extras ); # Rely on custom packages, `pkgs`, and `llakaLib`
    inherit directory;
  }
)
