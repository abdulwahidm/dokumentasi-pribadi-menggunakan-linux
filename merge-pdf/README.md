Berikut adalah dokumentasi lengkap langkah-langkah untuk mengubah file teks (`.txt`) dan kumpulan file gambar (`.jpg`) menjadi **satu file PDF** secara otomatis di Ubuntu. Kita akan menggunakan tool `enscript`, `ps2pdf`, `img2pdf`, dan `pdfunite`.

---

# 📄 Dokumentasi: Menggabungkan `.txt` dan Gambar `.jpg` Menjadi Satu File PDF di Ubuntu

## 🎯 Tujuan

Menghasilkan satu file PDF yang terdiri dari:

1. Halaman pertama: isi file `_chat.txt`
2. Halaman-halaman selanjutnya: semua file `.jpg` di folder yang sama

---

## ✅ 1. Persiapan: Install Semua Tools

Buka terminal dan jalankan:

```bash
sudo apt update
sudo apt install enscript ghostscript img2pdf poppler-utils
```

---

## ✅ 2. Struktur Folder (Contoh)

Pastikan struktur folder kamu seperti ini:

```
project-folder/
├── _chat.txt
├── 00000013-photo.jpg
├── 00000014-photo.jpg
└── ... (gambar lainnya)
```

> Catatan: Gambar harus berformat `.jpg`

---

## ✅ 3. Langkah-langkah

### 🔹 A. Ubah File `_chat.txt` Menjadi PDF

```bash
enscript _chat.txt -o - | ps2pdf - chat.pdf
```

Hasil: `chat.pdf`

---

### 🔹 B. Ubah Semua Gambar `.jpg` Menjadi Satu File PDF

```bash
img2pdf $(ls *.jpg | sort) -o images.pdf
```

Hasil: `images.pdf`

---

### 🔹 C. Gabungkan `chat.pdf` dan `images.pdf` Menjadi Final Output

```bash
pdfunite chat.pdf images.pdf output_final.pdf
```

Hasil akhir: `output_final.pdf`

---

## 🧪 Contoh One-Liner (Sekali Jalan)

```bash
enscript _chat.txt -o - | ps2pdf - chat.pdf && img2pdf $(ls *.jpg | sort) -o images.pdf && pdfunite chat.pdf images.pdf output_final.pdf
```

---

## 📝 Tambahan: Script Otomatis (`gabung.sh`)

Simpan script ini sebagai file bernama `gabung.sh`:

```bash
#!/bin/bash

# Ubah file txt ke PDF
enscript _chat.txt -o - | ps2pdf - chat.pdf

# Gabungkan semua jpg ke dalam satu PDF
img2pdf $(ls *.jpg | sort) -o images.pdf

# Gabungkan keduanya menjadi output final
pdfunite chat.pdf images.pdf output_final.pdf

echo "Berhasil: File akhir adalah output_final.pdf"
```

Jalankan script dengan:

```bash
chmod +x gabung.sh
./gabung.sh
```

---

## ✅ Hasil Akhir

* `chat.pdf` → hasil dari `_chat.txt`
* `images.pdf` → gabungan semua gambar
* `output_final.pdf` → dokumen gabungan lengkap (siap dikirim atau dicetak)

---

Jika kamu ingin saya buatkan file `.md` atau `.pdf` dokumentasi ini, tinggal bilang.
