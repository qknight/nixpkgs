# IDS Imaging Development Systems GmbH - IDS Software Suite

# package these entities:
# - ids-uEye-suite-usb
#   - ueyenotify
#   - ueyesetid  
#   - ueyesetip  
#   - ueyeusbd
# - ids-uEye-suite-usb-service
#   - ueyeusbd
#   - udev rules
# - package the qt4 example program

{ stdenv, fetchurl, glib }:

let

  libPath = stdenv.lib.makeLibraryPath [
    glib
  ];

in

assert stdenv.system == "i686-linux" || stdenv.system == "x86_64-linux";

stdenv.mkDerivation rec {
  name = "idsuEye-${version}";
  version = "4.61";

  src =
    if stdenv.system == "i686-linux" then
      fetchurl {
	url = "https://de.ids-imaging.com/download-ueye.html?file=tl_files/downloads/uEye_SDK/driver/uEye_Linux_${version}_32_Bit.tgz";
	sha256 = "3a64e83d37c437b1c2708232228a3da4958ee726d91501a0d2678f9a9e869709";
      }
    else if stdenv.system == "x86_64-linux" then
      fetchurl {
	url = "https://de.ids-imaging.com/download-ueye.html?file=tl_files/downloads/uEye_SDK/driver/uEye_Linux_${version}_64_Bit.tgz";
	sha256 = "aada46524e7756ec9d4840e166c056ec7c9f0b8774e521c35d5d6d4b9c2da5fc";
      }
    else
      abort "IDS Software Suite requires i686-linux or x86_64-linux";

  installPhase = ''
    mkdir "$out"

    /bin/sh ueyesdk-setup-4.61-usb-amd64.gz.run --noexec --target extracted/    

    cd extracted/

    mkdir $out/lib
    cp lib64/libueye_api64.so.4.61 $out/lib/libueye_api.so

    mkdir $out/fw
    cp fw/* $out/fw

    mkdir $out/includes
    mv include/ueye.h include/uEye.h
    cp -r include/* $out/includes

    mkdir -p $out/share/doc
    cp -r doc/* $out/share/doc

    mkdir $out/bin
    for i in ueyenotify ueyesetid ueyesetip ueyeusbd; do
      cp "bin64/$i" $out/bin
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$out/bin/$i"
      patchelf --set-rpath "${stdenv.cc.cc}/lib:${stdenv.cc.cc}/lib64:${libPath}:$out/lib" "$out/bin/$i"
    done
  '';

  meta = with stdenv.lib; {
    description = "IDS Software Suite from IDS Imaging Development Systems GmbH";
    homepage = https://en.ids-imaging.com/;
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [ qknight ];
  };
}
