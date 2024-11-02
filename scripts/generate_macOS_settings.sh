#!/bin/sh
# generate macOS configuration commands (with existing values)

SETTINGS_FILE="$(cd "$(dirname "$0")/../config" && pwd)/macOS_settings.txt"

{
    echo "# DOCK; icon size, magnification bool/size"
    echo "defaults write com.apple.dock tilesize -int $(defaults read com.apple.dock tilesize)"
    echo "defaults write com.apple.dock magnification -bool $(defaults read com.apple.dock magnification)"
    echo "defaults write com.apple.dock largesize -int $(defaults read com.apple.dock largesize)"
    
    echo "\n# KEYBOARD; change spotlight to optn-space, alfred cmd-space, disable screenshots shift-cmd-3 & shift-cmd-4 to be used by shottr"
    
    echo "\n# TRACKPAD; gesture bools"
    echo "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool $(defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking)"
    echo "defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool $(defaults read com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag)"
    echo "defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool $(defaults read NSGlobalDomain AppleEnableSwipeNavigateWithScrolls)"
    
    echo "\n# FINDER; new window location"
    echo "defaults write com.apple.finder NewWindowTarget -string \"$(defaults read com.apple.finder NewWindowTarget)"
    
    echo "\n# GENERAL; screenshot save location, scroll bars"
    echo "defaults write com.apple.screencapture location -string \"$(defaults read com.apple.screencapture location)\""
    echo "defaults write NSGlobalDomain AppleShowScrollBars -string \"$(defaults read NSGlobalDomain AppleShowScrollBars)\""
    
} > "$SETTINGS_FILE"

echo "Successfully generated macOS settings commands to $SETTINGS_FILE"
