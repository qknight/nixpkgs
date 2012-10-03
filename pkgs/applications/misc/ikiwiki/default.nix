{ stdenv, fetchurl, perl, gettext, makeWrapper, PerlMagick, YAML
, TextMarkdown, URI, HTMLParser, HTMLScrubber, HTMLTemplate, TimeDate
, CGISession, CGIFormBuilder, DBFile, LocaleGettext, RpcXML, XMLSimple
, YAMLLibYAML, which, HTMLTree, python, docutils
, gitSupport ? false, git ? null
, monotoneSupport ? false, monotone ? null
, bazaarSupport ? false, bazaar ? null
, cvsSupport ? false, cvs ? null, cvsps ? null, Filechdir ? null
, subversionSupport ? false, subversion ? null
, mercurialSupport ? false, mercurial ? null
, extraUtils ? []
}:

assert gitSupport -> (git != null);
assert monotoneSupport -> (monotone != null);
assert bazaarSupport -> (bazaar != null);
assert cvsSupport -> (cvs != null && cvsps != null && Filechdir != null);
assert subversionSupport -> (subversion != null);
assert mercurialSupport -> (mercurial != null);

let
  name = "ikiwiki";
  version = "3.20120725";

  lib = stdenv.lib;
in
stdenv.mkDerivation {
  name = "${name}-${version}";

  src = fetchurl {
    url = "http://ftp.de.debian.org/debian/pool/main/i/ikiwiki/${name}_${version}.tar.gz";
    sha256 = "b600096a77b17e4a9e8a9552c4d36e01ed9217a0f8ff8a4f15110cf80e7adfad";
  };

  buildInputs = [ perl TextMarkdown URI HTMLParser HTMLScrubber HTMLTemplate
    TimeDate gettext makeWrapper DBFile CGISession CGIFormBuilder LocaleGettext
    RpcXML XMLSimple PerlMagick YAML YAMLLibYAML which HTMLTree python docutils ] 
    ++ lib.optionals gitSupport [git]
    ++ lib.optionals monotoneSupport [monotone]
    ++ lib.optionals bazaarSupport [bazaar]
    ++ lib.optionals cvsSupport [cvs cvsps Filechdir]
    ++ lib.optionals subversionSupport [subversion]
    ++ lib.optionals mercurialSupport [mercurial];

  patchPhase = ''
    sed -i s@/usr/bin/perl@${perl}/bin/perl@ pm_filter mdwn2man
    sed -i s@/etc/ikiwiki@$out/etc@ Makefile.PL
    sed -i /ENV{PATH}/d ikiwiki.in
    # State the gcc dependency, and make the cgi use our wrapper
    sed -i -e 's@$0@"'$out/bin/ikiwiki'"@' \
        -e "s@'cc'@'${stdenv.gcc}/bin/gcc'@" IkiWiki/Wrapper.pm
    # fixing python support in the rst plugin
    sed -i s@/usr/bin/env\ python@${python}/bin/python@ plugins/rst
    # fixing lib/ikiwiki/plugins/proxy.py:#!/usr/bin/python
    sed -i s@/usr/bin/python@${python}/bin/python@ plugins/proxy.py
  '';

  configurePhase = "perl Makefile.PL PREFIX=$out";

  postInstall = ''
    for a in "$out/bin/"*; do
      wrapProgram $a --suffix PERL5LIB : $PERL5LIB --prefix PATH : ${perl}/bin:$out/bin \
      ${lib.optionalString gitSupport ''--prefix PATH : ${git}/bin \''}
      ${lib.optionalString monotoneSupport ''--prefix PATH : ${monotone}/bin \''}
      ${lib.optionalString bazaarSupport ''--prefix PATH : ${bazaar}/bin \''}
      ${lib.optionalString cvsSupport ''--prefix PATH : ${cvs}/bin \''}
      ${lib.optionalString cvsSupport ''--prefix PATH : ${cvsps}/bin \''}
      ${lib.optionalString subversionSupport ''--prefix PATH : ${subversion}/bin \''}
      ${lib.optionalString mercurialSupport ''--prefix PATH : ${mercurial}/bin \''}
      ${lib.concatMapStrings (x: "--prefix PATH : ${x}/bin ") extraUtils}
    done
  '';

  checkTarget = "test";
  doCheck = true;

  meta = {
    description = "Wiki compiler, storing pages and history in a RCS";
    homepage = "http://ikiwiki.info/";
    license = "GPLv2+";

    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.simons ];
  };
}
