# 📱 Setup Phone Authentication untuk Vossa4TeFa

## ⚠️ Error: BILLING_NOT_ENABLED

Error ini terjadi karena Firebase Phone Authentication memerlukan **billing enabled** di Firebase project.

## 📋 Langkah-langkah Mengatasi:

### 1. Enable Billing di Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project **"Vossa4TeFa"**
3. Klik **Project Settings** (⚙️)
4. Pergi ke tab **"Usage and billing"**
5. Klik **"Upgrade to Blaze plan"** (Pay-as-you-go)
6. Tambahkan payment method (kartu kredit/debit)

### 2. Konfigurasi Phone Authentication
1. Di Firebase Console, perg ke **Authentication** → **Sign-in method**
2. Pastikan **Phone** provider sudah diaktifkan
3. Konfigurasi **App verification** jika diperlukan

### 3. Test Phone Authentication
1. Jalankan aplikasi: `fvm flutter run -d emulator-5554`
2. Coba login dengan nomor HP
3. OTP akan dikirim ke nomor HP

## 💰 Biaya Phone Authentication:

### Blaze Plan (Pay-as-you-go):
- **Gratis**: 10,000 verifikasi per bulan
- **Berbayar**: $0.01 per verifikasi setelah quota gratis

### Spark Plan (Gratis):
- **Tidak mendukung** Phone Authentication
- Hanya mendukung Email/Password dan Google Sign-In

## 🔧 Alternatif Solusi:

### 1. Gunakan Email/Password Login
- Sudah berfungsi dengan baik
- Tidak memerlukan billing
- Cocok untuk development/testing

### 2. Gunakan Google Sign-In
- Setelah dikonfigurasi SHA-1 fingerprint
- Tidak memerlukan billing
- User-friendly

### 3. Disable Phone Authentication
- Hapus tab "Nomor HP" dari login page
- Fokus pada Email dan Google Sign-In

## 📱 Status Aplikasi:
- ✅ **Email/Password Login** - Berfungsi normal
- ⚠️ **Phone/OTP Login** - Perlu billing enabled
- ⚠️ **Google Sign-In** - Perlu konfigurasi SHA-1

## 🎯 Rekomendasi:
Untuk development dan testing, gunakan **Email/Password login** yang sudah berfungsi dengan baik. Phone Authentication bisa diaktifkan nanti saat aplikasi sudah siap untuk production.
