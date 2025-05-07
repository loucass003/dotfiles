{
  stdenv,
  lib,
  makeWrapper,
  fetchFromGitHub,
}:
let
  version = "0.0.0";
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "fusion360";

  src = fetchFromGitHub {
    owner = "cryinkfly";
    repo = "Autodesk-Fusion-360-for-Linux";
    rev = "86e389acc349ff9dadc26a20aee32e162d49e5d3";
    sha256 = "f6uypZGpzP1J2qM1L1VJomvO0tQOR2E/lsmDvDIccSg=";
  };

  isLibrary = false;
  isExecutable = true;

  nativeBuildInputs = [
    gawk
    cabextract
    coreutils
    curl
    lsb_release
    mesa-utils
    p7zip
    polkit
    samba
    spacenavd
    wget
    winbind
    xdg_utils
    bc
    xrandr
  ];

  installPhase = ''
    systemctl enable spacenavd
    systemctl start spacenavd
    ./autodesk_fusion_installer_x86-64.sh --install --default --full
  '';

  meta = with lib; {
    description = "Fusion 360";
    platforms = platforms.linux;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
