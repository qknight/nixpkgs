{ stdenv, fetchFromGitHub, emscriptenfastcomp, python, nodejs, closurecompiler, pkgs
, jre, binaryen, enableWasm ? true ,  python2Packages, cmake
}:

let
  rev = "1.37.36";
  appdir = "share/emscripten";
in

stdenv.mkDerivation {
  name = "emscripten-${rev}";

  src = fetchFromGitHub {
    owner = "kripken";
    repo = "emscripten";
    sha256 = "02p0cp86vd1mydlpq544xbydggpnrq9dhbxx7h08j235frjm5cdc";
    inherit rev;
  };

  buildInputs = [ nodejs cmake python ];

  buildCommand = ''
    mkdir -p $out/${appdir}
    cp -r $src/* $out/${appdir}
    chmod -R +w $out/${appdir}
    grep -rl '^#!/usr.*python' $out/${appdir} | xargs sed -i -s 's@^#!/usr.*python.*@#!${python}/bin/python@'
    sed -i -e "s,EM_CONFIG = '~/.emscripten',EM_CONFIG = '$out/${appdir}/config'," $out/${appdir}/tools/shared.py
    sed -i -e 's,^.*did not see a source tree above the LLVM.*$,      return True,' $out/${appdir}/tools/shared.py
    sed -i -e 's,def check_sanity(force=False):,def check_sanity(force=False):\n  return,' $out/${appdir}/tools/shared.py
    # fixes cmake support
    sed -i -e "s/print \('emcc (Emscript.*\)/sys.stderr.write(\1); sys.stderr.flush()/g" $out/${appdir}/emcc.py
    mkdir $out/bin
    ln -s $out/${appdir}/{em++,em-config,emar,embuilder.py,emcc,emcmake,emconfigure,emlink.py,emmake,emranlib,emrun,emscons} $out/bin

    echo "EMSCRIPTEN_ROOT = '$out/${appdir}'" > $out/${appdir}/config
    echo "LLVM_ROOT = '${emscriptenfastcomp}/bin'" >> $out/${appdir}/config
    echo "PYTHON = '${python}/bin/python'" >> $out/${appdir}/config
    echo "NODE_JS = '${nodejs}/bin/node'" >> $out/${appdir}/config
    echo "JS_ENGINES = [NODE_JS]" >> $out/${appdir}/config
    echo "COMPILER_ENGINE = NODE_JS" >> $out/${appdir}/config
    echo "CLOSURE_COMPILER = '${closurecompiler}/share/java/closure-compiler-v${closurecompiler.version}.jar'" >> $out/${appdir}/config
    echo "JAVA = '${jre}/bin/java'" >> $out/${appdir}/config
  ''
  + stdenv.lib.optionalString enableWasm ''
    echo "BINARYEN_ROOT = '${binaryen}'" >> $out/share/emscripten/config

    echo "--------------- running test -----------------"
    HOME=$TMPDIR
    cp $out/${appdir}/config $HOME/.emscripten
    echo "SPIDERMONKEY_ENGINE = []" >> $HOME/.emscripten
    cat $HOME/.emscripten
    export PATH=$PATH:$out/bin

    #export EMCC_DEBUG=2  
    ${python}/bin/python $src/tests/runner.py test_hello_world
    echo "--------------- running test -----------------"
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/kripken/emscripten;
    description = "An LLVM-to-JavaScript Compiler";
    platforms = platforms.all;
    maintainers = with maintainers; [ qknight matthewbauer ];
    license = licenses.ncsa;
  };
}
