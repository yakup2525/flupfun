#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Select unused iOS values after checking App Store Connect; Android is untouched.
: "${IOS_BUILD_NAME:?Set the intended iOS marketing version}"
: "${IOS_BUILD_NUMBER:?Set an unused iOS build number}"
flutter pub get
flutter build ipa --release --dart-define-from-file=config/ads.ios.production.json \
  --build-name="$IOS_BUILD_NAME" --build-number="$IOS_BUILD_NUMBER" "$@"
