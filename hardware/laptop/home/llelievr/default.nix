{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  modules = ../../../../home-modules;
  mpvOptsAC      = "loop-playlist --shuffle --panscan=1.0 --video-unscaled=no --image-display-duration=300 --loop-file=yes --length=300 --hwdec=auto --vo=gpu --fps=24 --no-audio";
  mpvOptsBattery = "--pause --panscan=1.0 --video-unscaled=no --no-audio";

  # Launched once per monitor at startup.
  # Polls every 5s: starts mpvpaper when monitor appears, stops it when it disappears,
  # restarts it when scale or AC state changes.
  mpvpaper-watch = pkgs.writeShellScript "mpvpaper-watch" ''
    MON="$1"

    is_on_ac() {
      for path in /sys/class/power_supply/AC/online /sys/class/power_supply/ACAD/online; do
        [ -f "$path" ] && { cat "$path"; return; }
      done
      echo "1"
    }

    get_scale() {
      ${pkgs.hyprland}/bin/hyprctl monitors -j \
        | ${pkgs.jq}/bin/jq -r ".[] | select(.name == \"$MON\") | .scale | tostring"
    }

    launch() {
      pkill -f "mpvpaper $MON" || true
      sleep 0.1
      if [ "$(is_on_ac)" = "1" ]; then
        ${pkgs.mpvpaper}/bin/mpvpaper "$MON" -o "${mpvOptsAC}" "$HOME/Pictures/Wallpapers" &
      else
        ${pkgs.mpvpaper}/bin/mpvpaper "$MON" -o "${mpvOptsBattery}" "$HOME/Pictures/Wallpapers" &
      fi
    }

    prev_ac=""
    prev_scale=""
    running=false

    while true; do
      curr_scale=$(get_scale)

      if [ -n "$curr_scale" ]; then
        curr_ac=$(is_on_ac)
        if [ "$running" = "false" ] || [ "$curr_ac" != "$prev_ac" ] || [ "$curr_scale" != "$prev_scale" ]; then
          prev_ac="$curr_ac"
          prev_scale="$curr_scale"
          running=true
          launch
        fi
      else
        if [ "$running" = "true" ]; then
          pkill -f "mpvpaper $MON" || true
          running=false
          prev_scale=""
        fi
      fi

      sleep 1
    done
  '';

  # Only responsible for eDP-1 scale/position based on connected monitors.
  monitor-scale-sync = pkgs.writeShellScript "monitor-scale-sync" ''
    apply() {
      if ${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -e 'any(.[]; .name == "DP-5" or .name == "DP-6")' > /dev/null; then
        ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1, 2560x1600@165, -1600x940, 1.6"
        ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-5, 2560x1440@60, 0x0, 1"
        ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-6, 2560x1440@60, 0x1440, 1"
      else
        ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1, 2560x1600@165, 0x0, 1"
      fi
    }

    apply

    DEBOUNCE_PID=""
    ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock \
      | while read -r line; do
          case "$line" in
            monitoradded*)
              kill "$DEBOUNCE_PID" 2>/dev/null
              (sleep 0.2 && apply) &
              DEBOUNCE_PID=$!
              ;;
            monitorremoved*)
              kill "$DEBOUNCE_PID" 2>/dev/null
              (sleep 0.2 && apply) &
              DEBOUNCE_PID=$!
              ;;
          esac
        done
    
  '';
in
{
  imports = [
    (modules + /commons.nix)
    (modules + /shell.nix)
    # (modules + /niri)
    (modules + /hyprland)
  ];

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "eDP-1, 2560x1600@165, 0x0, 1.6"
      "DP-5, 2560x1440@60, 2560x0, 1"
      "DP-6, 2560x1440@60, 2560x1440, 1"
    ];

    workspace = [
      "8, monitor:eDP-1"
      "9, monitor:eDP-1"
    ];

    exec-once = [
      "${mpvpaper-watch} eDP-1"
      "${mpvpaper-watch} DP-5"
      "${mpvpaper-watch} DP-6"
      "${monitor-scale-sync}"
      "easyeffect"
    ];
  };

  home.username = "llelievr";
  home.homeDirectory = "/home/llelievr";

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
