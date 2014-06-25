{ stdenv, fetchurl, unzip, nodejs, bash, curl, postgresql, python, utillinux }:

stdenv.mkDerivation {
  name = "etherpad-lite-1.4.0";

  src = fetchurl {
    url = http://lastlog.de/misc/ether-etherpad-lite-1.4.0-1-gc3a6a23.zip;
    sha256 = "73e936fcd4e7d314d56bcbe0345b0123ea1769435100341556f06d2591faf015";
  };

  # utillinux for flock, needed by node_modules/ueberDB/node_modules/pg/build
  buildInputs = [ nodejs unzip bash curl postgresql python utillinux ];
 
  phases = "unpackPhase configurePhase patchPhase buildPhase installPhase";

  patches = [
    ./abs-path.patch
  ];

  configurePhase = ''
    #npm2nix
  '';
 
  buildPhase = ''
    make
    # HOME=. is a hack to make npm work, i needs to write ~/.npm and ~/.node-gyp/ 
    #HOME=. npm install ep_table_of_contents
    #HOME=. npm install ep_markdown
    HOME=. bin/installDeps.sh
    echo -e "done\n" > src/.ep_initialized
    echo "22e064455007a45719a7da3db34214c32002713b91970dae651d9f00baa6bd0a#" > APIKEY.txt
  '';
  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';

  meta = {
    description = "Etherpad is a highly customizable Open Source online editor providing collaborative editing in really real-time.";
    homepage = http://etherpad.org;
    license = stdenv.lib.licenses.asl20;
    maintainers = [ stdenv.lib.maintainers.qknight ];
  };
}
