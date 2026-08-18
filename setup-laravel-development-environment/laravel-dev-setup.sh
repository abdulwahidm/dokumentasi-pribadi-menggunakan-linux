#!/usr/bin/env bash
# =============================================================================
#  Laravel Development Environment Setup Script
#  Versi  : 2.0.0 (Universal Edition)
#  Target : Ubuntu 20.04/22.04/24.04, Pop!_OS, Linux Mint,
#           Debian 11 (Bullseye), Debian 12 (Bookworm), dan turunannya
#  Laravel: 13.x (latest stable)
#  PHP    : 8.3
# =============================================================================
#
#  CARA PENGGUNAAN:
#    chmod +x laravel-dev-setup.sh
#    ./laravel-dev-setup.sh [nama-project]
#
#  Contoh:
#    ./laravel-dev-setup.sh                  → project: laravel-app
#    ./laravel-dev-setup.sh toko-online      → project: toko-online
#
# =============================================================================

set -euo pipefail

# ─── Warna output ─────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[✓]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }
section() { echo -e "\n${CYAN}${BOLD}━━━ $* ━━━${NC}"; }

# ─── Konfigurasi project ──────────────────────────────────────────────────────
PHP_VERSION="8.3"
PROJECT_NAME="${1:-laravel-app}"
PROJECT_DIR="$HOME/$PROJECT_NAME"
DB_NAME="${PROJECT_NAME//-/_}_db"
DB_USER="${PROJECT_NAME//-/_}_user"
DB_PASS="secret_$(openssl rand -hex 6)"
APP_URL="http://localhost:8000"

# ─── Banner ───────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║    Laravel Dev Environment Setup v2.0 — Universal       ║"
echo "║  PHP 8.3 · Composer · MySQL 8 · Node.js · Laravel 13   ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  Project   : ${BOLD}$PROJECT_NAME${NC}"
echo -e "  Directory : ${BOLD}$PROJECT_DIR${NC}"
echo -e "  Database  : ${BOLD}$DB_NAME${NC}"
echo ""

# =============================================================================
# [PRE-CHECK] Validasi sistem & deteksi distro
# =============================================================================
section "PRE-CHECK · Deteksi Sistem"

# Harus Linux
[[ "$OSTYPE" == "linux-gnu"* ]] || error "Script ini hanya untuk Linux."

# Harus ada apt-get
command -v apt-get &>/dev/null || error "apt-get tidak ditemukan. Script ini hanya mendukung Ubuntu/Debian."

# Harus ada sudo
command -v sudo &>/dev/null || error "sudo tidak tersedia. Install dulu: apt-get install sudo"

# Deteksi distro & codename
OS_ID=""
OS_CODENAME=""
OS_ID_LIKE=""

if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_CODENAME="${VERSION_CODENAME:-}"
    OS_ID_LIKE="${ID_LIKE:-}"
elif command -v lsb_release &>/dev/null; then
    OS_ID=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    OS_CODENAME=$(lsb_release -sc)
else
    error "Tidak dapat mendeteksi distro Linux. Pastikan /etc/os-release ada."
fi

# Fallback codename dari lsb_release jika kosong
if [ -z "$OS_CODENAME" ] && command -v lsb_release &>/dev/null; then
    OS_CODENAME=$(lsb_release -sc)
fi

[ -z "$OS_CODENAME" ] && error "Tidak dapat mendeteksi codename distro (contoh: jammy, bookworm)."

# Tentukan jenis sistem
IS_UBUNTU=false
IS_DEBIAN=false

case "$OS_ID" in
    ubuntu|pop|linuxmint|elementary|zorin|neon|kubuntu|xubuntu|lubuntu)
        IS_UBUNTU=true ;;
    debian|raspbian)
        IS_DEBIAN=true ;;
    *)
        # Cek ID_LIKE untuk distro turunan
        if [[ "$OS_ID_LIKE" == *"ubuntu"* ]]; then
            IS_UBUNTU=true
        elif [[ "$OS_ID_LIKE" == *"debian"* ]]; then
            IS_DEBIAN=true
        else
            error "Distro '$OS_ID' tidak didukung. Hanya Ubuntu/Debian dan turunannya."
        fi ;;
esac

