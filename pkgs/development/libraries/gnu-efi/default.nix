{ stdenv, fetchurl, pciutils }: with stdenv.lib;

stdenv.mkDerivation rec {
  name = "gnu-efi-${version}";
  version = "3.0.5";

  src = fetchurl {
    url = "mirror://sourceforge/gnu-efi/${name}.tar.bz2";
    sha256 = "08hb2gpzcj5p743wcagm0j2m4gh100xv12llpbjc13zi2icwv3xx";
  };

  buildInputs = [ pciutils ];

  hardeningDisable = [ "stackprotector" ];

  makeFlags = [
    "PREFIX=\${out}"
    "CC=${stdenv.cc.prefix}gcc"
    "AS=${stdenv.cc.prefix}as"
    "LD=${stdenv.cc.prefix}ld"
    "AR=${stdenv.cc.prefix}ar"
    "RANLIB=${stdenv.cc.prefix}ranlib"
    "OBJCOPY=${stdenv.cc.prefix}objcopy"
  ] ++ stdenv.lib.optional stdenv.isArm "ARCH=arm";

  meta = with stdenv.lib; {
    description = "GNU EFI development toolchain";
    homepage = https://sourceforge.net/projects/gnu-efi/;
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
