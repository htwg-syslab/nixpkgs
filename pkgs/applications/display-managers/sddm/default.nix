{ mkDerivation, lib, copyPathsToStore, fetchFromGitHub, fetchpatch
, cmake, extra-cmake-modules, pkgconfig, libxcb, libpthreadstubs, lndir
, libXdmcp, libXau, qtbase, qtdeclarative, qttools, pam, systemd
}:

let

  version = "0.15.0";

in mkDerivation rec {
  name = "sddm-${version}";

  src = fetchFromGitHub {
    owner = "sddm";
    repo = "sddm";
    rev = "v${version}";
    sha256 = "1wissgl7wd7fblq8ghz8n2fr6wqip7h88p9fiarfpvi1918fgng8";
  };

  patches =
    copyPathsToStore (lib.readPathsFromFile ./. ./series);

  postPatch =
    # Module Qt5::Test must be included in `find_package` before it is used.
    ''
      sed -i CMakeLists.txt -e '/find_package(Qt5/ s|)| Test)|'
    '';

  nativeBuildInputs = [ cmake extra-cmake-modules pkgconfig qttools ];

  buildInputs = [
    libxcb libpthreadstubs libXdmcp libXau pam qtbase qtdeclarative systemd
  ];

  cmakeFlags = [
    "-DCONFIG_FILE=/etc/sddm.conf"
    # Set UID_MIN and UID_MAX so that the build script won't try
    # to read them from /etc/login.defs (fails in chroot).
    # The values come from NixOS; they may not be appropriate
    # for running SDDM outside NixOS, but that configuration is
    # not supported anyway.
    "-DUID_MIN=1000"
    "-DUID_MAX=29999"
  ];

  preConfigure = ''
    export cmakeFlags="$cmakeFlags -DQT_IMPORTS_DIR=$out/$qtQmlPrefix -DCMAKE_INSTALL_SYSCONFDIR=$out/etc -DSYSTEMD_SYSTEM_UNIT_DIR=$out/lib/systemd/system"
  '';

  postInstall = ''
    # remove empty scripts
    rm "$out/share/sddm/scripts/Xsetup" "$out/share/sddm/scripts/Xstop"
  '';

  meta = with lib; {
    description = "QML based X11 display manager";
    homepage = https://github.com/sddm/sddm;
    platforms = platforms.linux;
    maintainers = with maintainers; [ abbradar ttuegel ];
  };
}
