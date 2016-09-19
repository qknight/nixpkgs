{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "leaps-${version}";
  version = "20160626-${stdenv.lib.strings.substring 0 7 rev}";
  rev = "9320bd1a0759a3c22caee1e761dc221df396ac0c";

  goPackagePath = "github.com/jeffail/leaps";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/jeffail/leaps";
    sha256 = "1rsjr0hskv9yf8vgx9jqxnldzmbi0jqih8iryx7jl8jid8cvwwdj";
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
