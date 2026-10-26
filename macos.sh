#!/usr/bin/env bash
# macOS system preferences. Safe to re-run.
set -euo pipefail

# Dock: autohide, 56px icons, no "recent apps" section
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 56
defaults write com.apple.dock show-recents -bool false

# Trackpad: tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Rectangle: use its alternate default shortcuts, skip welcome/update prompts
defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -bool true
defaults write com.knollsoft.Rectangle allowAnyShortcut -bool true
defaults write com.knollsoft.Rectangle SUEnableAutomaticChecks -bool false
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1

killall Dock 2>/dev/null || true
echo "macOS defaults applied (some need a logout to take effect)."
