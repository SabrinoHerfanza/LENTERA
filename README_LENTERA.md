# LENTERA — Project Baru

LENTERA adalah aplikasi Flutter untuk memantau kegiatan mengaji siswa secara real-time menggunakan Firebase Authentication dan Firebase Realtime Database.

## 1. Buat project

flutter create lentera
cd lentera

## 2. Ganti dependency

Salin pubspec.yaml dari paket ini ke project, lalu:

flutter pub get

## 3. Hubungkan Firebase

Pastikan Firebase CLI dan FlutterFire CLI sudah terpasang.

firebase login
dart pub global activate flutterfire_cli
flutterfire configure

Pilih project Firebase dan platform Android/Web yang ingin dipakai.

Perintah tersebut akan membuat:
lib/firebase_options.dart

Jangan membuat firebase_options.dart manual.

## 4. Aktifkan Authentication

Firebase Console:
Authentication > Sign-in method > Email/Password > Enable.

## 5. Buat Realtime Database

Firebase Console:
Build > Realtime Database > Create Database.

Untuk pengujian awal, boleh mulai dari test mode, tetapi segera ganti dengan rules dari database.rules.json.

## 6. Buat akun

Firebase Authentication > Users > Add user.

Agar siswa bisa login menggunakan NIS, gunakan email internal:
10231@lentera.app

Password contoh:
Lentera123!

Lalu buat node:
users/<UID>

{
  "name": "Ahmad",
  "nis": "10231",
  "className": "XI IPA 2",
  "role": "siswa"
}

Untuk admin:
admin@lentera.app

Node:
users/<UID_ADMIN>

{
  "name": "Admin",
  "nis": "",
  "className": "",
  "role": "admin"
}

## 7. Security Rules

Buka Realtime Database > Rules.

Salin isi database.rules.json.

## 8. Jalankan

flutter run

## 9. Fitur yang sudah ada

- Splash screen
- Login NIS/email + password
- Show/hide password
- Reset password
- Role siswa/admin
- Dashboard siswa
- Absensi
- Sesi mengaji
- Timer mengaji
- Heartbeat real-time
- Simpan progres
- Riwayat membaca
- Dashboard admin
- Daftar siswa
- Detail siswa
- Notifikasi/interupsi

## Catatan

Halaman membaca saat ini memakai satu teks Arab contoh sebagai placeholder. Untuk versi lomba final, gunakan sumber teks Al-Qur'an yang sesuai dan data surat/ayat lengkap.

Sistem heartbeat saat ini adalah fondasi monitoring. Deteksi aplikasi benar-benar ditutup/background dan AI pendeteksi suara sebaiknya ditambahkan pada tahap lanjutan menggunakan mekanisme native/background yang sesuai.
