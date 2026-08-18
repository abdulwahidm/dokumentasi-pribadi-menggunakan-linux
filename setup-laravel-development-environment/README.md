# 🚀 Setup Laravel Development Environment di Linux

Dokumentasi lengkap untuk menyiapkan lingkungan pengembangan **Laravel 13** (versi stabil terbaru) di sistem Linux berbasis Ubuntu/Debian menggunakan script otomatis.

> **Dibuat & diuji pada:** Pop!_OS 22.04 LTS — Agustus 2026

---

## 📦 Yang Akan Diinstall

| Komponen | Versi | Keterangan |
|----------|-------|------------|
| **PHP** | 8.3 | Via Ondrej PPA (Ubuntu) / Sury (Debian) |
| **Composer** | 2.x (terbaru) | Package manager PHP |
| **Laravel** | 13.x (terbaru) | Framework PHP |
| **MySQL** | 8.0 | Database server |
| **Node.js** | LTS | Runtime JavaScript |
| **NPM** | Latest | Package manager Node |
| **Vite** | (bundled) | Build tool frontend |

---

## 🖥️ Kompatibilitas

| Distro | Versi | Status |
|--------|-------|--------|
| Pop!_OS | 22.04 | ✅ Tested |
| Ubuntu | 20.04, 22.04, 24.04 | ✅ Supported |
| Linux Mint | 20.x, 21.x | ✅ Supported |
| Debian | 11 (Bullseye), 12 (Bookworm) | ✅ Supported |
| Elementary OS | 6.x, 7.x | ✅ Supported |
| Zorin OS | Latest | ✅ Supported |
| Arch / Fedora / RHEL | - | ❌ Tidak didukung |

---

## ⚡ Cara Penggunaan Cepat

### 1. Download script

```bash
curl -O https://raw.githubusercontent.com/abdulwahidm/dokumentasi-pribadi-menggunakan-linux/main/setup-laravel-development-environment/laravel-dev-setup.sh
```

### 2. Beri izin eksekusi

```bash
chmod +x laravel-dev-setup.sh
```

### 3. Jalankan

```bash
# Dengan nama project default (laravel-app)
./laravel-dev-setup.sh

# Dengan nama project custom
./laravel-dev-setup.sh nama-project-anda
./laravel-dev-setup.sh toko-online
./laravel-dev-setup.sh blog-pribadi
```

> Script akan meminta password sudo **satu kali** di awal, lalu berjalan otomatis sampai selesai.

---

## 📋 Langkah-langkah yang Dilakukan Script

```
STEP 1/10  Deteksi distro & tambah PHP repository yang sesuai
STEP 2/10  Update package list (apt-get update)
STEP 3/10  Install PHP 8.3 + semua extension Laravel
STEP 4/10  Install / update Composer
STEP 5/10  Install Node.js LTS + NPM (jika belum ada)
STEP 6/10  Install & start MySQL Server
STEP 7/10  Buat database & user MySQL khusus project
STEP 8/10  Buat project Laravel 13 via composer create-project
STEP 9/10  Konfigurasi .env (DB, APP_URL, APP_KEY)
STEP 10/10 npm install + migrate + npm run build + optimasi cache
```

---

## 🗂️ Struktur Project yang Dihasilkan

```
~/nama-project/
├── app/              ← Kode utama aplikasi (Models, Controllers, dll.)
├── bootstrap/        ← Bootstrap & cache framework
├── config/           ← File konfigurasi
├── database/
│   └── migrations/   ← File migrasi database
├── public/
│   └── build/        ← Assets yang sudah di-build (Vite)
├── resources/
│   ├── css/          ← Stylesheet sumber
│   ├── js/           ← JavaScript sumber
│   └── views/        ← Template Blade
├── routes/
│   └── web.php       ← Definisi route web
├── storage/          ← Log, cache, file upload
├── .env              ← Konfigurasi environment (jangan di-commit!)
├── .env.credentials  ← Kredensial DB (jangan di-commit!)
├── artisan           ← CLI Laravel
├── composer.json
└── package.json
```

---

## 🚦 Menjalankan Server Development

Setelah setup selesai:

```bash
# Masuk ke folder project
cd ~/laravel-app

# Jalankan PHP development server
php artisan serve
# → Buka browser: http://localhost:8000

# Jalankan Vite untuk hot-reload frontend (terminal terpisah)
npm run dev
```

---

## 🗃️ Informasi Database

Setiap project mendapat database dan user MySQL tersendiri secara otomatis:

| Item | Nilai |
|------|-------|
| Host | `127.0.0.1` |
| Port | `3306` |
| Database | `{nama_project}_db` |
| User | `{nama_project}_user` |
| Password | *(acak, tersimpan di `.env` dan `.env.credentials`)* |

Kredensial lengkap tersimpan di:
```bash
cat ~/nama-project/.env.credentials
```

---

## 🛠️ Perintah Laravel yang Sering Dipakai

```bash
# Buat Model + Migration + Controller sekaligus
php artisan make:model NamaModel -mcr

# Buat Controller
php artisan make:controller NamaController

# Jalankan migration
php artisan migrate

# Rollback migration terakhir
php artisan migrate:rollback

# Buat & jalankan seeder
php artisan make:seeder NamaSeeder
php artisan db:seed

# Masuk ke Laravel REPL (Tinker)
php artisan tinker

# Lihat semua route
php artisan route:list

# Clear semua cache
php artisan optimize:clear
```

---

## ❓ Troubleshooting

### PHP version salah setelah install

```bash
sudo update-alternatives --config php
# Pilih PHP 8.3 dari daftar
```

### MySQL tidak bisa connect

```bash
sudo systemctl status mysql
sudo systemctl start mysql
sudo mysql -e "SELECT User, Host FROM mysql.user;"
```

### Permission denied di storage/

```bash
chmod -R 775 storage bootstrap/cache
```

### Port 8000 sudah dipakai

```bash
php artisan serve --port=8080
```

### Composer out of memory

```bash
COMPOSER_MEMORY_LIMIT=-1 composer install
```

---

## 📁 File dalam Folder Ini

| File | Keterangan |
|------|------------|
| `README.md` | Dokumentasi ini |
| `laravel-dev-setup.sh` | Script setup otomatis (v2.0 Universal) |

---

## 🔗 Referensi

- [Laravel Documentation](https://laravel.com/docs)
- [PHP 8.3 Release Notes](https://www.php.net/releases/8.3/)
- [Ondrej PPA (Ubuntu)](https://launchpad.net/~ondrej/+archive/ubuntu/php)
- [Sury PHP Repo (Debian)](https://packages.sury.org/php/)
- [Composer](https://getcomposer.org/)

---

*Dibuat dengan ❤️ — [dokumentasi-pribadi-menggunakan-linux](https://github.com/abdulwahidm/dokumentasi-pribadi-menggunakan-linux)*
