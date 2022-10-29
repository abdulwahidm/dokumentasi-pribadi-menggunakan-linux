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
swapfile adalah program yang tersedia pada ubuntu untuk membuat atau mengelola virtual RAM dengan mengambil sumber daya tersedia pada disk. Namun, dalam kasus ini alangkah baiknya
perangkat komputer sudah menggunakan SSD sebagai memori storagenya. Sebab jika masih menggunakan Hard-drive akan sangat signifikan sekali perbedaannya dengan native-RAM dari sisi kecepatan jika ia dimanfaatkan sebagai virtual RAM. 

Adapun langkah-langkah untuk menjalankan methode swapfile saya sertakan linknya dibawah ini:

https://www.addictivetips.com/ubuntu-linux-tips/ubuntu-increase-swap-guide/

Setelah melakukan cara tsb kini perangkat komputer saya tidak lagi mengalami hardware exception. 
Saya pun tidak perlu khawatir lagi saat harus menjalan program komputer secara multitasking.