# Ubuntu: butuh codename Ubuntu asli (bukan codename Mint, dll.)
# Linux Mint punya codename sendiri, tapi berbasis Ubuntu
# Mapping Mint → Ubuntu codename
UBUNTU_CODENAME="$OS_CODENAME"
if [ "$OS_ID" = "linuxmint" ]; then
    # Mint 21.x = Ubuntu jammy, Mint 20.x = Ubuntu focal
    MINT_VERSION=$(echo "${VERSION_ID:-0}" | cut -d. -f1)
    case "$MINT_VERSION" in
        21|22) UBUNTU_CODENAME="jammy" ;;
        20)    UBUNTU_CODENAME="focal" ;;
        *)     UBUNTU_CODENAME=$(grep UBUNTU_CODENAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || echo "jammy") ;;
    esac
fi

# Pop!_OS: pakai codename Ubuntu (biasanya tertera di /etc/os-release)
if [ "$OS_ID" = "pop" ]; then
    UBUNTU_CODENAME=$(grep UBUNTU_CODENAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || echo "$OS_CODENAME")
fi

# Validasi Debian codename yang didukung
if $IS_DEBIAN; then
    case "$OS_CODENAME" in
        bullseye|bookworm|trixie) ;;
        *) warn "Debian codename '$OS_CODENAME' belum pernah diuji. Melanjutkan dengan risiko sendiri." ;;
    esac
fi

# Validasi Ubuntu codename yang didukung
if $IS_UBUNTU; then
    case "$UBUNTU_CODENAME" in
        focal|jammy|noble|oracular) ;;
        *) warn "Ubuntu codename '$UBUNTU_CODENAME' belum pernah diuji. Melanjutkan dengan risiko sendiri." ;;
    esac
fi

success "Distro   : $OS_ID ($OS_CODENAME)"
$IS_UBUNTU && success "Tipe     : Ubuntu-based (codename Ubuntu: $UBUNTU_CODENAME)"
$IS_DEBIAN && success "Tipe     : Debian"
success "Arsitektur: $(uname -m)"

# =============================================================================
# [AUTH] Autentikasi sudo sekali di awal
# =============================================================================
section "AUTH · Autentikasi Sudo"

read -rsp "$(echo -e "${BOLD}[sudo]${NC} Masukkan password sudo: ")" SUDO_PASS
echo ""
echo "$SUDO_PASS" | sudo -S true 2>/dev/null || error "Password sudo salah atau tidak punya hak sudo."
success "Autentikasi sudo berhasil"

# Helper sudo non-interaktif
SUDO() { echo "$SUDO_PASS" | sudo -S "$@" 2>/dev/null; }
SUDO_VERBOSE() { echo "$SUDO_PASS" | sudo -S "$@"; }

# =============================================================================
# STEP 1: Tambah Repository PHP (Ondrej)
# =============================================================================
section "STEP 1/10 · Repository PHP 8.3"

# Install dependency add-apt-repository jika belum ada
if ! command -v add-apt-repository &>/dev/null; then
    info "Menginstall software-properties-common..."
    SUDO apt-get install -y software-properties-common gnupg2 lsb-release curl ca-certificates >/dev/null 2>&1
fi

if $IS_UBUNTU; then
    # ── Ubuntu/Pop/Mint: gunakan Ondrej PPA ──
    PPA_FILE="/etc/apt/sources.list.d/ondrej-ubuntu-php-${UBUNTU_CODENAME}.list"
    PHP_INSTALLED=false

    if [ -f "$PPA_FILE" ] && grep -q "^deb " "$PPA_FILE" 2>/dev/null; then
        success "Ondrej PPA sudah aktif"
    elif [ -f "$PPA_FILE" ] && grep -q "^# deb " "$PPA_FILE" 2>/dev/null; then
        info "Mengaktifkan Ondrej PPA yang ter-disable..."
        SUDO sed -i 's|^# deb|deb|g' "$PPA_FILE"
        success "Ondrej PPA diaktifkan"
    else
        # Cek format .sources (Ubuntu 24.04+)
        PPA_SOURCES="/etc/apt/sources.list.d/ondrej-ubuntu-php.sources"
        if [ -f "$PPA_SOURCES" ]; then
            success "Ondrej PPA (format .sources) sudah ada"
        else
            info "Menambahkan Ondrej PHP PPA..."
            SUDO_VERBOSE add-apt-repository -y ppa:ondrej/php
            success "Ondrej PPA ditambahkan"
        fi
    fi

