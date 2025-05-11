{
  pkgs,
  stdenv,
  inputs,
  lib,
  ...
}:
let
  installer = pkgs.fetchurl {
    url = "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe";
    name = "FusionInstaller.exe";
    sha256 = "xn2cauJw57mayQuGIjwBN8+IciwEACwtdw4rQsfB0Co=";
  };

  webview = pkgs.fetchurl {
    url = "https://github.com/aedancullen/webview2-evergreen-standalone-installer-archive/releases/download/109.0.1518.78/MicrosoftEdgeWebView2RuntimeInstallerX64.exe";
    name = "EdgeInstaller.exe";
    sha256 = "8sxJhj4iFALUZk2fqUSkfyJUPaLcs2NDjD5Zh4m5/Vs=";
  };

  xml = pkgs.writeText "NMachineSpecificOptions.xml" ''
    <?xml version="1.0" encoding="UTF-16" standalone="no" ?>
    <OptionGroups>
      <BootstrapOptionsGroup SchemaVersion="2" ToolTip="Special preferences that require the application to be restarted after a change." UserName="Bootstrap">
        <driverOptionId ToolTip="The driver used to display the graphics" UserName="Graphics driver" Value="VirtualDeviceDx9"/></BootstrapOptionsGroup>
    </OptionGroups>
  '';

  WINEPREFIX = "$HOME/Fusion360";

  pname = "fusion360";
  version = "1.0.0";

  tricksFmt = builtins.concatStringsSep " " [
    "atmlib"
    "gdiplus"
    "arial"
    "corefonts"
    "cjkfonts"
    "dotnet452"
    "msxml4"
    "msxml6"
    "vcrun2017"
    "fontsmooth=rgb"
    "winhttp"
    "win10"
    "dxvk"
  ];

  fetchurl = args@{ url, sha256, ... }: pkgs.fetchurl { inherit url sha256; } // args;

  # wineProton = stdenv.mkDerivation rec {
  #   pname = "wine-cafe-custom";
  #   version = "wine-cafe";

  #   src = pkgs.fetchurl {
  #     url = "https://github.com/bottlesdevs/wine/releases/download/caffe-9.7/caffe-9.7-x86_64.tar.xz";
  #     sha256 = "sha256-qDdRBbQ5IDU2VoBY6I/AfkXsgyPjoHKQG8nnY8IgAC4=";
  #   };

  #   installPhase = ''
  #     mkdir -p $out
  #     mv * $out/
  #   '';

  #   meta.platforms = lib.platforms.linux;
  # };
  wine = pkgs.wine.overrideAttrs (old: {
    name = "wine-4.0.2";
    patches = [ ];
    src = fetchurl rec {

      version = "4.0.2";
      url = "https://dl.winehq.org/wine/source/4.0/wine-${version}.tar.xz";
      sha256 = "0x5x9pvhryzhq1m7i8gx5wwwj341zz05zymadlhfw5w45xlm0h4r";

      ## see http://wiki.winehq.org/Gecko
      gecko32 = fetchurl rec {
        version = "2.47";
        url = "http://dl.winehq.org/wine/wine-gecko/${version}/wine_gecko-${version}-x86.msi";
        sha256 = "0fk4fwb4ym8xn0i5jv5r5y198jbpka24xmxgr8hjv5b3blgkd2iv";
      };
      gecko64 = fetchurl rec {
        version = "2.47";
        url = "http://dl.winehq.org/wine/wine-gecko/${version}/wine_gecko-${version}-x86_64.msi";
        sha256 = "0zaagqsji6zaag92fqwlasjs8v9hwjci5c2agn9m7a8fwljylrf5";
      };

      ## see http://wiki.winehq.org/Mono
      mono = fetchurl rec {
        version = "4.9.2";
        url = "http://dl.winehq.org/wine/wine-mono/${version}/wine-mono-${version}.msi";
        sha256 = "0x7z0216j21bzc9v1q283qlsvbfzn92yiaf26ilh6bd7zib4c7xr";
      };

    };
  });
  winetricks = pkgs.winetricks.overrideAttrs (old: {
    patches = [ ./winetricks.patch ];
  });

  script = pkgs.writeShellScriptBin pname ''
    # export WINEARCH="win64"
    export WINEFSYNC=1
    export WINEESYNC=1
    export WINEPREFIX="${WINEPREFIX}"
    # export WINEDLLOVERRIDES="api-ms-win-crt-private-l1-1-0,api-ms-win-crt-conio-l1-1-0,api-ms-win-crt-convert-l1-1-0,api-ms-win-crt-environment-l1-1-0,api-ms-win-crt-filesystem-l1-1-0,api-ms-win-crt-heap-l1-1-0,api-ms-win-crt-locale-l1-1-0,api-ms-win-crt-math-l1-1-0,api-ms-win-crt-multibyte-l1-1-0,api-ms-win-crt-process-l1-1-0,api-ms-win-crt-runtime-l1-1-0,api-ms-win-crt-stdio-l1-1-0,api-ms-win-crt-string-l1-1-0,api-ms-win-crt-utility-l1-1-0,api-ms-win-crt-time-l1-1-0,atl140,concrt140,msvcp140,msvcp140_1,msvcp140_atomic_wait,ucrtbase,vcomp140,vccorlib140,vcruntime140,vcruntime140_1=n,b;adpclientservice.exe="
    # export FUSION_IDSDK=false
    USER="$(whoami)"
    export WINE_BIN="${wine}/bin/.wine"
    export WINESERVER_BIN="${wine}/bin/wineserver"
    export PATH=${wine}/bin:${winetricks}/bin:$PATH
    FUSION_LAUNCHER="$WINEPREFIX/drive_c/Users/$USER/Desktop/Autodesk Fusion.lnk"

    # if [ ! -d "$WINEPREFIX" ]; then
      # # create the wine prefix
      # # wine wineboot
      # # echo "Wineboot is done!"
      # # install tricks
      # winetricks -q -f ${tricksFmt}
      # wineserver -w
      # # We must install cjkfonts again then sometimes it doesn't work in the first time!
      # winetricks -q -f cjkfonts
      # # We must set to Windows 10 or 11 again because some other winetricks sometimes set it back to Windows XP!
      # winetricks -q -f win11
      # echo "Winetricks is done!"

      # wine REG ADD "HKCU\Software\Wine\DllOverrides" /v "adpclientservice.exe" /t REG_SZ /d "" /f
      # # Navigation bar does not work well with anything other than the wine builtin DX9
      # wine REG ADD "HKCU\Software\Wine\DllOverrides" /v "AdCefWebBrowser.exe" /t REG_SZ /d builtin /f
      # # Use Visual Studio Redist that is bundled with the application
      # wine REG ADD "HKCU\Software\Wine\DllOverrides" /v "msvcp140" /t REG_SZ /d native /f
      # wine REG ADD "HKCU\Software\Wine\DllOverrides" /v "mfc140u" /t REG_SZ /d native /f
      # # Fixed the problem with the bcp47langs issue and now the login works again!
      # wine reg add "HKCU\Software\Wine\DllOverrides" /v "bcp47langs" /t REG_SZ /d "" /f

      wineserver -k

      curl -L https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/setup/resource/video_driver/dxvk/DXVK.reg -o "$WINEPREFIX/drive_c/users/$USER/Downloads/DXVK.reg"
      wine regedit.exe "$WINEPREFIX/drive_c/users/$USER/Downloads/DXVK.reg"

      # wine ${webview} /install

      wine ${installer}

      mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Autodesk/Neutron Platform/Options"
      cp ${xml} "$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Autodesk/Neutron Platform/Options"

      # Disable Debug messages on regular runs, we dont have a terminal, so speed up the system by not wasting time prining them into the Void
      # sed -i 's/=env WINEPREFIX=/=env WINEDEBUG=-all env WINEPREFIX=/g' "$HOME/.local/share/applications/wine/Programs/Autodesk/Autodesk Fusion.desktop"

      wineserver -w
    # fi

    cd "$WINEPREFIX"

    xdg-mime default adskidmgr-opener.desktop x-scheme-handler/adskidmgr

    wine "$FUSION_LAUNCHER" "$@"
    wineserver -w
  '';
in
stdenv.mkDerivation rec {
  inherit version pname;

  dontUnpack = true;

  src = installer;

  nativeBuildInputs = [
    pkgs.copyDesktopItems
  ];

  desktopItems = [
    (pkgs.makeDesktopItem {
      desktopName = "adskidmgr-opener.desktop";
      name = "adskidmgr Scheme Handler";
      exec = ''env WINEPREFIX="\\$HOME/Fusion360" wine "C:\users\$USER\AppData\Local\Autodesk\webdeploy\production\57cd45aa09be2d79663784069561ec17eda99ca8\Autodesk Identity Manager\AdskIdentityManager.exe" %u'';
      mimeTypes = [ "x-scheme-handler/adskidmgr" ];
    })
  ];

  installPhase = ''
    mkdir -p $out/share/applications
    copyDesktopItems

    install -D ${script}/bin/fusion360 $out/bin/fusion360
  '';

  meta = {
    description = "Autodesk Fusion 360";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
