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
readonly DRIVE="
com.google.android.apps.docs
com.google.android.apps.docs.editors.docs
"

readonly BUILTIN_DISTRACTIONS="
com.google.android.googlequicksearchbox
com.google.android.googlequicksearchbox.nga_resources
com.google.android.youtube
com.android.htmlviewer
"

readonly BROWSERS="
com.android.chrome
com.chrome.dev
com.duckduckgo.mobile.android
com.microsoft.emmx
com.opera.gx
com.opera.mini.native.beta
org.mozilla.firefox
org.mozilla.firefox_beta
"

readonly SOCIAL_MEDIA="
com.bereal.ft
com.facebook.katana
com.instagram.android
com.keylesspalace.tusky
com.pinterest
com.reddit.frontpage
com.rubenmayayo.reddit
com.snapchat.android
com.truthsocial.android.app
com.tumblr
com.twitter.android
com.vkontakte.android
com.zhiliaoapp.musically
ml.docilealligator.infinityforreddit
org.joinmastodon.android
tv.twitch.android.app
"

readonly NEWS="
bbc.mobile.news.www
com.abc.abcnews
com.aljazeera.mobile
com.cbsnews.ott
com.cnn.mobile.android.phone
com.devhd.feedly
com.eterno
com.foxnews.android
com.google.android.apps.magazines
com.guardian
com.nytimes.android
com.opera.app.news
com.particlenews.newsbreak
com.spotcrime.spotcrimemobilev2
com.treemolabs.apps.cbsnews
com.yahoo.mobile.client.android.yahoo
com.zumobi.msnbc
flipboard.app
jp.gocro.smartnews.android
mnn.Android
org.npr.one
sp0n.citizen
"

DISTRACTIONS="${BROWSERS} ${NEWS} ${BUILTIN_DISTRACTIONS} ${SOCIAL_MEDIA}"
ALL="${DISTRACTIONS} ${DRIVE} ${MAPS} ${GMAIL} ${STORE} ${BLOAT}"

# Convenience for an extra path one might happen to have 'adb' installed.
export PATH=$PATH:$HOME/Downloads/platform-tools

# "enable" or "disable"
readonly MODE=$1
shift

adb_installed() {
	adb version >/dev/null && return

	if [ -x /opt/homebrew/bin/brew ]; then
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

adb_connected() {
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
	bloat)
		list="${list} ${BLOAT}"
		;;
	social)
		list="${list} ${SOCIAL_MEDIA}"
		;;
	news)
		list="${list} ${NEWS}"
		;;
	browsers)
		list="${list} ${BROWSERS}"
		;;
	drive)
		list="${list} ${DRIVE}"
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
	launcher)
		list="${list} com.google.android.apps.nexuslauncher"
		;;
	tv)
		list="${list} com.google.android.videos"
		;;
	distractions)
		list="${list} ${DISTRACTIONS}"
		;;
	all)
		list="${list} ${ALL}"
		;;
	*)
		echo "unknown group: $1"
		exit 1
		;;
	esac
	shift
done

items="$(echo $list | sort -u | grep '\.' | xargs | sed s/' '/'\$\|\^'/g)"
APP_RE="^${items}$"

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
	;;
esac
