# Quietude

![quietude](images/logo.jpg?raw=true "quietude logo")

Quietude provides a distraction-free Android experience through disabling all the system applications that you don't need day-to-day. Think of it as a "LightPhone"-like experience on a regular phone, but where you get to choose your applications. 

Applications are disabled in a way that is reversable, but only by plugging in a USB cable and running quietude (or adb) again.

## Usage

![screenshot](images/screenshot.jpg?raw=true "screenshot")

Syntax:

```shell
./quietude.sh [disable|enable] <category>
```

Disable all built-in distractions and bloat:

```shell
./quietude.sh disable all
```

Re-enable Google Maps:

```shell
./quietude.sh enable maps
```

Re-enable everything:

```shell
./quietude.sh enable all
```

## Requirements

* A macOS or Linux host - this may also function within WSL2 (untested)
* A USB cable plugged into your Android phone
* [Android Debug Bridge](https://developer.android.com/studio/command-line/adb), though if missing, quietude will try to automatically install this on macOS and Ubuntu
* [USB Debugging](https://developer.android.com/studio/command-line/adb#Enabling) enabled on your phone.

## Details

What does Quietude disable on a phone? It depends on the category used:

* `all`
  * Everything below
* `distractions`
  * Google Chrome
  * Google Docs
  * Google Search
  * Youtube
* `store`
  * Google Play Store
* `bloat`
  * Sound Recorder
  * Youtube Music
  * Google Wellbeing
  * Android Tips
  * File Manager
  * Verizon's built-in Android agents
* `gmail`
  * GMail
* `maps`
  * Google Maps

## Recommended post-execution steps:

  - Replace the Android launcher with a minimalist one, such as [olauncher](https://play.google.com/store/apps/details?id=app.olauncher&hl=en_US&gl=US)
  - Change your phone's language to one you vaguely understand (Swedish!)
  - Force your screen into monochrome mode (Settings -> Developer -> Simulate color space -> Monochromacy) or another color simulation.

## FAQ

### What about disabling Social Networking?

I don't have any to test against, but feel free to send a pull request if you know the ID of any that ship with a phone.

### What phones will this work on?

As far as I know, any phone where you can enable USB Debugging. This should include all [Google Play supported devices](https://storage.googleapis.com/play_public/supported_devices.html).

