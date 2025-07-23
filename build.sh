#!/bin/bash

# Flutter'ı kur
echo "Flutter kuruluyor..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Flutter doctor
flutter doctor

# Bağımlılıkları yükle
echo "Bağımlılıklar yükleniyor..."
flutter pub get

# Web build
echo "Web build oluşturuluyor..."
flutter build web --release

echo "Build tamamlandı!" 