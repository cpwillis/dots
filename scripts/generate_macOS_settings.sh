#!/usr/bin/env bash
# generate macOS configuration commands from current system values
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="${SCRIPT_DIR}/../meta/macOS_settings.sh"

# helpers — silently skip keys not present in defaults db
write_int() {
    local v
    if v=$(defaults read "$1" "$2" 2>/dev/null); then
        printf 'defaults write %s %s -int %s\n' "$1" "$2" "$v"
    fi
}
write_bool() {
    local v
    if v=$(defaults read "$1" "$2" 2>/dev/null); then
        printf 'defaults write %s %s -bool %s\n' "$1" "$2" "$v"
    fi
}
write_string() {
    local v
    if v=$(defaults read "$1" "$2" 2>/dev/null); then
        printf 'defaults write %s %s -string "%s"\n' "$1" "$2" "$v"
    fi
}

{
    # ── DOCK ────────────────────────────────────────────────────────────────────
    printf '# DOCK\n'
    printf '# icon size in pixels\n';                      write_int    com.apple.dock tilesize
    printf '# enable icon magnification on hover\n';       write_bool   com.apple.dock magnification
    printf '# magnified icon size\n';                      write_int    com.apple.dock largesize
    printf '# auto-hide the Dock\n';                       write_bool   com.apple.dock autohide
    printf '# dock position: left, bottom, right\n';       write_string com.apple.dock orientation
    printf '# minimize animation: genie, scale\n';         write_string com.apple.dock mineffect
    printf '# minimize windows into their app icon\n';     write_bool   com.apple.dock minimize-to-application
    printf '# show recently opened apps section\n';        write_bool   com.apple.dock show-recents

    # ── KEYBOARD ────────────────────────────────────────────────────────────────
    printf '\n# KEYBOARD\n'
    HK='defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add'
    printf '# Spotlight Search → opt-space (frees cmd-space for Alfred)\n'
    printf "%s 64 '{enabled = 1; value = {parameters = (32, 49, 524288);  type = standard; }; }'\n" "${HK}"
    printf '# Spotlight Window → disabled\n'
    printf "%s 65 '{enabled = 0; value = {parameters = (32, 49, 1572864); type = standard; }; }'\n" "${HK}"
    printf '# shift-cmd-3 screenshot to file → disabled (for Shottr)\n'
    printf "%s 28 '{enabled = 0; value = {parameters = (51, 20, 1179648); type = standard; }; }'\n" "${HK}"
    printf '# shift-cmd-4 screenshot area → disabled (for Shottr)\n'
    printf "%s 30 '{enabled = 0; value = {parameters = (52, 21, 1179648); type = standard; }; }'\n" "${HK}"
    printf '# apply symbolic hotkey changes\n'
    printf '/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u\n'
    printf '# key repeat rate — lower is faster (default: 6)\n';           write_int  NSGlobalDomain KeyRepeat
    printf '# delay before key repeat begins — lower is shorter (default: 25)\n'; write_int  NSGlobalDomain InitialKeyRepeat
    printf '# press-and-hold shows accent menu — false enables key repeat in editors\n'; write_bool NSGlobalDomain ApplePressAndHoldEnabled

    # ── TRACKPAD ────────────────────────────────────────────────────────────────
    printf '\n# TRACKPAD\n'
    printf '# tap to click\n';                                    write_bool com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking
    printf '# three-finger drag\n';                               write_bool com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag
    printf '# two-finger swipe for back/forward in browsers\n';   write_bool NSGlobalDomain AppleEnableSwipeNavigateWithScrolls
    printf '# force click and haptic feedback\n';                 write_bool com.apple.AppleMultitouchTrackpad ActuateDetents
    printf '# silent clicking (no click sound)\n';                write_bool com.apple.AppleMultitouchTrackpad SilentClicking

    # ── FINDER ──────────────────────────────────────────────────────────────────
    printf '\n# FINDER\n'
    printf '# new window default location\n';                          write_string com.apple.finder NewWindowTarget
    printf '# show hidden dotfiles\n';                                 write_bool   com.apple.finder AppleShowAllFiles
    printf '# show full path in title bar\n';                          write_bool   com.apple.finder _FXShowPosixPathInTitle
    printf '# show path bar at the bottom\n';                          write_bool   com.apple.finder ShowPathbar
    printf '# show status bar at the bottom\n';                        write_bool   com.apple.finder ShowStatusBar
    printf '# default view: Nlsv=list, icnv=icon, clmv=column, glyv=gallery\n'; write_string com.apple.finder FXPreferredViewStyle
    printf '# keep folders on top when sorting by name\n';             write_bool   com.apple.finder _FXSortFoldersFirst
    printf '# search scope: SCcf=current folder, SCev=entire Mac\n';   write_string com.apple.finder FXDefaultSearchScope
    printf '# warn before changing a file extension\n';                write_bool   com.apple.finder FXEnableExtensionChangeWarning
    printf '# show external drives on desktop\n';                      write_bool   com.apple.finder ShowExternalHardDrivesOnDesktop
    printf '# show removable media on desktop\n';                      write_bool   com.apple.finder ShowRemovableMediaOnDesktop

    # ── GENERAL ─────────────────────────────────────────────────────────────────
    printf '\n# GENERAL\n'
    printf '# screenshot save location\n';                             write_string com.apple.screencapture location
    printf '# screenshot format: png, jpg, pdf, tiff, bmp\n';         write_string com.apple.screencapture type
    printf '# scrollbar visibility: WhenScrolling, Automatic, Always\n'; write_string NSGlobalDomain AppleShowScrollBars
    printf '# save new documents to iCloud by default\n';              write_bool   NSGlobalDomain NSDocumentSaveNewDocumentsToCloud
    printf '# expand save dialog by default\n';                        write_bool   NSGlobalDomain NSNavPanelExpandedStateForSaveMode
    printf '# expand print dialog by default\n';                       write_bool   NSGlobalDomain PMPrintingExpandedStateForPrint2
    printf '# auto-capitalise first letter of sentences\n';            write_bool   NSGlobalDomain NSAutomaticCapitalizationEnabled
    printf '# substitute -- with em dash automatically\n';             write_bool   NSGlobalDomain NSAutomaticDashSubstitutionEnabled
    printf '# substitute straight quotes with curly quotes\n';         write_bool   NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled
    printf '# auto-correct spelling\n';                                write_bool   NSGlobalDomain NSAutomaticSpellingCorrectionEnabled

    # ── MISSION CONTROL ─────────────────────────────────────────────────────────
    printf '\n# MISSION CONTROL\n'
    printf '# auto-rearrange Spaces based on most recent use\n';  write_bool com.apple.dock mru-spaces
    printf '# group windows by app in Mission Control\n';         write_bool com.apple.dock expose-group-by-app

    # ── Apply changes ────────────────────────────────────────────────────────────
    printf '\n# Apply changes\n'
    printf 'killall Dock || true\n'
    printf 'killall Finder || true\n'
    printf 'killall SystemUIServer || true\n'

} > "${SETTINGS_FILE}"

printf "✓ Generated macOS settings → %s\n" "${SETTINGS_FILE}"
