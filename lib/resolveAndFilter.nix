{ llakaLib }:

input:
  llakaLib.filterNixFiles ( llakaLib.resolveFolders input )
