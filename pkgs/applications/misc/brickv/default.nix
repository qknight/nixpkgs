{ stdenv, fetchgit, python27Packages, pythonPackages, setuptools } :

let
  py = python27Packages;
in

stdenv.mkDerivation rec {
  name = "brickv-${version}";
  version = "2.1.1";
  
  src = fetchgit {
    url = "git://github.com/Tinkerforge/brickv.git";
    rev = "refs/tags/brickv-${version}";
    sha256 = "097kaz7d0rzg0ijvcna3y620k3m5fgxpqsac5gbhah8pd7vlj1a4";
  };

  
  python_deps = with py; [ pyopengl pyserial setuptools pythonPackages.pyqwt pythonPackages.wrapPython];

  pythonPath = python_deps;

  propagatedBuildInputs = python_deps;

  buildInputs = [ py.wrapPython ];

  #buildInputs = [ python pyqt4 pyopengl pythonPackages.pyqwt pythonPackages.wrapPython ];
  #pythonPath = [ pyqt4 pyopengl pythonPackages.pyqwt ];

  #zzz = ''
  #  import sys
  #  import os
  #  sys.path.append(os.path.join(os.path.dirname(__file__), "../lib/python2.7/site-packages/brickv"))
  #'';

  #prePatch = ''
  #  substituteInPlace src/brickv/main.py --replace "import sys" "$zzz"
  #  substituteInPlace src/brickv/build_ui.py --replace "/usr/bin/env python" "${python}/bin/python"
  #  substituteInPlace src/brickv/build_all_ui.py --replace "/usr/bin/env python" "${python}/bin/python"
  #'';

  buildPhase = ''
    cd src/brickv
    ${py.python}/bin/python build_all_ui.py
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/python2.7/site-packages/brickv

    mv main.py $out/bin/brickv
    mv * $out/lib/python2.7/site-packages/brickv

    wrapPythonPrograms
  '';

  meta = {
    homepage = http://www.tinkerforge.com/;
    description = "The Brick Viewer provides a graphical interface for testing Bricks and Bricklets. Each device has its own view that shows the main features and allows to control them.";
    maintainers = [ stdenv.lib.maintainers.qknight ];
    license = "GPLv2";
    platforms = stdenv.lib.platforms.all;
  };

}
