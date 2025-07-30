# My Diet - Diyet Takip Uygulaması

Bu Flutter uygulaması, kullanıcıların günlük beslenme alışkanlıklarını takip etmelerine ve diyetisyenleriyle paylaşmalarına olanak sağlar.

## Özellikler

- Kullanıcı profil oluşturma ve düzenleme
- Harris-Benedict formülü ile günlük kalori ihtiyacı hesaplama
- Özel kalori hedefi belirleme
- AI destekli besin kalori hesaplama (Gemini API)
- Manuel kalori girişi
- Öğün ekleme, düzenleme ve silme
- Detaylı besin değeri takibi
- Diyetisyenle paylaşım raporu oluşturma

## Kurulum

1. Projeyi klonlayın:
```bash
git clone <repository-url>
cd my_diet
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Gemini API anahtarını ayarlayın:
   - `.env.example` dosyasını `.env` olarak kopyalayın
   - `.env` dosyasında `GEMINI_API_KEY` değerini kendi API anahtarınızla değiştirin

```bash
cp .env.example .env
```

4. Uygulamayı çalıştırın:
```bash
flutter run
```

## API Anahtarı Kurulumu

Bu uygulama Gemini AI API'sini kullanır. API anahtarını almak için:

1. [Google AI Studio](https://makersuite.google.com/app/apikey) adresine gidin
2. Yeni bir API anahtarı oluşturun
3. `.env` dosyasında `GEMINI_API_KEY` değerini güncelleyin

## Güvenlik

- `.env` dosyası `.gitignore`'a eklenmiştir ve GitHub'a yüklenmez
- API anahtarınızı asla doğrudan kod içinde saklamayın
- `.env.example` dosyasını referans olarak kullanın

## Kullanım

1. **Profil Oluşturma**: İlk açılışta kullanıcı bilgilerinizi girin
2. **Öğün Ekleme**: "+" butonuna tıklayarak yeni öğün ekleyin
3. **Besin Ekleme**: Her öğüne tek tek besin maddeleri ekleyin
4. **Kalori Hesaplama**: AI ile otomatik veya manuel kalori girişi
5. **Takip**: Günlük kalori alımınızı takip edin
6. **Paylaşım**: Diyetisyeninizle detaylı rapor paylaşın

## Teknolojiler

- Flutter
- Provider (State Management)
- SharedPreferences (Veri Saklama)
- Gemini AI API
- HTTP (API İletişimi)
- Screenshot (Rapor Oluşturma)
- Share Plus (Dosya Paylaşımı)
