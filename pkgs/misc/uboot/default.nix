{ stdenv, buildPackages, fetchurl, bc, dtc, python2
, hostPlatform
}:

let
  buildUBoot = { targetPlatforms
               , filesToInstall
               , installDir ? "$out"
               , defconfig
               , extraMeta ? {}
               , otherConfig ? ""
               , ... } @ args:
            stdenv.mkDerivation (rec {

    name = "uboot-${defconfig}-${version}";
    version = "2017.09";

    src = fetchurl {
      url = "ftp://ftp.denx.de/pub/u-boot/u-boot-${version}.tar.bz2";
      sha256 = "0i4p12ar0zgyxs8hiqgp6p6shvbw4ikkvryd4mh70bppyln5zldj";
    };

    nativeBuildInputs = [ buildPackages.stdenv.cc buildPackages.openssl bc dtc python2 ];

    buildInputs = nativeBuildInputs;

    hardeningDisable = [ "all" ];

    postPatch = ''
      patchShebangs tools
    '';

    configurePhase = ''
      make $makeFlags ${defconfig}
      # Apply otherConfig
      echo "${otherConfig}" >> .config
      make $makeFlags oldconfig
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p ${installDir}
      cp ${stdenv.lib.concatStringsSep " " filesToInstall} ${installDir}

      runHook postInstall
    '';

    enableParallelBuilding = true;
    dontStrip = true;

    makeFlags = stdenv.lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform)
      [
        "CROSS_COMPILE=${stdenv.cc.prefix}"
        "HOSTCC=${buildPackages.stdenv.cc.prefix}gcc"
        "HOSTCFLAGS+=-I${stdenv.lib.getDev buildPackages.openssl}/include"
        "HOSTLDFLAGS+=-L${stdenv.lib.getLib buildPackages.openssl}/lib"
      ];

    meta = with stdenv.lib; {
      homepage = http://www.denx.de/wiki/U-Boot/;
      description = "Boot loader for embedded systems";
      license = licenses.gpl2;
      maintainers = [ maintainers.dezgeg ];
      platforms = targetPlatforms;
    } // extraMeta;
  } // args);

in rec {
  inherit buildUBoot;

  ubootTools = buildUBoot rec {
    defconfig = "allnoconfig";
    # This is necessary otherwise the build fails with undefined symbols at link-time.
    # This is likely a bug in u-boot.
    otherConfig = ''
      CONFIG_FIT=y
      CONFIG_FIT_SIGNATURE=y
      CONFIG_FIT_ENABLE_SHA256_SUPPORT=y
      CONFIG_FIT_VERBOSE=y
      CONFIG_FIT_BEST_MATCH=y
      CONFIG_SPL_RSA=y
    '';
    installDir = "$out/bin";
    buildFlags = "tools NO_SDL=1";
    dontStrip = false;
    targetPlatforms = stdenv.lib.platforms.linux;
    filesToInstall = ["tools/dumpimage" "tools/mkenvimage" "tools/mkimage"];
  };

  ubootA20OlinuxinoLime = buildUBoot rec {
    defconfig = "A20-OLinuXino-Lime_defconfig";
    targetPlatforms = ["armv7l-linux"];
    filesToInstall = ["u-boot-sunxi-with-spl.bin"];
  };

  ubootBananaPi = buildUBoot rec {
    defconfig = "Bananapi_defconfig";
    targetPlatforms = ["armv7l-linux"];
    filesToInstall = ["u-boot-sunxi-with-spl.bin"];
  };

  ubootBeagleboneBlack = buildUBoot rec {
    defconfig = "am335x_boneblack_defconfig";
    targetPlatforms = ["armv7l-linux"];
    filesToInstall = ["MLO" "u-boot.img"];
  };

  ubootJetsonTK1 = buildUBoot rec {
    defconfig = "jetson-tk1_defconfig";
    targetPlatforms = ["armv7l-linux"];
    filesToInstall = ["u-boot" "u-boot.dtb" "u-boot-dtb-tegra.bin" "u-boot-nodtb-tegra.bin"];
  };

  ubootOdroidXU3 = buildUBoot rec {
    defconfig = "odroid-xu3_defconfig";
    targetPlatforms = ["armv7l-linux"];
    filesToInstall = ["u-boot-dtb.bin"];
  };

  ubootPcduino3Nano = buildUBoot rec {
    defconfig = "Linksprite_pcDuino3_Nano_defconfig";
    targetPlatforms = ["armv7l-linux"];
    filesToInstall = ["u-boot-sunxi-with-spl.bin"];
  };

  ubootRaspberryPi = buildUBoot rec {
    defconfig = "rpi_defconfig";
    targetPlatforms = ["armv6l-linux"];
    filesToInstall = ["u-boot.bin"];
  };

  ubootRaspberryPi2 = buildUBoot rec {
    defconfig = "rpi_2_defconfig";
    targetPlatforms = ["armv7l-linux"];
    filesToInstall = ["u-boot.bin"];
  };

  ubootRaspberryPi3_32bit = buildUBoot rec {
    defconfig = "rpi_3_32b_defconfig";
    targetPlatforms = ["armv7l-linux"];
    filesToInstall = ["u-boot.bin"];
  };

  ubootRaspberryPi3_64bit = buildUBoot rec {
    defconfig = "rpi_3_defconfig";
    targetPlatforms = ["aarch64-linux"];
    filesToInstall = ["u-boot.bin"];
  };

  ubootUtilite = buildUBoot rec {
    defconfig = "cm_fx6_defconfig";
    targetPlatforms = ["armv7l-linux"];
    filesToInstall = ["u-boot-with-nand-spl.imx"];
    buildFlags = "u-boot-with-nand-spl.imx";
    postConfigure = ''
      cat >> .config << EOF
      CONFIG_CMD_SETEXPR=y
      EOF
    '';
    # sata init; load sata 0 $loadaddr u-boot-with-nand-spl.imx
    # sf probe; sf update $loadaddr 0 80000
  };

  ubootWandboard = buildUBoot rec {
    defconfig = "wandboard_defconfig";
    targetPlatforms = ["armv7l-linux"];
    filesToInstall = ["u-boot.img" "SPL"];
  };

  ubootMicrozed = buildUBoot rec {
    defconfig = "zynq_microzed_defconfig";
    #targetPlatforms = ["armv7l-linux"];
    targetPlatforms = ["armv7l-linux"];
    filesToInstall = ["u-boot.bin"];
  };
}
