# 🔐 Setup Google Sign-In untuk Vossa4TeFa

## SHA-1 Fingerprint yang Diperlukan:
```
D6:89:CD:26:76:D8:3A:76:A7:B5:E3:A4:EC:75:98:41:31:0C:23:45
```

## 📋 Langkah-langkah Konfigurasi:

### 1. Firebase Console Setup
1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project **"Vossa4TeFa"**
3. Klik **Project Settings** (ikon gear ⚙️)
4. Scroll ke bagian **"Your apps"**
5. Klik pada aplikasi Android: `com.example.soft_skills_tefa`
6. Di bagian **"SHA certificate fingerprints"**:
   - Klik **"Add fingerprint"**
   - Masukkan: `D6:89:CD:26:76:D8:3A:76:A7:B5:E3:A4:EC:75:98:41:31:0C:23:45`
   - Klik **"Save"**

### 2. Download google-services.json
1. Setelah menambahkan SHA-1, download ulang `google-services.json`
2. Replace file di: `android/app/google-services.json`

### 3. Google Cloud Console Setup
1. Buka [Google Cloud Console](https://console.cloud.google.com)
2. Pilih project yang sama dengan Firebase
3. Pergi ke **APIs & Services** → **OAuth consent screen**
4. Pastikan OAuth consent screen sudah dikonfigurasi:
   - User Type: External
   - App name: Vossa4TeFa
   - User support email: fulungwkwk@gmail.com
   - Developer contact: fulungwkwk@gmail.com

### 4. Enable Google Sign-In API
1. Di Google Cloud Console, perg ke **APIs & Services** → **Library**
2. Cari "Google Sign-In API" atau "Google+ API"
3. Klik **"Enable"**

### 5. Test Aplikasi
1. Jalankan aplikasi: `fvm flutter run -d emulator-5554`
2. Coba login dengan Google
3. Jika masih error, tunggu 5-10 menit untuk propagasi konfigurasi

## 🔧 Troubleshooting:

### Error "ApiException: 10"
- Pastikan SHA-1 fingerprint sudah ditambahkan
- Pastikan google-services.json sudah diupdate
- Tunggu beberapa menit untuk propagasi

### Error "sign_in_failed"
- Pastikan OAuth consent screen sudah dikonfigurasi
- Pastikan Google Sign-In API sudah diaktifkan

### Error "network_error"
- Cek koneksi internet
- Pastikan emulator bisa akses internet

## 📱 Status Aplikasi:
- ✅ Email/Password Login
- ✅ Phone/OTP Login  
- ⚠️ Google Sign-In (perlu konfigurasi SHA-1)

Setelah mengikuti langkah-langkah di atas, Google Sign-In akan berfungsi dengan baik!
