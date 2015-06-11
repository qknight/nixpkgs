{ stdenv, fetchsvn, python }:

stdenv.mkDerivation rec {
  name = "ctemplate-${version}";

  version = "2.2";

  src = fetchsvn {
    url = "http://ctemplate.googlecode.com/svn/tags/${name}";
    sha256 = "0n1skfkr3sw22dvgaxg5chfn8rdmz94l23l10hfigqx8n62aw9ln";
  };

  buildInputs = [ python ];

  postPatch = ''
    patchShebangs .
  '';

  meta = {
    description = "A simple but powerful template language for C++";
    longDescription = ''
      CTemplate is a simple but powerful template language for C++. It
      emphasizes separating logic from presentation: it is impossible to
      embed application logic in this template language.
    '';
    homepage = http://code.google.com/p/google-ctemplate/;
    license = "bsd";
  };
}
