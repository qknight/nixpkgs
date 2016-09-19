{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "leaps-${version}";
  version = "20160626-${stdenv.lib.strings.substring 0 7 rev}";
  rev = "70524e3d02d0cf31f3d13737193a1459150781c8";

  goPackagePath = "github.com/jeffail/leaps";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/jeffail/leaps";
    sha256 = "0w63y777h5qc8fwnkrbawn3an9px0l1zz3649x0n8lhk125fvchj";
    fetchSubmodules = false;  
  };

  goDeps = ./deps.json;
  meta = {
    description = "A pair programming tool and library written in Golang";
    homepage = "https://github.com/jeffail/leaps/";
    license = "MIT";
    maintainers = with stdenv.lib.maintainers; [ qknight ];
    meta.platforms = stdenv.lib.platforms.linux;
  };
}
