#!/bin/sh
set -eu

case "${SDK_NAME:-}" in
  iphoneos*) expected_platform="IOS" ;;
  iphonesimulator*) expected_platform="IOSSIMULATOR" ;;
  *) exit 0 ;;
esac

project_root="${FLUTTER_APPLICATION_PATH:-}"
if [ -z "$project_root" ]; then
  project_root="$(cd "${SRCROOT:-.}/.." && pwd)"
fi

native_assets_dir="$project_root/build/native_assets/ios"

clean_native_asset_cache() {
  rm -rf "$native_assets_dir"
  rm -rf "$project_root/.dart_tool/flutter_build"
  rm -f \
    "$project_root/build/dart_build_result.json" \
    "$project_root/build/dart_build.d" \
    "$project_root/build/install_code_assets.d" \
    "$project_root/build/native_assets.json"
}

if [ ! -d "$native_assets_dir" ]; then
  if [ -d "$project_root/.dart_tool/flutter_build" ] &&
    find "$project_root/.dart_tool/flutter_build" -name native_assets.json -print -quit | grep -q .; then
    echo "Cleaning incomplete Flutter native iOS asset cache"
    clean_native_asset_cache
  fi
  exit 0
fi

stale_asset=""
checked_asset=0
for framework_dir in "$native_assets_dir"/*.framework; do
  [ -d "$framework_dir" ] || continue
  framework_name="$(basename "$framework_dir" .framework)"
  framework_binary="$framework_dir/$framework_name"
  [ -f "$framework_binary" ] || continue
  checked_asset=1

  platform="$(xcrun vtool -show-build "$framework_binary" 2>/dev/null | awk '/platform / { print $2; exit }')"
  if [ -n "$platform" ] && [ "$platform" != "$expected_platform" ]; then
    stale_asset="$framework_binary ($platform)"
    break
  fi
done

if [ "$checked_asset" -eq 0 ]; then
  if [ -d "$project_root/.dart_tool/flutter_build" ] &&
    find "$project_root/.dart_tool/flutter_build" -name native_assets.json -print -quit | grep -q .; then
    echo "Cleaning incomplete Flutter native iOS asset cache"
    clean_native_asset_cache
  fi
  exit 0
fi

[ -n "$stale_asset" ] || exit 0

echo "Cleaning stale Flutter native iOS assets: expected $expected_platform, found $stale_asset"
clean_native_asset_cache