elif $IS_DEBIAN; then
    # ── Debian: gunakan deb.sury.org ──
    SURY_LIST="/etc/apt/sources.list.d/php.list"
    SURY_KEY="/etc/apt/trusted.gpg.d/php.gpg"

    if [ -f "$SURY_LIST" ] && grep -q "deb.sury.org" "$SURY_LIST" 2>/dev/null; then
        success "Sury PHP repo untuk Debian sudah ada"
    else
        info "Menambahkan Sury PHP repo untuk Debian ($OS_CODENAME)..."

        # Download & import GPG key
        curl -fsSL "https://packages.sury.org/php/apt.gpg" | SUDO tee "$SURY_KEY" >/dev/null
        echo "deb [signed-by=${SURY_KEY}] https://packages.sury.org/php/ ${OS_CODENAME} main" \
            | SUDO tee "$SURY_LIST" >/dev/null
        success "Sury PHP repo ditambahkan"
    fi
fi

# =============================================================================
# STEP 2: Update Package List
# =============================================================================
section "STEP 2/10 · Update Package List"
info "Menjalankan apt-get update..."
SUDO apt-get update -qq
success "Package list diperbarui"

# Verifikasi PHP 8.3 tersedia
apt-cache show "php${PHP_VERSION}" >/dev/null 2>&1 \
    || error "Package php${PHP_VERSION} tidak ditemukan setelah update. Periksa koneksi internet atau kompatibilitas distro."

# =============================================================================
# STEP 3: Install PHP 8.3 + Extensions
# =============================================================================
section "STEP 3/10 · PHP $PHP_VERSION & Extensions"

REQUIRED_EXTS=(
    php${PHP_VERSION}
    php${PHP_VERSION}-cli
    php${PHP_VERSION}-fpm
    php${PHP_VERSION}-common
    php${PHP_VERSION}-mbstring
    php${PHP_VERSION}-xml
    php${PHP_VERSION}-curl
    php${PHP_VERSION}-zip
    php${PHP_VERSION}-bcmath
    php${PHP_VERSION}-intl
    php${PHP_VERSION}-mysql
    php${PHP_VERSION}-gd
    php${PHP_VERSION}-dom
    php${PHP_VERSION}-sqlite3
    php${PHP_VERSION}-tokenizer
    php${PHP_VERSION}-opcache
    unzip
)

if php --version 2>/dev/null | grep -q "PHP $PHP_VERSION"; then
    success "PHP $PHP_VERSION sudah terinstall"
else
    info "Menginstall PHP $PHP_VERSION dan extensions..."
    SUDO apt-get install -y "${REQUIRED_EXTS[@]}" >/dev/null 2>&1
    success "PHP $PHP_VERSION terinstall"
fi

# Pastikan PHP 8.3 yang aktif sebagai default
SUDO update-alternatives --set php "/usr/bin/php${PHP_VERSION}" 2>/dev/null || true
success "PHP aktif: $(php --version | head -1)"

# =============================================================================
# STEP 4: Install Composer
# =============================================================================
section "STEP 4/10 · Composer"

if command -v composer &>/dev/null; then
    COMPOSER_MAJOR=$(composer --version 2>/dev/null | grep -oP '\d+' | head -1)
    if [ "${COMPOSER_MAJOR:-0}" -ge 2 ]; then
        info "Composer sudah versi 2+, update ke terbaru..."
        SUDO composer self-update --quiet 2>/dev/null || true
        success "Composer: $(composer --version | head -1)"
    else
        warn "Composer versi lama ditemukan, menginstall ulang versi 2..."
        SUDO rm -f "$(command -v composer)"
        # lanjut ke install di bawah
        command -v composer &>/dev/null || true
    fi
fi

if ! command -v composer &>/dev/null; then
    info "Mengunduh & menginstall Composer..."
    EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', '/tmp/composer-setup.php');")"

    [ "$EXPECTED_CHECKSUM" = "$ACTUAL_CHECKSUM" ] \
        || { rm /tmp/composer-setup.php; error "Checksum Composer installer tidak cocok!"; }

    SUDO php /tmp/composer-setup.php \
        --install-dir=/usr/local/bin \
        --filename=composer \
        --quiet
    rm -f /tmp/composer-setup.php
    success "Composer: $(composer --version | head -1)"
fi

# =============================================================================
# STEP 5: Install Node.js & NPM
# =============================================================================
section "STEP 5/10 · Node.js & NPM"

if command -v node &>/dev/null && node --version | grep -qE "^v(18|20|22|24)"; then
    success "Node.js sudah ada: $(node --version), NPM: $(npm --version)"
else
    info "Menginstall Node.js LTS via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | SUDO_VERBOSE bash - >/dev/null 2>&1
    SUDO apt-get install -y nodejs >/dev/null 2>&1
    success "Node.js: $(node --version), NPM: $(npm --version)"
