{ stdenv, fetchgit, pythonPackages, setuptools } :

stdenv.mkDerivation rec {
  name = "brickv-${version}";
  version = "2.1.2";
  
  src = fetchgit {
    url = "git://github.com/Tinkerforge/brickv.git";
    rev = "refs/tags/v${version}";
    sha256 = "036p3n9l9fixqk4kxach0bx8sb24s9f4z86x0vph38bs62nbygl3";
  };

  buildInputs = with pythonPackages; [ python pyqt4 pyopengl pyqwt wrapPython ];
  python_deps = with pythonPackages; [ python pyqt4 pyopengl pyqwt wrapPython pyserial setuptools ];
  pythonPath = python_deps;
  propagatedBuildInputs = python_deps;

  #zzz = ''
  #  import sys
  #  sys.path.append(os.path.join(os.path.dirname(__file__), "../lib/python2.7/site-packages/brickv"))
  #'';

  prePatch = ''
    #substituteInPlace src/brickv/main.py --replace "import sys" "$zzz"
    find . -name \*.py | while read i
      do
        sed -i -e "s|#!/usr/bin/env python|#!${pythonPackages.python}/bin/python|" $i
      done
  '';

  buildPhase = ''
    cd src
    ${pythonPackages.python}/bin/python build_all_ui.py
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share

    cd brickv
    mv * $out/share

    # replace the tinkerforge wrapper by nixified one
    echo "#!/bin/sh" > brickv
    # FIXME, $@ is missing
    echo "/bin/sh $out/share/main.py \"$@\"" >> brickv
    chmod u+x brickv
    mv brickv $out/bin
  
    wrapPythonPrograms;
  '';

  meta = {
    homepage = http://www.tinkerforge.com/;
    description = "The Brick Viewer provides a graphical interface for testing Bricks and Bricklets. Each device has its own view that shows the main features and allows to control them.";
    maintainers = [ stdenv.lib.maintainers.qknight ];
    license = "GPLv2";
    platforms = stdenv.lib.platforms.all;
  };

}
