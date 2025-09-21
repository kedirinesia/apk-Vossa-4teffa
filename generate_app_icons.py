#!/usr/bin/env python3
"""
Script untuk mengkonversi logoAPK.jpg menjadi berbagai ukuran icon yang dibutuhkan
untuk Android, iOS, dan Web.
"""

import os
from PIL import Image, ImageOps
import shutil

def create_icon_sizes():
    """Membuat berbagai ukuran icon dari logoAPK.jpg"""
    
    # Path ke logo sumber
    source_logo = "assets/logoAPK.jpg"
    
    if not os.path.exists(source_logo):
        print(f"❌ File {source_logo} tidak ditemukan!")
        return False
    
    print(f"✅ Menggunakan logo dari: {source_logo}")
    
    # Buka gambar sumber
    try:
        original_image = Image.open(source_logo)
        print(f"📏 Ukuran asli: {original_image.size}")
        
        # Konversi ke RGB jika perlu
        if original_image.mode != 'RGB':
            original_image = original_image.convert('RGB')
            
    except Exception as e:
        print(f"❌ Error membuka gambar: {e}")
        return False
    
    # Ukuran yang dibutuhkan untuk Android (dalam pixel)
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    # Ukuran yang dibutuhkan untuk iOS
    ios_sizes = {
        'Icon-App-20x20@1x.png': 20,
        'Icon-App-20x20@2x.png': 40,
        'Icon-App-20x20@3x.png': 60,
        'Icon-App-29x29@1x.png': 29,
        'Icon-App-29x29@2x.png': 58,
        'Icon-App-29x29@3x.png': 87,
        'Icon-App-40x40@1x.png': 40,
        'Icon-App-40x40@2x.png': 80,
        'Icon-App-40x40@3x.png': 120,
        'Icon-App-60x60@2x.png': 120,
        'Icon-App-60x60@3x.png': 180,
        'Icon-App-76x76@1x.png': 76,
        'Icon-App-76x76@2x.png': 152,
        'Icon-App-83.5x83.5@2x.png': 167,
        'Icon-App-1024x1024@1x.png': 1024
    }
    
    # Ukuran untuk Web
    web_sizes = {
        'Icon-192.png': 192,
        'Icon-512.png': 512,
        'Icon-maskable-192.png': 192,
        'Icon-maskable-512.png': 512
    }
    
    # Fungsi untuk resize gambar dengan kualitas tinggi
    def resize_image(image, size):
        """Resize gambar dengan kualitas tinggi"""
        return image.resize((size, size), Image.Resampling.LANCZOS)
    
    # Fungsi untuk membuat icon dengan background putih (untuk maskable)
    def create_maskable_icon(image, size):
        """Membuat icon dengan background putih untuk maskable icons"""
        # Resize gambar
        resized = resize_image(image, size)
        
        # Buat background putih
        background = Image.new('RGB', (size, size), 'white')
        
        # Paste gambar di tengah
        x = (size - resized.width) // 2
        y = (size - resized.height) // 2
        background.paste(resized, (x, y))
        
        return background
    
    print("\n🔧 Membuat icon untuk Android...")
    # Buat icon untuk Android
    for folder, size in android_sizes.items():
        folder_path = f"android/app/src/main/res/{folder}"
        os.makedirs(folder_path, exist_ok=True)
        
        resized_image = resize_image(original_image, size)
        output_path = os.path.join(folder_path, "ic_launcher.png")
        resized_image.save(output_path, "PNG")
        print(f"  ✅ {folder}/ic_launcher.png ({size}x{size})")
    
    print("\n🔧 Membuat icon untuk iOS...")
    # Buat icon untuk iOS
    ios_folder = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(ios_folder, exist_ok=True)
    
    for filename, size in ios_sizes.items():
        resized_image = resize_image(original_image, size)
        output_path = os.path.join(ios_folder, filename)
        resized_image.save(output_path, "PNG")
        print(f"  ✅ {filename} ({size}x{size})")
    
    print("\n🔧 Membuat icon untuk Web...")
    # Buat icon untuk Web
    web_folder = "web/icons"
    os.makedirs(web_folder, exist_ok=True)
    
    for filename, size in web_sizes.items():
        if 'maskable' in filename:
            # Buat maskable icon dengan background putih
            resized_image = create_maskable_icon(original_image, size)
        else:
            resized_image = resize_image(original_image, size)
        
        output_path = os.path.join(web_folder, filename)
        resized_image.save(output_path, "PNG")
        print(f"  ✅ {filename} ({size}x{size})")
    
    # Buat favicon untuk web
    favicon_path = "web/favicon.png"
    favicon_image = resize_image(original_image, 32)
    favicon_image.save(favicon_path, "PNG")
    print(f"  ✅ favicon.png (32x32)")
    
    print("\n🎉 Semua icon berhasil dibuat!")
    print("\n📋 Langkah selanjutnya:")
    print("1. Jalankan: flutter clean")
    print("2. Jalankan: flutter pub get")
    print("3. Build aplikasi: flutter build apk")
    
    return True

if __name__ == "__main__":
    print("🚀 Generator App Icons")
    print("=" * 50)
    create_icon_sizes()
