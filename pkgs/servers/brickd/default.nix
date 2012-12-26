{ stdenv, fetchgit, python, twisted, libusb, pythonPackages } :

stdenv.mkDerivation {
  name = "brickd-1.0.11";
  
  src = fetchgit {
    url = "git://github.com/Tinkerforge/brickd.git";
    rev = "0d870e69d37488bc046f267d6c9ae0a01abf46f9";
  };

  buildInputs = [ libusb python twisted pythonPackages.wrapPython ];

  pythonPath = [ libusb twisted  ];

  zzz = ''
    import signal
    sys.path.append(os.path.join(os.path.dirname(__file__), '../lib/python2.7/site-packages/brickd'))
  '';

  prePatch = ''
    substituteInPlace src/brickd/libusb/libusb1.py --replace "libusb-1.0" "${libusb}/lib/libusb-1.0"
    substituteInPlace src/brickd/brickd_linux.py --replace "import signal" "$zzz"
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/python2.7/site-packages/brickd

    cd src/brickd

    rm ./_build_dmg.sh ./brickd_windows.py ./brickd_macosx.py ./build_pkg.py

    mv brickd_linux.py $out/bin/brickd
    mv * $out/lib/python2.7/site-packages/brickd
    wrapPythonPrograms
  '';

  meta = {
    homepage = http://www.tinkerforge.com/;
    description = "The Brick Daemon is a daemon (or service on Windows) that acts as a bridge between the Bricks/Bricklets and the API bindings for the different programming languages.";
    maintainers = [ stdenv.lib.maintainers.qknight ];
  };

}
