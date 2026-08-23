# pdf-organizer — Skill opencode untuk Memorganisasi Koleksi PDF secara Aman & Auditable

> **Let AI reason about documents. Let deterministic code control the filesystem.**

Skill [opencode](https://opencode.ai) yang mengubah tumpukan PDF yang berantakan menjadi koleksi terklasifikasi — tanpa pernah memindahkan, menimpa, atau menghapus satu byte pun sebelum Anda menyetujuinya secara eksplisit.

---

## 1. Kenapa Skill Ini Dibuat

Skill ini lahir dari masalah yang sangat umum: folder `Downloads/`, `Documents/`, atau folder koleksi PDF lain yang berisi **ratusan hingga ribuan PDF dari berbagai sumber** — ebook, dokumentasi teknis, sertifikat, faktur, materi kursus, hasil scan, artikel jurnal, dokumen kependudukan, sampai ekspor chat — semuanya bercampur tanpa struktur dan sulit dicari kembali.

Percobaan "suruh AI pindahin file" klasik berakhir buruk: LLM menebak kategori dari nama file, langsung memindahkan ratusan file sekaligus, dan banyak yang salah tempat. Dari situ disusun desain kebalikannya:

| Masalah di lapangan | Solusi desain |
|---|---|
| `React.pdf` bisa jadi ebook/kursus/dokumentasi/paper — nama file saja tidak cukup | Hierarki evidence: metadata → struktur dokumen → isi teks → judul → penulis → filename → konteks direktori |
| Nama file sering menyesatkan (file `novel.pdf` ternyata bukan novel) | Fase `/pdf-review`: sampling ulang isi teks untuk semua kasus mencurigakan |
| Dokumen akademik/jurnal sering salah masuk folder ebook | Deteksi ISSN/jurnal + reclassifikasi berbasis bukti |
| Duplikat identik menumpuk bertahun-tahun dari unduhan berulang | SHA256 per file; duplikat **dilaporkan, tidak pernah dihapus** |
| Dokumen operasional sama tersalin dengan beberapa nama berbeda | Klastering nomor dokumen + similarity teks |
| PDF hasil scan tidak punya text layer | Ditandai `OCR_CANDIDATE`, confidence dipatok maksimal `REVIEW_REQUIRED` |
| LLM memindahkan ribuan file tanpa izin | **Approval gate wajib** — eksekusi hanya melalui manifest yang disetujui |

### Hasil pada pilot internal

Skill ini divalidasi pada koleksi privat berskala ~1000 file (multi-GB) yang berisi campuran semua jenis di atas. Hasilnya: seluruh koleksi terpetakan tanpa satu file pun hilang atau tertimpa, puluhan grup duplikat teridentifikasi, belasan salah klasifikasi tertangkap di fase review, dan eksekusi berjalan dengan nol konflik serta verifikasi hash dua arah. Angka detail sengaja tidak dipublikasikan karena berkaitan dengan isi koleksi pribadi.

---

## 2. Prinsip Desain

1. **Read-only sampai disetujui.** Sebelum approval, skill hanya boleh *membaca* PDF dan *menulis* ke `_ai-organizer/`. Pindah/rename/hapus/timpa = dilarang keras.
2. **Manifest adalah batas otorisasi.** Tidak ada mutasi filesystem di luar `classification.json` → `execution.json`.
3. **Confidence policy ketat:**

   ```text
   0.95–1.00  AUTO              boleh dieksekusi setelah approval
   0.85–0.94  REVIEW_OPTIONAL   butuh persetujuan eksplisit
   0.70–0.84  REVIEW_REQUIRED   butuh persetujuan eksplisit
   < 0.70     UNKNOWN           tidak akan pernah dipindah otomatis
   ```

4. **Deterministik dulu, LLM kemudian.** ISBN/publisher/TOC/struktur bab dideteksi aturan; LLM menyimpulkan makna dari bukti — bukan menebak.
5. **Verifiable & reversible.** SHA256 dihitung ulang sebelum dan sesudah tiap perpindahan; `execution.json` adalah rekaman rollback permanen.
6. **Ketika ragu: DO NOTHING.** Akurasi > automation rate.

### Pipeline

```text
DISCOVER → INVENTORY → EXTRACT → CLASSIFY → DEDUPLICATE → REVIEW
        → MANIFEST → HUMAN APPROVAL → EXECUTE → VERIFY → REPORT
```

---

## 3. Instalasi

### Sebagai skill global (semua project)

```bash
mkdir -p ~/.config/opencode/skills/pdf-organizer
cp SKILL.md ~/.config/opencode/skills/pdf-organizer/SKILL.md
```

### Sebagai skill per-project

```bash
mkdir -p .opencode/skills/pdf-organizer
cp SKILL.md .opencode/skills/pdf-organizer/SKILL.md
```

### Slash commands (opsional tapi disarankan)

```bash
mkdir -p .opencode/command          # di root folder koleksi PDF Anda
cp commands/*.md .opencode/command/
```

Restart opencode setelah instal (config hanya dimuat saat startup).

**Dependensi:** `poppler-utils` (`pdfinfo`, `pdftotext`), `sha256sum`.

```bash
# Debian/Ubuntu
sudo apt install poppler-utils
```

---

## 4. Cara Pakai

Dari folder koleksi PDF Anda:

```bash
cd ~/Documents/koleksi-pdf  # folder koleksi Anda
opencode
```

Lalu jalankan 4 fase berurutan:

| Command | Fase | Boleh menulis? |
|---|---|---|
| `/pdf-inventory` | Scan rekursif, metadata, SHA256, deteksi scan/corrupt/duplikat | Hanya `_ai-organizer/` |
| `/pdf-classify` | Klasifikasi berbasis bukti + confidence + tujuan usulan | Hanya `_ai-organizer/` |
| `/pdf-review` | Audit kedua: misfile, duplikat kandidat, kontradiksi | Hanya `_ai-organizer/` |
| `/pdf-organize` | Eksekusi **hanya operasi AUTO yang Anda setujui** | Memindahkan file ✓ |

Atau cukup bicara natural: *"organize my PDFs"* — skill akan aktif otomatis.

### Alur approval gate

```text
/pdf-classify selesai
      ↓
READY FOR APPROVAL - No filesystem mutations have been performed.
      ↓
Anda memilih scope:
  [1] AUTO saja            ← direkomendasikan
  [2] AUTO + REVIEW_OPTIONAL
  [3] + REVIEW_REQUIRED    ← baca review.md dulu
  [4] Batalkan
      ↓
/pdf-organize dieksekusi dengan verifikasi hash ganda
```

### Taksonomi default

```text
ebook · work · technical · documentation · course · research
finance · legal · reference · personal · unknown
```

Tujuan akhir selalu `category/subcategory/nama-file-asli.pdf` — **nama file tidak pernah diubah**.

---

## 5. Output di Folder Koleksi

```text
koleksi-pdf/                      # folder koleksi Anda (nama bebas)
├── _ai-organizer/
│   ├── manifests/
│   │   ├── inventory.json        # 1 record/PDF: path, sha256, metadata, status
│   │   ├── classification.json   # kategori + confidence + evidence + relasi duplikat
│   │   └── execution.json        # REKAMAN ROLLBACK — jangan dihapus
│   └── reports/
│       ├── inventory.md
│       ├── classification.md
│       ├── review.md
│       └── execution.md
├── ebook/programming/…
├── legal/certificate/…
└── unknown/                      # sengaja disisakan: tak terbaca / butuh keputusan manusia
```

Contoh record klasifikasi:

```json
{
  "source": "unknown/certificate-x7f2.pdf",
  "source_sha256": "abc123…",
  "destination": "legal/certificate/certificate-x7f2.pdf",
  "category": "legal",
  "subcategory": "certificate",
  "confidence": 0.96,
  "status": "AUTO",
  "action": "MOVE",
  "evidence": [
    "extracted text: Certificate of Course Completion",
    "issuer metadata: Online Learning Platform"
  ],
  "duplicate_status": "NONE"
}
```

---

## 6. Jaminan Keamanan

- **Tidak ada file yang pernah dihapus** — duplikat hanya dilaporkan.
- **Tidak ada overwrite** — destinasi terisi konten sama → `SKIPPED_DUPLICATE_EXACT`; beda konten → `CONFLICT`.
- **Abort per-operasi** jika SHA256 source berubah sejak inventory.
- **Verifikasi pasca-pindah**: hash destination harus identik, else `VERIFICATION_FAILED`.
- **Rollback** dapat direkonstruksi 100% dari `execution.json` (path asal, path tujuan, kedua hash, timestamp).
- Integrity check pada pilot internal: **jumlah file sebelum == jumlah sesudah**, nol kehilangan.

---

## 7. Batasan yang Dikenali Secara Jujur

- PDF hasil scan (image-only) tidak bisa diklasifikasi meyakinkan tanpa OCR — skill sengaja **tidak** melakukan OCR massal; ia menandainya `UNKNOWN` dan membiarkan keputusan pada Anda.
- Kualitas klasifikasi bergantung kualitas evidence; dokumen tanpa metadata/teks/nama bermakna akan tetap di `unknown/`.
- Skill ini mengatur *filesystem*, bukan isi PDF — tidak ada metadata PDF yang dimodifikasi.

---

## 8. Struktur Repo

```text
.
├── README.md                  # dokumen ini
├── SKILL.md                   # isi skill (instal ke folder skills/)
└── commands/                  # slash commands (instal ke .opencode/command/)
    ├── pdf-inventory.md
    ├── pdf-classify.md
    ├── pdf-review.md
    └── pdf-organize.md
```

## 9. Lisensi

MIT — gunakan, ubah, dan sesuaikan taksonominya untuk koleksi Anda sendiri.