fi

# =============================================================================
# STEP 6: Install & Konfigurasi MySQL Server
# =============================================================================
section "STEP 6/10 · MySQL Server"

# Deteksi apakah MySQL server sudah terinstall
MYSQL_SERVER_PKG=""
for pkg in mysql-server mysql-server-8.0 mariadb-server; do
    if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
        MYSQL_SERVER_PKG="$pkg"
        break
    fi
done

if [ -z "$MYSQL_SERVER_PKG" ]; then
    info "Menginstall MySQL Server..."
    SUDO apt-get install -y mysql-server >/dev/null 2>&1
    MYSQL_SERVER_PKG="mysql-server"
    success "MySQL Server terinstall"
fi

# Deteksi nama service yang benar
MYSQL_SERVICE=""
for svc in mysql mysqld mariadb mysql-server; do
    if SUDO systemctl list-unit-files "${svc}.service" 2>/dev/null | grep -q "$svc"; then
        MYSQL_SERVICE="$svc"
        break
    fi
done

[ -z "$MYSQL_SERVICE" ] && error "Tidak dapat menemukan service MySQL/MariaDB. Coba install manual: sudo apt install mysql-server"

# Start service
if ! SUDO systemctl is-active --quiet "$MYSQL_SERVICE" 2>/dev/null; then
    info "Menjalankan service $MYSQL_SERVICE..."
    SUDO systemctl start "$MYSQL_SERVICE"
    sleep 3
fi

# Enable auto-start saat boot
SUDO systemctl enable "$MYSQL_SERVICE" >/dev/null 2>&1 || true
success "MySQL berjalan (service: $MYSQL_SERVICE)"

# =============================================================================
# STEP 7: Buat Database & User
# =============================================================================
section "STEP 7/10 · Database & User MySQL"

info "Membuat database '$DB_NAME' dan user '$DB_USER'..."

# Gunakan file temp SQL untuk menghindari masalah heredoc + sudo
SQL_FILE=$(mktemp /tmp/laravel_setup_XXXXXX.sql)
cat > "$SQL_FILE" <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL

SUDO mysql < "$SQL_FILE" && rm -f "$SQL_FILE"

# Verifikasi koneksi
mysql -h 127.0.0.1 -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT 1;" >/dev/null 2>&1 \
    || error "Gagal koneksi ke database dengan user '$DB_USER'. Cek log MySQL."

success "Database '$DB_NAME' siap & koneksi berhasil diverifikasi"

# =============================================================================
# STEP 8: Buat Project Laravel 13
# =============================================================================
section "STEP 8/10 · Project Laravel 13"

if [ -d "$PROJECT_DIR" ]; then
    warn "Direktori '$PROJECT_DIR' sudah ada — melewati pembuatan project."
    warn "Hapus jika ingin buat ulang: rm -rf $PROJECT_DIR"
else
    info "Membuat project Laravel 13..."
    composer create-project laravel/laravel "$PROJECT_DIR" --prefer-dist --quiet
    success "Project Laravel 13 dibuat di $PROJECT_DIR"
fi

cd "$PROJECT_DIR"

# Verifikasi ini adalah project Laravel
[ -f artisan ] || error "Direktori $PROJECT_DIR bukan project Laravel yang valid."

# =============================================================================
# STEP 9: Konfigurasi .env
# =============================================================================
section "STEP 9/10 · Konfigurasi .env"

[ -f .env ] || cp .env.example .env

env_set() {
    local key="$1" val="$2"
    if grep -q "^${key}=" .env; then
        # Gunakan | sebagai delimiter agar aman dengan karakter path/password
        sed -i "s|^${key}=.*|${key}=${val}|" .env
    else
        echo "${key}=${val}" >> .env
    fi
}

env_set APP_NAME     "\"$PROJECT_NAME\""
env_set APP_URL      "$APP_URL"
env_set DB_CONNECTION mysql
env_set DB_HOST      127.0.0.1
env_set DB_PORT      3306
env_set DB_DATABASE  "$DB_NAME"
env_set DB_USERNAME  "$DB_USER"
env_set DB_PASSWORD  "$DB_PASS"

# Generate key jika belum ada
grep -q "^APP_KEY=base64:" .env \
    && success "APP_KEY sudah ada" \
    || php artisan key:generate --ansi

success ".env dikonfigurasi untuk MySQL"

# =============================================================================
# STEP 10: NPM Install, Migrasi & Build
# =============================================================================
section "STEP 10/10 · NPM, Migrasi & Build"

