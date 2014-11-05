{ stdenv, fetchurl, qt4 }:

stdenv.mkDerivation rec {
  name = "qwt-5.2.3";

  src = fetchurl {
    url = "http://archive.ubuntu.com/ubuntu/pool/universe/q/qwt5/qwt5_5.2.3.orig.tar.gz";
    sha256 = "5303941f265ba02e9b2144a6ca3556aaa48dda7b5225505ab9db549032efecd0";
  };

  #src = fetchurl {
  #  url = "mirror://sourceforge/qwt/${name}.tar.bz2";
  #  sha256 = "17snmh8qwsgb4j2yiyzmi0s1jli14vby5wv1kv4kvjq4aisvpf72";
  #};

  propagatedBuildInputs = [ qt4 ];

  patches = [ ./prefix-5.2.3.diff ];

  postPatch = ''
    sed -e "s@\$\$\[QT_INSTALL_PLUGINS\]@$out/lib/qt4/plugins@" -i designer/designer.pro
    '';

  configurePhase = ''qmake INSTALLBASE=$out -after doc.path=$out/share/doc/${name} -r'';

  meta = with stdenv.lib; {
    description = "Qt widgets for technical applications";
    homepage = http://qwt.sourceforge.net/;
    # LGPL 2.1 plus a few exceptions (more liberal)
    license = "Qwt License, Version 1.0";
    platforms = platforms.linux;
    maintainers = [ maintainers.bjornfor ];
  };
}
