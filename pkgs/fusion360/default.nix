{
  stdenv,
  lib,
  pkgs,
  wine,
  wineArch,
  mkWindowsApp,
  fetchurl,
  makeWrapper,
  ...
}:
let
  version = "0.0.0";
in
mkWindowsApp rec {
  inherit version wine wineArch;
  pname = "fusion360";

  enableVulkan = true;
  graphicsDriverCmd = true;

  # src = fetchurl {
  #   url = "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe";
  #   sha256 = "xn2cauJw57mayQuGIjwBN8+IciwEACwtdw4rQsfB0Co=";
  # };

  # webview = fetchurl {
  #   url = "https://github.com/aedancullen/webview2-evergreen-standalone-installer-archive/releases/download/109.0.1518.78/MicrosoftEdgeWebView2RuntimeInstallerX64.exe";
  #   sha256 = "8sxJhj4iFALUZk2fqUSkfyJUPaLcs2NDjD5Zh4m5/Vs=";
  # };

  nativeBuildInputs = with pkgs; [
    p7zip
  ];

  winAppInstall = ''
    winetricks -q sandbox
    sleep 5s
    # We must install some packages!
    winetricks -q atmlib gdiplus arial corefonts cjkfonts dotnet452 msxml4 msxml6 vcrun2017 fontsmooth=rgb winhttp win10
    # We must install cjkfonts again then sometimes it doesn't work in the first time!
    sleep 5s
    winetricks -q cjkfonts
    # We must set to Windows 10 or 11 again because some other winetricks sometimes set it back to Windows XP!
    sleep 5s
    winetricks -q win11
    sleep 5s
    wine REG ADD "HKCU\Software\Wine\DllOverrides" /v "adpclientservice.exe" /t REG_SZ /d "" /f
    # Navigation bar does not work well with anything other than the wine builtin DX9
    wine REG ADD "HKCU\Software\Wine\DllOverrides" /v "AdCefWebBrowser.exe" /t REG_SZ /d builtin /f
    # Use Visual Studio Redist that is bundled with the application
    wine REG ADD "HKCU\Software\Wine\DllOverrides" /v "msvcp140" /t REG_SZ /d native /f
    wine REG ADD "HKCU\Software\Wine\DllOverrides" /v "mfc140u" /t REG_SZ /d native /f
    # Fixed the problem with the bcp47langs issue and now the login works again!
    wine reg add "HKCU\Software\Wine\DllOverrides" /v "bcp47langs" /t REG_SZ /d "" /f
    sleep 5s

    mkdir -p $WINEPREFIX/drive_c/users/$USER/Downloads
    WORK_DIR=$WINEPREFIX/drive_c/users/$USER/Downloads
    echo $WORK_DIR
    cd $WORK_DIR
    7za e -y ${./resources/Qt6WebEngineCore.dll.7z} -o"./"
    QT6_WEBENGINECORE=$(find "$WINEPREFIX" -name 'Qt6WebEngineCore.dll' -printf "%T+ %p\n" | sort -r | head -n 1 | sed -r 's/^[^ ]+ //')
    QT6_WEBENGINECORE_DIR=$(dirname "$QT6_WEBENGINECORE")
    ls $QT6_WEBENGINECORE_DIR

    cp -f ${./resources/DXVK.reg} ./DXVK.reg
    cp -f ${./resources/MicrosoftEdgeWebView2RuntimeInstallerX64.exe} ./MicrosoftEdgeWebView2RuntimeInstallerX64.exe
    cp -f ${./resources/FusionInstaller.exe} ./FusionInstaller.exe
    ls $WORK_DIR
    wine ./MicrosoftEdgeWebView2RuntimeInstallerX64.exe /silent /install
    winetricks -q dxvk
    wine regedit.exe DXVK.reg
    wine ./FusionInstaller.exe 
    cp -f "./Qt6WebEngineCore.dll" "$QT6_WEBENGINECORE_DIR/Qt6WebEngineCore.dll"
    cp -f ${./resources/siappdll.dll} "$QT6_WEBENGINECORE_DIR/siappdll.dll"
    wineserver -w
    rm -rf $WORK_DIR
  '';

  winAppRun = ''
    wine start /unix "$WINEPREFIX/drive_c/Program Files/Notepad++/notepad++.exe" "$ARGS"
  '';

  installPhase = ''
    runHook preInstall
    ln -s $out/bin/.launcher $out/bin/fusion360
    runHook postInstall
  '';

  meta = with lib; {
    description = "Fusion 360";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
