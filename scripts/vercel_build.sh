#!/usr/bin/env bash
# ==============================================================================
# Dripzoid Flutter Web — Reproducible Vercel Build Script
# ==============================================================================
set -euo pipefail

echo "=========================================================="
echo "  Dripzoid Flutter Web — Vercel Release Build Pipeline   "
echo "=========================================================="

# 1. Pinned Flutter SDK Version
FLUTTER_VERSION="3.44.6"
FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/flutter}"

echo "[Info] Target Flutter SDK version: ${FLUTTER_VERSION}"
echo "[Info] Flutter install root: ${FLUTTER_ROOT}"

# 2. Check if Flutter is already present in PATH or target directory
if command -v flutter >/dev/null 2>&1; then
  echo "[Info] Flutter is already available in PATH: $(which flutter)"
elif [ -x "${FLUTTER_ROOT}/bin/flutter" ]; then
  echo "[Info] Found Flutter in cached directory: ${FLUTTER_ROOT}/bin/flutter"
  export PATH="${FLUTTER_ROOT}/bin:${PATH}"
else
  echo "[Info] Installing pinned Flutter SDK v${FLUTTER_VERSION}..."
  mkdir -p "$(dirname "${FLUTTER_ROOT}")"

  TARBALL_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  ARCHIVE_PATH="/tmp/flutter_linux_${FLUTTER_VERSION}.tar.xz"
  INSTALLED=0

  if command -v curl >/dev/null 2>&1 && command -v tar >/dev/null 2>&1 && command -v xz >/dev/null 2>&1; then
    echo "[Info] Downloading official tarball from ${TARBALL_URL}..."
    if curl -sSfL "${TARBALL_URL}" -o "${ARCHIVE_PATH}"; then
      echo "[Info] Extracting tarball into $(dirname "${FLUTTER_ROOT}")..."
      tar -xf "${ARCHIVE_PATH}" -C "$(dirname "${FLUTTER_ROOT}")"
      rm -f "${ARCHIVE_PATH}"
      INSTALLED=1
    else
      echo "[Warn] Tarball download failed. Falling back to git clone..."
    fi
  fi

  if [ "${INSTALLED}" -ne 1 ]; then
    echo "[Info] Performing shallow git clone (tag: ${FLUTTER_VERSION})..."
    rm -rf "${FLUTTER_ROOT}"
    git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git "${FLUTTER_ROOT}"
  fi

  export PATH="${FLUTTER_ROOT}/bin:${PATH}"
fi

# 3. Configure git safe directory (avoids 'dubious ownership' in containerized environments)
git config --global --add safe.directory "*" || true

# 4. Disable analytics to prevent CI hangs and network stalls
echo "[Info] Disabling Flutter analytics..."
flutter config --no-analytics >/dev/null 2>&1 || true

# 5. Pre-cache web engine artifacts
echo "[Info] Pre-caching Flutter Web engine artifacts..."
flutter precache --web

# 6. Print toolchain versions
echo "----------------------------------------------------------"
echo "[Info] Active Toolchain Versions:"
flutter --version
dart --version
echo "----------------------------------------------------------"

# 7. Resolve package dependencies
echo "[Info] Fetching dependencies (flutter pub get)..."
flutter pub get

# 8. Run code quality verification
echo "[Info] Running static analysis (flutter analyze)..."
flutter analyze

echo "[Info] Running test suite (flutter test)..."
flutter test

# 9. Build production web release
echo "[Info] Building Flutter Web production release..."
BUILD_ARGS=(build web --release)

# Inject environment variables if provided
if [ -n "${RAZORPAY_KEY:-}" ]; then
  echo "[Info] Passing RAZORPAY_KEY from environment to build"
  BUILD_ARGS+=(--dart-define="RAZORPAY_KEY=${RAZORPAY_KEY}")
fi

if [ -n "${APP_ENV:-}" ]; then
  echo "[Info] Passing APP_ENV=${APP_ENV} to build"
  BUILD_ARGS+=(--dart-define="APP_ENV=${APP_ENV}")
fi

flutter "${BUILD_ARGS[@]}"

# 10. Verify generated artifacts
echo "[Info] Verifying output artifacts in build/web..."
if [ ! -f "build/web/index.html" ]; then
  echo "[Error] Verification failed: build/web/index.html not found!" >&2
  exit 1
fi

if [ ! -f "build/web/main.dart.js" ]; then
  echo "[Error] Verification failed: build/web/main.dart.js not found!" >&2
  exit 1
fi

if [ ! -f "build/web/flutter.js" ]; then
  echo "[Error] Verification failed: build/web/flutter.js not found!" >&2
  exit 1
fi

echo "=========================================================="
echo "  Dripzoid Flutter Web — Build Successful! Output: build/web"
echo "=========================================================="
