{ stdenv, fetchurl}:

stdenv.mkDerivation {
  name = "conf_dvb2xspf";
  
  src = fetchurl {
    url = http://media.cdn.ubuntu-de.org/forum/attachments/55/34/2081188-conf_dvb2xspf.tar.gz;
    sha256 = "4ac72083412f95536267370ef789af8e9056bcca924a39ac4f640d74063ca273";
  };

  
  prePatch = ''
    substituteInPlace makefile --replace "/usr/bin/g++" "g++"
  '';


  installPhase = ''
    ensureDir $out
    mkdir -p $out/bin
    cp conf_dvb2xspf $out/bin
  '';


  meta = { 
    description = "dvb2xspf converter";
    homepage = "http://forum.ubuntuusers.de/topic/vlc-und-dvb-s-wie/2/#post-2081188";
    license = "GPLv2";
  };
}

