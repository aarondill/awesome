#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

declare -a set_c=(
  'https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/wallhaven-9mjw78.png'
  'https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/staircase.jpg'
  'https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/river.png'
  'https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/mountains.png'
  'https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/minimal_landscape.jpg'
  'https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/lake.jpg'
  'https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/australia.jpg'
  'https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/Computerized_Art_3440x1440_7.jpg'
  'https://raw.githubusercontent.com/AlexandrosLiaskos/Awesome_Wallpapers/main/images/beach_landscape.png'
)

mkdir -p ./C/images/
pushd ./C/images/ >/dev/null
for url in "${set_c[@]}"; do
  name="$(basename "$url")"
  if [ -f "$name" ]; then continue; fi
  echo "Downloading $name"
  curl -o "$name" "$url"
done
popd >/dev/null
echo "Done"
