#!/bin/bash

BYPASS=false
NO_RESTART=true
ONLY_THIS=

usage () {
  echo "apply.sh [-h] [-c TYPE] [-y]";
  echo "  -h  Show this help";
  echo "  -c  Select package to apply the desired config, e.g. -c rofi";
  echo "  -b  Bypass confirmation";
  echo "  -r  Restart the i3 instance after the apply process"
}

log_ () {
  echo "[saek's dots] $1"
}

log_err () {
  echo -e "\033[34m[saek's dots] error :: $1\033[0m";
  exit 1
}

log_warn () {
  echo -e "\033[35m[saek's dots] warn :: $1\033[0m";
}

log_pause () {
  if [ "$ONLY_THIS" ]; then
    log_warn "you selected: $ONLY_THIS"
  fi

  if [ $BYPASS != true ]; then
    log_warn "you're about to apply these dotfiles into your user folder, backup your config to avoid conflicts.";
    log_warn "press any key continue, or CTRL + C to cancel.";
    read -n 1 -s -r -p "";
  fi
}

i3restart () {
  if [ $NO_RESTART != true ]; then
    log_ "restarting i3...";
    i3-msg restart;
  fi
}

apply_config () {
  if [ "$ONLY_THIS" ]; then
    if [ ! "$3" = "$ONLY_THIS" ]; then return; fi
  fi
  log_ "applying config :: $2..."
  cp .config/$1 /home/$WHO/.config/$1
}

apply_script () {
  log_ "applying script :: $2..."
  cp .scripts/$1 /home/$WHO/.scripts/$1
}

apply_etc () {
  if [ "$ONLY_THIS" ]; then
    if [ ! "$4" = "$ONLY_THIS" ]; then return; fi
  fi
  log_ "applying etc file :: $3..."
  cp .etc/$1 /etc/$2
}

while getopts ":hbrc:" opt; do
  case $opt in 
    h) usage; exit ;;
    b) BYPASS=true ;;
    r) NO_RESTART=false ;;
    c) ONLY_THIS=${OPTARG} ;;
    :) log_err "missing argument for option -$OPTARG" ;;
    \?) log_err "unknown option -$OPTARG" ;;
  esac
done

WHO="$(logname)"
log_ "this is @$WHO"

[ "$UID" -eq 0 ] || log_err "you must start this script with sudo"

log_pause

log_ "copying assets..."

cp bg.jpg /home/$WHO/bg_.jpg
cp pyro.png /home/$WHO/pyro_.png

apply_config polybar/config "polybar - config" polybar
apply_config polybar/launch.sh "polybar - launch script" polybar
apply_config dunst/dunstrc "dunst - config" dunst
apply_config i3/config "i3 - config" i3
apply_config kitty/kitty.conf "kitty - config" kitty
apply_config neofetch/config.conf "neofetch - config" neofetch
apply_config rofi/config.rasi "rofi - config" rofi
apply_config rofi/power.rasi "rofi - power menu theme" rofi

apply_script lock.sh "lock screen"
apply_script spotify_status.py "spotify status"

apply_etc picom.conf "xdg/picom.conf" "picom - config" picom

i3restart
log_ "finished!"
exit 0
