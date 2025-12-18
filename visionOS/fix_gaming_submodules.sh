#!/bin/bash

# List of all gaming apps
GAMING_APPS=(
  "visionOS_Gaming_shadow-boxing-champions"
  "visionOS_Gaming_tactical-team-shooters"
  "visionOS_Gaming_home-defense-strategy"
  "visionOS_Gaming_spatial-arena-championship"
  "visionOS_Gaming_reality-realms-rpg"
  "visionOS_Gaming_time-machine-adventures"
  "visionOS_Gaming_mystery-investigation"
  "visionOS_Gaming_escape-room-network"
  "visionOS_Gaming_city-builder-tabletop"
  "visionOS_Gaming_reality-minecraft"
  "visionOS_Gaming_virtual-pet-ecosystem"
  "visionOS_Gaming_science-lab-sandbox"
  "visionOS_Gaming_rhythm-flow"
  "visionOS_Gaming_spatial-music-studio"
  "visionOS_Gaming_spatial-pictionary"
  "visionOS_Gaming_narrative-story-worlds"
  "visionOS_Gaming_interactive-theater"
  "visionOS_Gaming_myspatial-life"
  "visionOS_Gaming_holographic-board-games"
  "visionOS_Gaming_arena-esports"
  "visionOS_Gaming_hide-and-seek-evolved"
  "visionOS_Gaming_parkour-pathways"
  "visionOS_Gaming_reality-mmo-layer"
  "visionOS_Gaming_mindfulness-meditation-realms"
)

echo "Fixing gaming app submodules - converting to regular directories..."

for app in "${GAMING_APPS[@]}"; do
  if [ -d "$app/.git" ]; then
    echo "Processing $app..."
    # Remove from git index (unstage as submodule)
    git rm --cached "$app" 2>/dev/null
    # Remove .git directory
    rm -rf "$app/.git"
    # Add back as regular directory
    git add "$app"
    echo "  ✓ Fixed $app"
  else
    echo "  ⊘ $app has no .git directory"
  fi
done

echo ""
echo "All gaming apps converted from submodules to regular directories!"
echo "Now commit and push the changes."
