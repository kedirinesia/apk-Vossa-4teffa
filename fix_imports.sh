#!/bin/bash
# Script untuk otomatis menambahkan import hilang di file Dart

echo "🔧 Menambahkan import hilang..."

# Tambahkan import sesuai kebutuhan per file
declare -A imports
imports["lib/main.dart"]="import 'package:flutter/material.dart';"
imports["lib/pages/student_detail_page.dart"]="import 'package:flutter/material.dart';\nimport 'package:fl_chart/fl_chart.dart';"
imports["lib/pages/form_page.dart"]="import 'package:flutter/material.dart';\nimport '../models/student.dart';"
imports["lib/pages/observer_form_page.dart"]="import 'package:flutter/material.dart';\nimport '../models/observer_data.dart';\nimport 'instrument_selection_page.dart';"
imports["lib/pages/assessment_page.dart"]="import 'package:flutter/material.dart';\nimport '../models/observer_data.dart';\nimport '../data/instrument_data.dart';"
imports["lib/pages/result_page.dart"]="import 'package:flutter/material.dart';\nimport 'package:fl_chart/fl_chart.dart';"
imports["lib/pages/Instrument_selection_page.dart"]="import 'package:flutter/material.dart';\nimport '../models/observer_data.dart';"
imports["lib/pages/student_form_page.dart"]="import 'package:flutter/material.dart';\nimport '../models/student.dart';\nimport 'assessment_page.dart';\nimport '../models/observer_data.dart';"
imports["lib/pages/cover_page.dart"]="import 'package:flutter/material.dart';\nimport 'package:lottie/lottie.dart';"

for file in "${!imports[@]}"; do
  if [ -f "$file" ]; then
    for line in $(echo -e "${imports[$file]}"); do
      if ! grep -q "$line" "$file"; then
        sed -i '' "1s|^|$line\n|" "$file"
        echo "✅ Ditambahkan $line ke $file"
      fi
    done
  else
    echo "⚠️ File $file tidak ditemukan"
  fi
done

echo "🚀 Selesai menambahkan import hilang!"

