# Diyet Takip Uygulaması

Flutter ile geliştirilmiş diyet takip uygulaması. Günlük öğünlerinizi kaydedin, fotoğraf ekleyin ve diyet raporlarınızı paylaşın.

## Özellikler

- 📱 **Çoklu Platform**: Android, iOS, Web desteği
- 📸 **Fotoğraf Ekleme**: Öğünlerinize fotoğraf ekleyin
- 📊 **Diyet Raporu**: Günlük diyet raporlarınızı oluşturun
- 📤 **Paylaşım**: Raporlarınızı diyetisyeninizle paylaşın
- 🌍 **Türkçe Desteği**: Tam Türkçe arayüz
- 📅 **Tarih Takibi**: Günlük öğün takibi

## Teknolojiler

- **Flutter**: 3.27.4
- **Dart**: 3.6.2
- **Provider**: State management
- **Shared Preferences**: Yerel veri saklama
- **Image Picker**: Fotoğraf seçimi
- **Share Plus**: Paylaşım özelliği

## Kurulum

```bash
# Projeyi klonlayın
git clone https://github.com/kullaniciadi/diyet-takip.git

# Bağımlılıkları yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

## Build

### Android APK
```bash
flutter build apk --release
```

### Web
```bash
flutter build web --release
```

## Deploy

### Netlify
Bu proje Netlify üzerinde deploy edilmiştir. Otomatik deploy için:

1. GitHub repository'sini Netlify'a bağlayın
2. Build command: `flutter build web --release`
3. Publish directory: `build/web`

### Diğer Platformlar
- **Vercel**: `vercel.json` dosyası hazır
- **GitHub Pages**: `.github/workflows/deploy.yml` dosyası hazır

## Lisans

MIT License

## İletişim

Proje hakkında sorularınız için issue açabilirsiniz.
