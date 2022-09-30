#Problem:

Ketika saya membuka file video dengan format mp4, mkv, avi dengan menggunakan aplikasi bawaan Ubuntu 22.04 saya mendapatkan tampilan visual, melainkan hanya audio dengan layar blank hitam. Diikuti dengan munculnya pesan pada aplikasi Software & Update yang berisi keterangan (screnshot file terlampir pada direktori yang sama di repo ini):
 ```H.264(High Profile) decoder is required to play the file, but is not installed.```

#Solve:

Solusi dari masalah ini saya temukan pada situs ```askubuntu.com```
pada kasus ini langkah yang saya lakukan adalah dengan menginstall package *ubuntu-restricted-extras*  command yang dijalankan pada terminal adalah **```sudo apt install ubuntu-restricted-extras```**

link: https://askubuntu.com/questions/1026178/problems-playing-videos