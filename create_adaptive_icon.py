#!/usr/bin/env python3
"""
Script untuk membuat adaptive icon yang menggunakan logo asli dari assets/logoAPK.jpg
"""

import os
from PIL import Image, ImageOps
import shutil

def create_adaptive_icon():
    """Membuat adaptive icon yang menggunakan logo asli"""
    
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
    
    # Buat folder untuk adaptive icon
    adaptive_folder = "android/app/src/main/res/mipmap-anydpi-v26"
    os.makedirs(adaptive_folder, exist_ok=True)
    
    # Buat folder untuk drawable
    drawable_folder = "android/app/src/main/res/drawable"
    os.makedirs(drawable_folder, exist_ok=True)
    
    # Buat adaptive icon XML
    adaptive_icon_xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>'''
    
    with open(f"{adaptive_folder}/ic_launcher.xml", "w") as f:
        f.write(adaptive_icon_xml)
    
    with open(f"{adaptive_folder}/ic_launcher_round.xml", "w") as f:
        f.write(adaptive_icon_xml)
    
    # Buat background putih
    background_xml = '''<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path android:fillColor="#FFFFFF"
          android:pathData="M0,0h108v108h-108z" />
</vector>'''
    
    with open(f"{drawable_folder}/ic_launcher_background.xml", "w") as f:
        f.write(background_xml)
    
    # Buat foreground dengan logo asli
    # Resize logo ke ukuran yang lebih kecil untuk adaptive icon (70% dari ukuran penuh)
    logo_size = 76  # 70% dari 108
    resized_logo = original_image.resize((logo_size, logo_size), Image.Resampling.LANCZOS)
    
    # Buat canvas 108x108 dengan background transparan
    canvas = Image.new('RGBA', (108, 108), (0, 0, 0, 0))
    
    # Hitung posisi tengah untuk logo
    x_offset = (108 - logo_size) // 2
    y_offset = (108 - logo_size) // 2
    
    # Paste logo di tengah canvas
    canvas.paste(resized_logo, (x_offset, y_offset))
    
    # Simpan sebagai PNG untuk foreground
    foreground_path = f"{drawable_folder}/ic_launcher_foreground.png"
    canvas.save(foreground_path, "PNG")
    
    # Buat foreground XML yang menggunakan PNG
    foreground_xml = f'''<?xml version="1.0" encoding="utf-8"?>
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/ic_launcher_foreground" />'''
    
    with open(f"{drawable_folder}/ic_launcher_foreground.xml", "w") as f:
        f.write(foreground_xml)
    
    print("✅ Adaptive icon berhasil dibuat!")
    print("📱 Logo asli sekarang digunakan sebagai foreground")
    print("🎨 Background putih untuk kontras yang baik")
    
    return True

if __name__ == "__main__":
    print("🚀 Membuat Adaptive Icon dengan Logo Asli")
    print("=" * 50)
    create_adaptive_icon()
