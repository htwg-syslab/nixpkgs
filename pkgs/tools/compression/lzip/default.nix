{ stdenv, fetchurl, texinfo }:

stdenv.mkDerivation rec {
  name = "lzip-${version}";
  version = "1.19";

  buildInputs = [ texinfo ];

  src = fetchurl {
    url = "mirror://savannah/lzip/${name}.tar.gz";
    sha256 = "1abbch762gv8rjr579q3qyyk6c80plklbv2mw4x0vg71dgsw9bgz";
  };

  # This isn't an autoconf-based configure.
  configureFlags = "CXX=${stdenv.cc.prefix}g++ CPPFLAGS=-DNDEBUG CFLAGS=-O3 CXXFLAGS=-O3";
  configurePlatforms = [];

  doCheck = stdenv.hostPlatform == stdenv.buildPlatform;

  meta = {
    homepage = http://www.nongnu.org/lzip/lzip.html;
    description = "A lossless data compressor based on the LZMA algorithm";
    license = stdenv.lib.licenses.gpl3Plus;
    platforms = stdenv.lib.platforms.unix;
  };
}
