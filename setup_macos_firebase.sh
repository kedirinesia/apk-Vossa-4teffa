#!/bin/bash

# Script otomatis setup Flutter macOS project dengan Firebase
# Tested on Flutter 3.35.1 + macOS 15.5

set -e

echo "🔹 Step 1: Cek versi Flutter"
flutter --version

echo "🔹 Step 2: Bersihkan project"
flutter clean
rm -rf macos/Pods macos/Podfile.lock macos/Runner.xcworkspace

echo "🔹 Step 3: Regenerate folder macOS"
flutter create .

echo "🔹 Step 4: Cek Firebase CLI"
if ! command -v firebase &> /dev/null
then
    echo "Firebase CLI belum terinstall. Menginstall..."
    curl -sL https://firebase.tools | bash
else
    echo "Firebase CLI sudah terinstall."
fi

echo "🔹 Step 5: Cek FlutterFire CLI"
if ! command -v flutterfire &> /dev/null
then
    echo "FlutterFire CLI belum ada. Install..."
    dart pub global activate flutterfire_cli
else
    echo "FlutterFire CLI sudah terinstall."
fi

echo "🔹 Step 6: Konfigurasi Firebase untuk macOS"
flutterfire configure \
  --platforms=macos \
  --project=<FIREBASE_PROJECT_ID> \
  --out=lib/firebase_options.dart

echo "🔹 Step 7: Update dependencies Flutter"
flutter pub get

echo "🔹 Step 8: Install CocoaPods"
cd macos
pod install
cd ..

echo "✅ Setup selesai!"
echo "Sekarang jalankan aplikasi dengan: flutter run -d macos"
