#!/bin/sh
# 
# Distraction-free Android installer
#
# Usage:
#    ./minimal_android_phone.sh disable distractions
#
# This script will disable most sources of distractions on your phone. It requires
# USB debugging (Developer Mode) to be enabled, and is designed to be run right after
# a factory reset. It can also be run at any point afterwards.
#
# Think of it as a "LightPhone"-like experience on a stock-android phone
#
# What's it disable?
#
#   - Google Chrome / Chromium Web Browsers (but not the webview)
#   - Google Play Store
#   - Google Maps
#   - Gmail
#   - Verizon apps
#   - Wellbeing
#   - Audio Recorder
#   - Files
#   - Youtube Music
#   - Youtube
#   - Google Search Box
#   - Google Docs
#
# Recommended post-execution steps:
#
#   - Replace the Android launcher with olauncher
#   - Change your interface language to one you vaguely understand or want to learn more of
#   - Force your screen into monochrome mode (Settings -> Developer -> Simulate color space -> Monochromacy)

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

echo "mode: ${MODE}"
echo "apps: ${APP_RE}"

case "${MODE}" in
  enable)
    for pkg in $(adb shell pm list packages -u | sed s/package://g | egrep "${APP_RE}"); do
      adb shell pm enable --user 0 $pkg
      adb shell cmd package install-existing --user 0 $pkg
    done
    ;;
  disable)
    for pkg in $(adb shell pm list packages | sed s/package://g | egrep "${APP_RE}"); do
      adb shell pm disable-user --user 0 $pkg
      adb shell pm uninstall --user 0 $pkg
    done
    ;;
  *)
    echo "unknown mode: ${MODE}"
    exit 1
esac
