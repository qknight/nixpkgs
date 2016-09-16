{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "leaps-${version}";
  version = "20160626-${stdenv.lib.strings.substring 0 7 rev}";
  rev = "5d19e3f44a88d0f8f5ea058b0998ea351c7cac64";

  goPackagePath = "github.com/jeffail/leaps";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/qknight/leaps";
    sha256 = "1pwjmg6k227vfgklw73dj10hvf005vy1gh6kfhrqipvvx1q0bjvf";
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
