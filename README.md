# Perilumi
1-5 yaş için sesli, çevrimdışı 3D eğitici oyun (Godot 4.6.2).

## Derleme
Her gönderimde GitHub Actions `perilumi-test-apk` üretir. İmza anahtarı eklenince `perilumi-play-aab` de üretilir.

## İmza anahtarı (Termux, bir kez)
    pkg install openjdk-17
    cd ~ && keytool -genkeypair -keystore perilumi.keystore -alias perilumi -keyalg RSA -keysize 2048 -validity 10000
    base64 -w0 perilumi.keystore > perilumi.b64
GitHub > Settings > Secrets and variables > Actions:
- `KEYSTORE_BASE64`: perilumi.b64 içeriği
- `KEYSTORE_PASSWORD`: belirlediğin parola

`perilumi.keystore` dosyasını ve parolayı yedekle; depoya yükleme.

## Play Console
- Tür: Oyun, Eğitici. Ücretsiz.
- Hedef kitle: yalnız "5 yaş ve altı".
- Reklam: Hayır. Uygulama içi satın alma: yok.
- Veri güvenliği: veri toplanmıyor, paylaşılmıyor.
- Uygulama erişimi: giriş gerekmez.
- İçerik derecelendirme: şiddet ve uygunsuz içerik yok.
- Gizlilik politikası: `store/gizlilik.html` dosyasını siteye yükle, adresini gir.
- Görseller: `store/` klasörü.
- Yeni kişisel hesap: 12 testçi, 14 gün kapalı test.
