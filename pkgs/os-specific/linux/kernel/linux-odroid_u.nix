{ stdenv, fetchgit, ... } @ args:

import ./generic.nix (args // rec {
  version = "3.8.13.23";

  modDirVersion = "3.8.13.23"; #WTF is a modDirVersion?

  src = fetchgit {
    url = "https://github.com/hardkernel/linux.git";
    rev = "611de8e983e24007598ca87cb0060b5412f97e43";
    sha256 = "09jdzkpqfmnpz4i974p4vy84489wmkl5yq5rawhqwg1i2alas58s";
  };

  #features.iwlwifi = true;

  extraMeta.hydraPlatforms = [];
})
