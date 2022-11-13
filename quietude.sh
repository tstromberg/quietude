#!/bin/sh
# 
# Quietude - a distraction-free Android experience
#
# Usage:
#    ./quietude.sh disable distractions
#

readonly BLOAT="
com.android.musicfx
com.google.android.apps.nbu.files
com.google.android.apps.recorder
com.google.android.apps.tips
com.google.android.apps.wellbeing
com.google.android.apps.youtube.music
com.verizon.llkagent
com.verizon.mips.services
com.verizon.services
"

readonly STORE="com.android.vending"
readonly GMAIL="com.google.android.gm"
readonly MAPS="com.google.android.apps.maps"

readonly DISTRACTIONS="
com.android.chrome
com.google.android.apps.docs
com.google.android.apps.docs.editors.docs
com.google.android.googlequicksearchbox
com.google.android.googlequicksearchbox.nga_resources
com.google.android.youtube
"

# Convenience for an extra path one might happen to have 'adb' installed.
export PATH=$PATH:$HOME/Downloads/platform-tools

# "enable" or "disable"
readonly MODE=$1
shift

function adb_installed() {
   adb version >/dev/null && return

   if [ -x  /opt/homebrew/bin/brew ]; then
     echo "Installing adb via homebrew ..."
     brew install android-platform-tools
     return
   fi

   if [ -x /usr/bin/apt ]; then
    echo "Installing adb via apt ..."
    sudo apt-get install android-tools-adb
    return
   fi

   echo "Please install adb: https://developer.android.com/studio/releases/platform-tools"
   exit 1
}

function adb_connected() {
  devices=$(adb devices -l | egrep -v "^List of devices|^\$")
  echo "adb devices found:\n${devices}\n"

  if [ "${devices}" = "" ]; then
    echo "Phone not found. Connect a USB cable and enable USB debugging: https://developer.android.com/studio/command-line/adb"
    exit 1
  fi
}


list=""
while [[ $# -gt 0 ]]; do
  case $1 in
    all)
      list="${BLOAT} ${DISTRACTIONS} ${MAPS} ${STORE} ${GMAIL}"
      ;;
    bloat)
      list="${list} ${BLOAT}"
      ;;  
    distractions)
      list="${list} ${DISTRACTIONS}"
      ;;
    maps)
      list="${list} ${MAPS}"
      ;;
    store)
      list="${list} ${STORE}"
      ;;
    gmail)
      list="${list} ${GMAIL}"
      ;;
    *)
      echo "unknown group: $1"
      exit 1
  esac
  shift
done

items="$(echo $list | sort -u | grep '\.'| xargs | sed s/' '/'\$\|\^'/g)"
APP_RE="^${items}$"
echo "${MODE} regexp: ${APP_RE}"
echo ""

case "${MODE}" in
  enable)
    adb_installed || exit 1
    adb_connected || exit 1
    echo "Listing enabled packages matching ${APP_RE} ..."
    echo ""
    matched=0

    for pkg in $(adb shell pm list packages -u | sed s/package://g | egrep "${APP_RE}"); do
      matched=$(($matched + 1))
      echo "= ${pkg}"
      adb shell pm enable --user 0 $pkg 2>/dev/null
      adb shell cmd package install-existing --user 0 $pkg 2>/dev/null
      echo ""
    done

    echo "${matched} packages enabled"
    ;;
  disable)
    adb_installed || exit 1
    adb_connected || exit 1
    echo "Listing packages matching ${APP_RE} ..."
    echo ""
    matched=0
    
    for pkg in $(adb shell pm list packages | sed s/package://g | egrep "${APP_RE}"); do
      matched=$(($matched + 1))
      echo "= ${pkg}"
      adb shell pm disable-user --user 0 $pkg 2>/dev/null
      adb shell pm uninstall --user 0 $pkg 2>/dev/null
      echo ""
    done

    echo "${matched} packages disabled"

    ;;
  *)
    echo "unknown mode: ${MODE}"
    exit 1
esac
