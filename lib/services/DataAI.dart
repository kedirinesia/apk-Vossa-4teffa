String apiKey ="AIzaSyCH66wal927bMKuOIFvZirUwumd4ih2nt8";
//Content-Type : application/json
String endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
/*
Contoh Body Request:
{
  "contents": [
    {
      "parts": [
        {
          "text": ""
        }
      ]
    }
  ]
}


    Contoh Response :





    {
    "candidates": [
        {
            "content": {
                "parts": [
                    {
                        "text": "```json\n{\n  \"Analisa\": \"Berdasarkan data AspectAverages, siswa menunjukkan kekuatan pada Persiapan (PS) dan Keterampilan Pemecahan Masalah (KP). Kekuatan moderat terlihat pada Fleksibilitas (FS), Tanggung Jawab (TJ), dan Keterampilan Sosial (KS). Area yang perlu ditingkatkan adalah Komunikasi (KOM) yang memiliki nilai terendah.\",\n  \"Saran\": [\n    \"Berikan pelatihan khusus tentang teknik komunikasi efektif, seperti mendengarkan aktif dan menyampaikan pesan dengan jelas.\",\n    \"Fasilitasi kegiatan kelompok yang menekankan pentingnya komunikasi yang baik dalam mencapai tujuan bersama.\",\n    \"Dorong siswa untuk berpartisipasi aktif dalam diskusi kelas dan memberikan presentasi secara teratur.\",\n    \"Berikan umpan balik konstruktif secara individu mengenai kemampuan komunikasi siswa.\",\n    \"Berikan kesempatan kepada siswa untuk melatih keterampilan komunikasi melalui simulasi peran atau studi kasus.\"\n  ]\n}\n```"
                    }
                ],
                "role": "model"
            },
            "finishReason": "STOP",
            "avgLogprobs": -0.283053118773181
        }
    ],
    "usageMetadata": {
        "promptTokenCount": 281,
        "candidatesTokenCount": 198,
        "totalTokenCount": 479,
        "promptTokensDetails": [
            {
                "modality": "TEXT",
                "tokenCount": 281
            }
        ],
        "candidatesTokensDetails": [
            {
                "modality": "TEXT",
                "tokenCount": 198
            }
        ]
    },
    "modelVersion": "gemini-2.0-flash",
    "responseId": "_eHIaJuyJ_uiqtsPl8KuyAU"
}



*/