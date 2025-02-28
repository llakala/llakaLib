{ lib }:
# From https://noogle.dev/f/lib/packagesFromDirectoryRecursive#create-a-scope-for-the-nix-files-found-in-a-directory
# For convenience in flake with custom packages relying on each other
# Doesn't insert llakaLib by default, you can do that on your own via `extras`

{ directory, pkgs, extras ? {} }: # Function arguments
let
  unfiltered = lib.makeScope pkgs.newScope
  (
    # We use a wrapping set to grab `localPackages` as a file input,
    # rather than its values. This helps to prevent issues with shadowing
    # when a local package has the same name as something # in `pkgs`
    localPackages: lib.packagesFromDirectoryRecursive
    {
      callPackage = lib.callPackageWith
      (
        pkgs
        // extras
        // { inherit localPackages; }
      );
      inherit directory;
    }
  );
in
  # makeScope gives a lot of extra functions in its output. We only
  # want the derivations. We get them by passing in unfilteredOutput
  # to its `packages` function, which takes an input attrset
  # of the attrs to be supplied. We supply it with own derivations,
  # so it can rely on them. Metadata gone!
  unfiltered.packages unfiltered
