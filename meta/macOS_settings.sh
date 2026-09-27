# DOCK
# icon size in pixels
defaults write com.apple.dock tilesize -int 16
# enable icon magnification on hover
defaults write com.apple.dock magnification -bool true
# magnified icon size
defaults write com.apple.dock largesize -int 30
# auto-hide the Dock
defaults write com.apple.dock autohide -bool false
# dock position: left, bottom, right
# minimize animation: genie, scale
# minimize windows into their app icon
# show recently opened apps section
defaults write com.apple.dock show-recents -bool false

# KEYBOARD
# Spotlight Search → opt-space (frees cmd-space for Alfred)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 '{enabled = 1; value = {parameters = (32, 49, 524288);  type = standard; }; }'
# Spotlight Window → disabled
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 '{enabled = 0; value = {parameters = (32, 49, 1572864); type = standard; }; }'
# shift-cmd-3 screenshot to file → disabled (for Shottr)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 28 '{enabled = 0; value = {parameters = (51, 20, 1179648); type = standard; }; }'
# shift-cmd-4 screenshot area → disabled (for Shottr)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 30 '{enabled = 0; value = {parameters = (52, 21, 1179648); type = standard; }; }'
# apply symbolic hotkey changes
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
# key repeat rate - lower is faster (default: 6)
# delay before key repeat begins - lower is shorter (default: 25)
# press-and-hold shows accent menu - false enables key repeat in editors

# TRACKPAD
# tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# three-finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false
# two-finger swipe for back/forward in browsers
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false
# force click and haptic feedback
defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -bool true
# silent clicking (no click sound)

# FINDER
# new window default location
defaults write com.apple.finder NewWindowTarget -string "PfDo"
# show hidden dotfiles
# show full path in title bar
# show path bar at the bottom
defaults write com.apple.finder ShowPathbar -bool true
# show status bar at the bottom
defaults write com.apple.finder ShowStatusBar -bool false
# default view: Nlsv=list, icnv=icon, clmv=column, glyv=gallery
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
# keep folders on top when sorting by name
# search scope: SCcf=current folder, SCev=entire Mac
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# warn before changing a file extension
# show external drives on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
# show removable media on desktop
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# GENERAL
# screenshot save location
defaults write com.apple.screencapture location -string "~/Downloads"
# screenshot format: png, jpg, pdf, tiff, bmp
# scrollbar visibility: WhenScrolling, Automatic, Always
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"
# save new documents to iCloud by default
# expand save dialog by default
# expand print dialog by default
# auto-capitalise first letter of sentences
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true
# substitute -- with em dash automatically
# substitute straight quotes with curly quotes
# auto-correct spelling

# MISSION CONTROL
# auto-rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false
# group windows by app in Mission Control

# Apply changes
killall Dock || true
killall Finder || true
killall SystemUIServer || true
