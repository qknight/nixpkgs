{ stdenv, fetchgit, python, pyqt4, pyopengl, setuptools, pythonPackages } :

stdenv.mkDerivation {
  name = "brickv-1.1.14";
  
  src = fetchgit {
    url = "git://github.com/Tinkerforge/brickv.git";
    rev = "e68e8df766f42e731e26a037f4982e4aff7b10aa";
  };

  buildInputs = [ python pyqt4 pythonPackages.pyqwt pyopengl pythonPackages.wrapPython ];

  pythonPath = [ pyqt4 pyopengl pythonPackages.pyqwt ];

  zzz = ''
    import sys
    import os
    sys.path.append(os.path.join(os.path.dirname(__file__), "../lib/python2.7/site-packages/brickv"))
  '';

  prePatch = ''
    substituteInPlace src/brickv/main.py --replace "import sys" "$zzz"
    substituteInPlace src/brickv/build_ui.py --replace "/usr/bin/env python" "${python}/bin/python"
    substituteInPlace src/brickv/build_all_ui.py --replace "/usr/bin/env python" "${python}/bin/python"
  '';

  buildPhase = ''
    cd src/brickv
    ${python}/bin/python build_all_ui.py
  '';

  installPhase = ''
    cd ..
    for i in brickv/plot_widget.py brickv/plugin_system/plugins/servo/servo.py brickv/plugin_system/plugins/stepper/speedometer.py brickv/plugin_system/plugins/imu/imu.py brickv/plugin_system/plugins/rotary_poti/rotary_poti.py brickv/plugin_system/plugins/dc/speedometer.py; do 
        substituteInPlace $i --replace "PyQt4.Qwt5" "Qwt"
    done
    cd brickv


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
  };

}
