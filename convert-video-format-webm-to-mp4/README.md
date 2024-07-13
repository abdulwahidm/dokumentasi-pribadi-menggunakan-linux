# Convert WebM to MP4 on Ubuntu

## Scenario
Saya menggunakan aplikasi screencast bawaan di Ubuntu untuk merekam layar saya. Output dari aplikasi tersebut adalah video dengan format `.webm`. Namun, format WebM memiliki beberapa kelemahan:

- **Kompatibilitas**: Tidak semua pemutar video atau perangkat mendukung format WebM.
- **Pengeditan**: Banyak perangkat lunak pengeditan video yang tidak mendukung format WebM secara langsung.
- **Streaming**: Beberapa platform streaming lebih memilih format MP4 karena dukungan yang lebih luas dan kompatibilitas dengan berbagai codec.

Untuk mengatasi masalah ini, saya ingin mengubah format video dari WebM ke MP4 yang memiliki beberapa keunggulan:

- **Kompatibilitas Luas**: MP4 didukung oleh hampir semua perangkat dan pemutar video.
- **Pengeditan Mudah**: Banyak perangkat lunak pengeditan video yang mendukung format MP4.
- **Efisiensi Streaming**: MP4 lebih efisien untuk streaming di banyak platform.

## Prerequisites
Pastikan Anda telah menginstal `ffmpeg` di sistem Ubuntu Anda. Anda dapat menginstalnya dengan perintah berikut:

```bash
sudo apt update
sudo apt install ffmpeg
```

## Conversion Process  

### Step 1: Check the Original Video Dimensions
Pertama, periksa dimensi video asli untuk memastikan bahwa lebar dan tinggi video dapat dibagi dengan 2, yang merupakan persyaratan untuk encoder libx264.

```bash
ffmpeg -i input.webm
```

### Step 2: Convert WebM to MP4 with Scaling
Jika dimensi video tidak bisa dibagi dengan 2, Anda bisa menyesuaikan ukurannya menggunakan filter scale. Ini memastikan lebar dan tinggi video adalah angka genap.

```bash
ffmpeg -i input.webm -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" output.mp4
```

### Step 3: Convert WebM to MP4 with Cropping (Optional)
Sebagai alternatif, Anda bisa melakukan cropping pada video jika lebih cocok untuk kebutuhan Anda.

```bash
ffmpeg -i input.webm -vf "crop=trunc(iw/2)*2:trunc(ih/2)*2" output.mp4
```

## Troubleshooting  
Jika Anda menemui kesalahan saat konversi, berikut adalah beberapa langkah pemecahan masalah yang dapat membantu:

``` Error: width not divisible by 2```
Pastikan Anda menggunakan filter scale atau crop untuk mengubah dimensi video sehingga dapat dibagi dengan 2.

```Error: File not found```
Pastikan path ke file input benar dan file tersebut ada.

```Performance Issues```
Jika konversi video membutuhkan waktu lama, pastikan sistem Anda memiliki sumber daya yang cukup atau coba konversi pada mesin yang lebih kuat.


## Kesimpulan
Mengonversi video dari format WebM ke MP4 di Ubuntu sangat mudah dengan menggunakan `ffmpeg`. Format MP4 menawarkan kompatibilitas yang lebih luas, membuatnya lebih mudah untuk diedit dan distreaming. Dengan mengikuti langkah-langkah di atas, Anda dapat dengan mudah mengonversi video Anda untuk memenuhi kebutuhan Anda dalam berbagai aplikasi dan platform.


Dengan tambahan ini, README.md Anda mencakup langkah-langkah konversi, pemecahan masalah yang umum, dan kesimpulan yang membantu pengguna memahami manfaat dari proses konversi tersebut.


## Catatan Tambahan
- Jika Anda ingin mengompres video atau mengubah codec saat konversi, Anda mungkin perlu menyesuaikan perintah `ffmpeg` sesuai dengan kebutuhan spesifik Anda.
- Pastikan untuk menguji video hasil konversi untuk memastikan bahwa kualitasnya memenuhi ekspektasi Anda sebelum menggunakan atau mengunggahnya ke platform lain.

Dengan mengikuti panduan ini, Anda dapat memastikan bahwa video Anda kompatibel dengan berbagai perangkat dan platform, memudahkan distribusi dan aksesibilitas.

## Further Reading  
Untuk informasi lebih lanjut tentang ffmpeg dan opsi-opsinya, Anda dapat mengunjungi dokumentasi resmi:

[FFmpeg Documentation](https://ffmpeg.org/ffmpeg.html)
