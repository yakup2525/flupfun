#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${PROJECT_DIR}/deploy/android"
AAB_SOURCE="${PROJECT_DIR}/build/app/outputs/bundle/release/app-release.aab"
DATE="$(date +%Y-%m-%d)"
APP_NAME="flupfun"

cd "${PROJECT_DIR}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter bulunamadi. PATH'e eklendiginden emin olun."
  exit 1
fi

if [[ ! -f "${PROJECT_DIR}/android/key.properties" ]]; then
  echo "android/key.properties bulunamadi. Release imzasi icin gerekli."
  exit 1
fi

VERSION="$(grep '^version:' pubspec.yaml | sed 's/version: //g' | tr -d ' ')"
OUTPUT_FILE="${OUTPUT_DIR}/${APP_NAME}-${DATE}-v${VERSION}.aab"

echo "Release AAB derleniyor..."
flutter pub get
flutter build appbundle --release

if [[ ! -f "${AAB_SOURCE}" ]]; then
  echo "AAB dosyasi olusturulamadi: ${AAB_SOURCE}"
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"
cp "${AAB_SOURCE}" "${OUTPUT_FILE}"

echo ""
echo "Deploy ciktisi hazir:"
echo "  ${OUTPUT_FILE}"
echo ""
echo "Google Play Console'a yuklemek icin bu dosyayi kullanabilirsiniz."
