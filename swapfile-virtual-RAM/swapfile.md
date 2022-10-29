- # Problem :
- linux ubuntu 22.04

Saya menggunakan perangkat komputer yang memiliki memori RAM dengan kapasitas 4GB.
Ketika komputer digunakan untuk membuka beberapa tab pada browser, 
sambil membubka IDE atau text editor, pemutar audio secara bersamaan (multitasking)
seringkali komputer saya berhenti bekerja karena kehabisan ruang pada memori RAM. 
Kemudian setelah beberapa saat mengalami freeze moment, secara otomatis semua 
program aplikasi yang saya jalankan tersebut di force-quit oleh system. 
Dan layar kembali pada tampilan awal desktop seperti baru saat selesai booting.

Tentu solusi termudah adalah dengan menambahkan atau upgrade fisik RAM 
dengan kapasitas yang lebih besar. Namun, alih-alih melakukan upgrade RAM. Pada kasus ini saya mencari alternatif selain menyelesaikan masalah ini pada wilayah  hardware belaka.

- # Solusi: 
- swapfile adalah program yang tersedia pada ubuntu untuk membuat atau mengelola virtual RAM dengan mengambil sumber daya tersedia pada disk. Namun, dalam kasus ini alangkah baiknya
perangkat komputer sudah menggunakan memori storage yang berbentuk SSD. Sebab jika masih menggunakan Hard-drive sebagai memori penyimpanan akan signikan sekali perbedaannya dengan RAM dari sisi kecepatan untuk dimanfaatkan sebagai virtual RAM. 

Adapun untuk langkah-langkah untuk menjalankan cara ini saya sertakan link dibawah ini:

https://www.addictivetips.com/ubuntu-linux-tips/ubuntu-increase-swap-guide/

Setelah melakukan cara tsb kini perangkat komputer saya tidak lagi mengalami hardware exception. 
Saya pun tidak perlu khawatir lagi saat harus menjalan program komputer secara multitasking.









