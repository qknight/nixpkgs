{ stdenv, fetchurl, qt4 }:

stdenv.mkDerivation rec {
  #name = "qwt-5.2.3";
  #src = fetchurl {
  #  url = "mirror://sourceforge/qwt/${name}.tar.bz2";
  #  sha256 = "1dqa096mm6n3bidfq2b67nmdsvsw4ndzzd1qhl6hn8skcwqazzip";
  #};
  #patches = [ ./prefix-5.2.3.diff ];

  src = pkgs.fetchurl {
    url = "http://prdownloads.sourceforge.net/pyqwt/PyQwt-${version}.tar.gz";
    sha256 = "02z7g60sjm3hx7b21dd8cjv73w057dwpgyyz24f701vdqzhcga4q";
  };

  #name = "qwt-5.2.1";
  #patches = [ ./prefix-5.2.1.diff ];
  #src = fetchurl {
  #  url = "mirror://sourceforge/qwt/${name}.tar.bz2";
  #  sha256 = "e2b8bb755404cb3dc99e61f3e2d7262152193488f5fbe88524eb698e11ac569f";
  #};

  #name = "qwt-5.2.3";
  #patches = [ ./prefix-5.2.3.diff ];
  #src = fetchurl {
  #  url = "http://archive.ubuntu.com/ubuntu/pool/universe/q/qwt5/qwt5_5.2.3.orig.tar.gz";
  #  sha256 = "5303941f265ba02e9b2144a6ca3556aaa48dda7b5225505ab9db549032efecd0";
  #};

  propagatedBuildInputs = [ qt4 ];

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