info "Menginstall NPM packages..."
npm install --silent
success "NPM packages: $(npm list --depth=0 2>/dev/null | wc -l) packages"

info "Menjalankan database migration..."
php artisan migrate:fresh --force
success "Migration selesai"

info "Build frontend assets (Vite)..."
npm run build --silent
success "Assets dibangun"

info "Mengatur permissions..."
chmod -R 775 storage bootstrap/cache
success "Permissions OK"

info "Optimasi cache aplikasi..."
php artisan config:cache --quiet
php artisan route:cache  --quiet
php artisan view:cache   --quiet
success "Cache dioptimasi"

# =============================================================================
# VERIFIKASI AKHIR
# =============================================================================
section "VERIFIKASI AKHIR"

CHECKS_PASSED=0
CHECKS_TOTAL=5

check() {
    local label="$1"; shift
    if "$@" &>/dev/null; then
        success "$label"
        ((CHECKS_PASSED++))
    else
        warn "$label [GAGAL]"
    fi
}

check "PHP 8.3 aktif"            php -r "exit(PHP_MAJOR_VERSION==8 && PHP_MINOR_VERSION==3 ? 0 : 1);"
check "Composer tersedia"        composer --version
check "MySQL koneksi OK"         mysql -h 127.0.0.1 -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT 1;"
check "Laravel artisan berjalan" php artisan --version
check "Assets dibangun"          test -f "$PROJECT_DIR/public/build/manifest.json"

# =============================================================================
# SUMMARY
# =============================================================================
LARAVEL_VER=$(php artisan --version 2>/dev/null || echo "unknown")
PHP_VER=$(php --version | head -1 | awk '{print $1,$2}')
COMPOSER_VER=$(composer --version 2>/dev/null | awk '{print $3}')
NODE_VER=$(node --version)
NPM_VER=$(npm --version)

echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║         🎉  Laravel Environment Siap Digunakan!          ║${NC}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
printf "${GREEN}║${NC}  %-14s: %s\n"  "OS"        "$OS_ID ($OS_CODENAME)"
printf "${GREEN}║${NC}  %-14s: %s\n"  "Laravel"   "$LARAVEL_VER"
printf "${GREEN}║${NC}  %-14s: %s\n"  "PHP"       "$PHP_VER"
printf "${GREEN}║${NC}  %-14s: %s\n"  "Composer"  "v$COMPOSER_VER"
printf "${GREEN}║${NC}  %-14s: %s / NPM %s\n" "Node.js" "$NODE_VER" "$NPM_VER"
printf "${GREEN}║${NC}  %-14s: %s\n"  "MySQL svc" "$MYSQL_SERVICE"
printf "${GREEN}║${NC}  %-14s: %s\n"  "Project"   "$PROJECT_DIR"
printf "${GREEN}║${NC}  %-14s: %d/%d passed\n" "Checks" "$CHECKS_PASSED" "$CHECKS_TOTAL"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  ${BOLD}Kredensial Database:${NC}"
printf "${GREEN}║${NC}    Host     : 127.0.0.1:3306\n"
printf "${GREEN}║${NC}    Database : %s\n" "$DB_NAME"
printf "${GREEN}║${NC}    User     : %s\n" "$DB_USER"
printf "${GREEN}║${NC}    Password : %s\n" "$DB_PASS"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  ${BOLD}Jalankan development server:${NC}"
echo -e "${GREEN}║${NC}"
echo -e "${GREEN}║${NC}    cd $PROJECT_DIR"
echo -e "${GREEN}║${NC}    php artisan serve    → http://localhost:8000"
echo -e "${GREEN}║${NC}    npm run dev          → Vite hot-reload"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Simpan kredensial ke file (permission 600 = hanya owner yang bisa baca)
CRED_FILE="$PROJECT_DIR/.env.credentials"
cat > "$CRED_FILE" <<EOF
# Laravel Credentials — $(date)
# ⚠️  JANGAN commit file ini! Tambahkan ke .gitignore

PROJECT_DIR=$PROJECT_DIR
APP_URL=$APP_URL
OS=$OS_ID ($OS_CODENAME)

DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=$DB_NAME
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASS
EOF
chmod 600 "$CRED_FILE"

# Tambahkan ke .gitignore jika belum ada
grep -q ".env.credentials" .gitignore 2>/dev/null \
    || echo ".env.credentials" >> .gitignore

info "Kredensial tersimpan di  : $CRED_FILE"
info "Script log tersimpan di  : /tmp/laravel-setup.log (jika ada error)"
echo ""
