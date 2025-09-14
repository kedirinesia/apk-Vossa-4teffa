#!/bin/bash
# Jalankan: ./fix_imports.sh

MISSING=$(./check_imports.sh | grep "❌ Hilang")

if [ -z "$MISSING" ]; then
  echo "✅ Tidak ada import yang hilang."
  exit 0
fi

echo "🔧 Memperbaiki import yang hilang..."

while IFS= read -r line; do
  FILE=$(echo $line | cut -d':' -f2)
  IMPORT=$(echo $line | cut -d':' -f3-)

  if [ -f "$FILE" ]; then
    if ! grep -q "$IMPORT" "$FILE"; then
      # Cari baris terakhir yang mengandung 'import'
      LAST_IMPORT_LINE=$(grep -n "^import " "$FILE" | tail -n 1 | cut -d: -f1)

      if [ -z "$LAST_IMPORT_LINE" ]; then
        # Kalau tidak ada import sama sekali, tambahkan di paling atas
        echo "$IMPORT" | cat - "$FILE" > temp && mv temp "$FILE"
      else
        # Sisipkan setelah import terakhir
        awk -v l=$LAST_IMPORT_LINE -v imp="$IMPORT" '
          NR==l {print; print imp; next} 
          {print}
        ' "$FILE" > temp && mv temp "$FILE"
      fi

      echo "✅ Ditambahkan ke $FILE -> $IMPORT"
    fi
  fi
done <<< "$MISSING"

echo "🚀 Semua import hilang sudah diperbaiki!"
#!/bin/bash

while read -r FILE; do
  # Skip baris kosong atau komentar
  [[ -z "$FILE" || "$FILE" =~ ^# ]] && continue

  # Jika import dari package: (flutter, fl_chart, lottie, dll)
  if [[ "$FILE" == package:* ]]; then
    echo "📦 Package import: $FILE (cek di pubspec.yaml)"
  else
    # Import lokal, cek apakah file ada
    if [ -f "$FILE" ]; then
      echo "✅ Ada: $FILE"
    else
      echo "❌ Hilang: $FILE"
    fi
  fi
done < imports.txt
#!/bin/bash
echo "🔎 Mengecek file import di folder lib/ ..."

# Kumpulkan semua file dart yang ada di lib
ALL_FILES=$(find lib -type f -name "*.dart" | sed 's|^./||')

# Cari semua import selain bawaan Flutter/Dart
grep -R "import '" lib/ | grep -v "package:flutter" | grep -v "dart:" | while read -r line; do
  FILE=$(echo "$line" | sed -E "s/.*import '(.*)';.*/\1/")

  # Kalau import relative (misalnya ../pages/xxx.dart)
  if [[ "$FILE" == .* ]]; then
    DIR=$(dirname "$(echo "$line" | cut -d: -f1)")
    FILE=$(realpath --relative-to=. "$DIR/$FILE")
  fi

  if [ -f "$FILE" ]; then
    echo "✅ Ada: $FILE"
  else
    echo "❌ Hilang: $FILE"

    # Coba cari file yang mirip
    BASE=$(basename "$FILE")
    SUGGEST=$(echo "$ALL_FILES" | grep -i "$(echo "$BASE" | sed 's/[_\.]/.*/g')" | head -n 3)

    if [ -n "$SUGGEST" ]; then
      echo "   🔧 Mungkin maksudnya:"
      echo "$SUGGEST" | sed 's/^/     → /'
    fi
  fi
done

