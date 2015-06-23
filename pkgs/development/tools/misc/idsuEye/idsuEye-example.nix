# IDS Imaging Development Systems GmbH - IDS Software Suite
{ stdenv, pkgs, fetchurl, qt4, idsuEye }:


stdenv.mkDerivation rec {
  name = "idsuEye-example-${version}";
  version = "4.61";

  buildInputs = [ qt4 idsuEye ];

  src = fetchurl {
    url = "https://de.ids-imaging.com/download-ueye.html?file=tl_files/downloads/uEye_SDK/driver/uEye_Linux_${version}_64_Bit.tgz";
    sha256 = "aada46524e7756ec9d4840e166c056ec7c9f0b8774e521c35d5d6d4b9c2da5fc";  
  };

  phases = [ "unpackPhase" "extractionPhase" "patchPhase" "configurePhase" "buildPhase" "installPhase" ];
  patches = [ ./fix-build-system.patch ];
  
  extractionPhase = ''
    /bin/sh ueyesdk-setup-4.61-usb-amd64.gz.run --noexec --target extracted/    
    cd extracted/src/ueyedemo
  '';

  configurePhase = ''
    echo "INCLUDEPATH += ${pkgs.idsuEye}/includes" >> uEyeDemo.pro
    echo "DESTDIR=\"$out\"" >> uEyeDemo.pro
    cat uEyeDemo.pro
    echo $out
    echo "=-----------------------"
    qmake PREFIX=$out
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv $out/ueyedemo $out/bin
  '';

  meta = with stdenv.lib; {
    description = "IDS Software Suite from IDS Imaging Development Systems GmbH - Qt4 example program";
    homepage = https://en.ids-imaging.com/;
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [ qknight ];
  };
}
