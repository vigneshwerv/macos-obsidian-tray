#!/bin/bash
set -euo pipefail

APP_NAME="Obsidian Tray"
SCHEME="Obsidian Tray"
PROJECT_DIR="Obsidian Tray"
BUILD_DIR="$(pwd)/build"
ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "==> Archiving..."
xcodebuild archive \
  -project "$PROJECT_DIR/$APP_NAME.xcodeproj" \
  -scheme "$SCHEME" \
  -archivePath "$ARCHIVE_PATH" \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=NO \
  -quiet

echo "==> Exporting app..."
mkdir -p "$EXPORT_PATH"
cp -R "$ARCHIVE_PATH/Products/Applications/$APP_NAME.app" "$EXPORT_PATH/"

echo "==> Creating DMG..."
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$EXPORT_PATH" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo ""
echo "Done: $DMG_PATH"
