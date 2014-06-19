{ stdenv, fetchurl, which}:

stdenv.mkDerivation {
  name = "etherpad-lite-1.4.0";

  src = fetchurl {
    url = lastlog.de/misc/ether-etherpad-lite-1.4.0-1-gc3a6a23.zip;
    sha256 = "73e936fcd4e7d314d56bcbe0345b0123ea1769435100341556f06d2591faf015";
  };

  buildInputs = [ nodejs ];

  installPhase = ''
    mkdir -p $out;
    cd ether-etherpad-lite-c3a6a23
    cp -R * $out
  '';

  meta = {
    description = "Etherpad is a highly customizable Open Source online editor providing collaborative editing in really real-time.";
    homepage = http://etherpad.org;
    license = stdenv.lib.licenses.asl20;
    maintainers = [ stdenv.lib.maintainers.qknight ];
  };
}
