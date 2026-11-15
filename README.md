# Lumi — Ruang Teduh & Jejak Harian 🌿🐻

<p align="center">
  <img src="assets/public/lumi_app_icon.jpg" alt="Lumi Mascot Icon" width="140" />
</p>

<p align="center">
  <b>Aplikasi Jurnal Kesehatan Mental, Pemantauan Ritme Sirkadian, Kepatuhan Rutinitas (Obat & Makan), serta Ringkasan Klinis Psikiater/Psikolog Berbasis Offline-First</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/State_Management-Provider-355070" alt="Provider" />
  <img src="https://img.shields.io/badge/Database-SQLite_(sqflite)-003B57?logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/Privacy-AES--256_Local_First-B5EAD7" alt="Privacy" />
</p>

---

## 🎬 Demo Video & Live Deployment

Tonton demonstrasi penggunaan atau coba langsung aplikasi **Lumi — Ruang Teduh & Jejak Harian** melalui tautan berikut:

- **🌐 Live Web App (GitHub Pages):** [https://zulfarida0107-crypto.github.io/Lumi-app/](https://zulfarida0107-crypto.github.io/Lumi-app/)
- **📦 GitHub Release (`v1.0.0`):** [https://github.com/zulfarida0107-crypto/Lumi-app/releases/tag/v1.0.0](https://github.com/zulfarida0107-crypto/Lumi-app/releases/tag/v1.0.0)
- **🎥 Link Demo Video:** [Tonton Video Demo Lumi (YouTube / Google Drive)](#) *(Ganti `#` dengan tautan video demo Anda)*

---

## ✨ Main Features

1. **Animated Mascot Splash & Multi-Layer Sanctuary Authentication:**
   - Animasi pembukaan interaktif maskot beruang **Lumi** dengan tunas daun mint yang tumbuh lembut.
   - Sistem keamanan berlapis yang mewajibkan registrasi akun terlebih dahulu, dilengkapi layar **Sambutan Hangat**, **Verifikasi Sidik Jari / Biometrik**, serta **Kunci PIN Privasi 4-Digit (Dialpad 3x4)**.
2. **Tab 1 — Hari Ini (Jejak Ritme Harian & 1-Tap Self-Care):**
   - Pemantauan waktu *real-time* WIB dengan *auto-reset* pergantian hari pukul `00:00 WIB` dan kalender strip mingguan interaktif.
   - **4 Kartu Jejak Utama:** Pencatatan **Minum Obat** (Pagi, Siang, Malam), **Jadwal Makan** (Pagi, Siang, Malam), **Durasi & Kualitas Tidur**, serta **Suasana Hati & Kapasitas Energi**.
   - **Mode Darurat 1-Tap ("Lagi Sangat Lelah"):** Memungkinkan penyintas depresi/kelelahan ekstrem mencatat kondisi harian hanya dengan satu sentuhan tanpa beban mengisi formulir panjang.
3. **Tab 2 — Catatan & Memori (Jurnal Harian & Mode Siap Konsultasi):**
   - Penulisan jurnal perasaan harian lengkap dengan lampiran dokumentasi foto, memo suara (*waveform*), label pemicu (*tags*), dan pencarian cepat.
   - **Pin Terapi (`⭐ Siap Konsultasi`):** Menandai catatan penting agar otomatis dirangkum saat sesi bersama psikolog atau psikiater.
   - **Fitur Mata Teduh (Privacy Blur):** Menyamarkan isi teks jurnal secara instan saat berada di ruang publik.
4. **Tab 3 — Matriks Bulanan, Year in Pixels & Ringkasan Konsultasi Dokter:**
   - **Kalender Bulanan Interaktif:** Menampilkan indikator suasana hati per tanggal (atau tanda `-` jika belum ada data) dan *bottom sheet* rincian harian saat tanggal diketuk.
   - **Wawasan Pola Otomatis (Dynamic Insights):** Menganalisis korelasi antara durasi tidur, kepatuhan minum obat, keteraturan makan, dan kestabilan afek secara dinamis.
   - **Ringkasan Konsultasi Dokter (`RingkasanKonsultasiScreen`):** Halaman laporan klinis terstruktur untuk psikiater/psikolog yang mencakup Matriks Klinis Utama, Sorotan Catatan Terapi, serta **Agenda Tanya Pasien ke Dokter** (mendukung tambah, ubah, dan hapus dengan konfirmasi).
   - **Sub-tab Tahunan (*Year in Pixels* & Kalender 12 Bulan):** Memvisualisasikan perjalanan emosi dan kualitas tidur selama 365 hari penuh.
5. **Tab 4 — Chart (Visualisasi Grafik Batang / Dynamic Bar Charts):**
   - **Bar Chart Jam Tidur & Mood Harian** dengan filter Mingguan (Minggu 1–4 & Sebulan Penuh) dan garis target tidur ideal `7 jam`.
   - **Grouped Bar Chart Kepatuhan Rutinitas (Obat vs Makan)** untuk waktu Pagi, Siang, dan Malam.
   - **Bar Chart Frekuensi Level Suasana Hati** (Level 1 *Berat* s/d Level 5 *Damai*) dan **Distribusi Kualitas Tidur**.

---

## 🔄 CRUD Operations Description

Aplikasi **Lumi** mengimplementasikan operasi **CRUD (Create, Read, Update, Delete)** secara menyeluruh yang terhubung langsung ke penyimpanan lokal (`SQLite` melalui `LumiDatabase`) dan *in-memory reactive state* (`LumiProvider`):

| Operasi | Modul / Entitas Data | Deskripsi Implementasi di Aplikasi Lumi |
| :--- | :--- | :--- |
| **CREATE** *(Tambah Data)* | **Akun Pengguna, Jejak Harian (`DailyJejak`), Catatan Jurnal (`NoteMemory`), & Agenda Dokter** | • Membuat akun baru pada `LumiRegisterScreen` (`LumiAuthStore.registerAccount`).<br>• Mencatat jam tidur, kualitas tidur, dan alasan pada modal *Catat Tidur* (`saveSleepRecord`).<br>• Menambahkan entri jurnal perasaan baru beserta mood, tag, foto, atau memo suara (`addNote`).<br>• Menambahkan pertanyaan baru pada bagian **Agenda Tanya Pasien ke Dokter** di halaman Ringkasan Konsultasi. |
| **READ** *(Baca & Visualisasi)* | **Linimasa Harian, Feed Catatan, Matriks Bulanan/Tahunan, & Bar Chart** | • Membaca data harian berdasarkan tanggal terpilih (`loadDataForDate`) dan menampilkannya pada kartu *Jejak Hari Ini*.<br>• Menampilkan dan memfilter daftar jurnal berdasarkan kata kunci pencarian, kategori *Siap Konsultasi*, *Low Energy*, Foto, atau Memo Suara.<br>• Mengagregasi data bulanan dan tahunan secara dinamis ke Kalender Bulanan, Matriks Klinis Dokter, *Year in Pixels*, dan *Bar Chart*. |
| **UPDATE** *(Perbarui Data)* | **Ceklis Rutinitas Obat/Makan, Catatan Jurnal, Nama Panggilan, & Agenda Dokter** | • Memperbarui status ceklis selesai (`✓`) atau terlewat (`✗`) beserta jam pelaksanaan pada jadwal Obat dan Makan (`toggleRoutineItem`, `saveRoutinesForType`).<br>• Mengubah isi catatan jurnal, level mood, dan status bintang *Pin Terapi* (`updateNote`, `togglePinNote`).<br>• Mengubah nama panggilan pengguna di layar Sambutan Hangat & tautan Google Spreadsheet di Pengaturan.<br>• Mengedit judul dan rincian pertanyaan pada **Agenda Tanya Pasien ke Dokter**. |
| **DELETE** *(Hapus Data)* | **Catatan Jurnal (`NoteMemory`), Reset Ceklis Harian, & Agenda Dokter** | • Menghapus catatan jurnal perasaan dari daftar dan database SQLite (`deleteNote`).<br>• Menghapus pertanyaan pada **Agenda Tanya Pasien ke Dokter** dengan pengaman **Popup Dialog Konfirmasi Hapus** agar tidak terhapus secara tidak sengaja.<br>• Membatalkan ceklis rutinitas harian sehingga hari tanpa rekaman otomatis dibersihkan dari koleksi aktif. |

---

## 🛠️ Technology

| Komponen | Teknologi / Pustaka | Kegunaan |
| :--- | :--- | :--- |
| **Framework UI** | [Flutter](https://flutter.dev/) (`SDK ^3.11.4`) | Pengembangan aplikasi lintas platform (Android, iOS, Windows, Web) dengan satu basis kode. |
| **Bahasa Pemrograman** | [Dart](https://dart.dev/) | Bahasa pemrograman utama untuk logika bisnis, model data, dan antarmuka reaktif. |
| **State Management** | [`provider`](https://pub.dev/packages/provider) (`^6.1.5+1`) | Mengelola *state* reaktif terpusat (`LumiProvider`) agar perubahan input langsung memperbarui Matriks dan Chart. |
| **Database Lokal** | [`sqflite`](https://pub.dev/packages/sqflite) (`^2.4.2+1`) & [`path`](https://pub.dev/packages/path) | Penyimpanan relasional SQLite *offline-first* di perangkat pengguna untuk tabel `daily_jejak` dan `notes`. |
| **Preferensi Lokal** | [`shared_preferences`](https://pub.dev/packages/shared_preferences) (`^2.5.6`) | Menyimpan konfigurasi ringan dan pengaturan pengguna di perangkat. |
| **Tipografi & Format Tanggal** | [`google_fonts`](https://pub.dev/packages/google_fonts) (`Plus Jakarta Sans`) & [`intl`](https://pub.dev/packages/intl) | Tipografi humanis yang menenangkan serta pemformatan waktu *real-time* WIB. |

---

## 🚀 Installation & Running Guide

Ikuti langkah-langkah berikut untuk menjalankan proyek **Lumi** di perangkat lokal Anda:

### 1. Prasyarat (*Prerequisites*)
- **Flutter SDK** versi `3.11.0` atau lebih baru (`flutter --version`).
- **Git** terpasang di komputer.
- **Android Studio** / **VS Code** beserta emulator Android, atau browser **Google Chrome** / **Microsoft Edge** / **Windows Desktop**.

### 2. Clone Repository & Instalasi Dependensi
```bash
# 1. Clone repository dari GitHub
git clone https://github.com/zulfarida0107-crypto/Lumi-app.git

# 2. Masuk ke direktori proyek
cd Lumi-app

# 3. Unduh seluruh paket dependensi Flutter
flutter pub get
```

### 3. Menjalankan Aplikasi
```bash
# Menjalankan di perangkat Android / Emulator yang terhubung
flutter run

# Menjalankan di Windows Desktop
flutter run -d windows

# Menjalankan di Browser Chrome
flutter run -d chrome
```

---

## 📦 Deployment / Release via GitHub

Aplikasi **Lumi** telah di-*deploy* secara langsung melalui **GitHub Pages** (untuk akses Web instan) dan **GitHub Releases** (untuk distribusi rilis versi `v1.0.0`):

- **Live Deployment (GitHub Pages):** [https://zulfarida0107-crypto.github.io/Lumi-app/](https://zulfarida0107-crypto.github.io/Lumi-app/)
- **Official Release (`v1.0.0`):** [https://github.com/zulfarida0107-crypto/Lumi-app/releases/tag/v1.0.0](https://github.com/zulfarida0107-crypto/Lumi-app/releases/tag/v1.0.0)
- **Source Repository:** [https://github.com/zulfarida0107-crypto/Lumi-app](https://github.com/zulfarida0107-crypto/Lumi-app)

### 1. Build File Release (APK / Web)
```bash
# Buat file APK Release untuk Android
flutter build apk --release

# Atau buat bundel Web Release untuk GitHub Pages
flutter build web --release --base-href "/Lumi-app/"
```

### 2. Publikasi ke GitHub Releases & GitHub Pages
1. Commit dan dorong (*push*) seluruh perubahan kode ke cabang utama GitHub:
   ```bash
   git add .
   git commit -m "chore(release): v1.0.0 Lumi Ruang Teduh & Jejak Harian"
   git push origin main
   ```
2. Buat *tag* versi rilis baru dan publikasikan ke GitHub Releases:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0 — Lumi: Ruang Teduh & Jejak Harian"
   git push origin v1.0.0
   ```
3. Untuk pembaruan **GitHub Pages**, dorong hasil `build/web` ke cabang `gh-pages`:
   ```bash
   cd build/web
   git init -b gh-pages
   git add .
   git commit -m "deploy: Lumi Web release to GitHub Pages"
   git push -f https://github.com/zulfarida0107-crypto/Lumi-app.git gh-pages
   ```

---

## 📸 Documentation & Demo

Berikut adalah dokumentasi visual dan penjelasan setiap fitur utama pada aplikasi **Lumi**:

| Feature | Documentation Preview | Description |
| :--- | :---: | :--- |
| **1. Animated Mascot Splash & Auth Sanctuary** | <img src="assets/public/lumi_app_icon.jpg" alt="Splash & Auth Preview" width="120" /> | Layar pembuka beranimasi maskot beruang **Lumi** dengan tunas daun mint yang tumbuh lembut, dilanjutkan dengan gerbang autentikasi wajib akun terdaftar (**Daftar Akun Baru**, **Login Email**, **Sidik Jari / Biometrik**, **Kunci PIN 4-Digit**, dan **Sambutan Hangat**). |
| **2. Tab Hari Ini (Jejak Harian & 1-Tap Routine)** | `[Preview Tab Hari Ini]`<br>*(Tambahkan screenshot Tab Hari Ini)* | Dashboard harian *real-time* WIB dengan kalender mingguan geser, 4 kartu status (**Obat**, **Makan**, **Tidur**, **Mood**), tombol darurat **"Lagi Sangat Lelah"** (*1-Tap Low-Energy Mode*), serta pencatatan jadwal Pagi/Siang/Malam. |
| **3. Tab Catatan & Mode Siap Konsultasi** | `[Preview Tab Catatan]`<br>*(Tambahkan screenshot Tab Catatan)* | Linimasa jurnal perasaan dengan pencarian instan, filter kategori, penanda **⭐ Pin Terapi**, fitur penyamaran privasi **Mata Teduh** (*blur*), serta dukungan lampiran foto dan memo suara. |
| **4. Tab Matriks Bulanan & Year in Pixels** | `[Preview Tab Matriks]`<br>*(Tambahkan screenshot Tab Matriks)* | Kalender bulanan interaktif yang menampilkan indikator mood harian (atau `-` bila belum ada data), *bottom sheet* detail harian, analisis pola otomatis, serta visualisasi tahunan **Year in Pixels** (365 hari). |
| **5. Ringkasan Konsultasi Dokter / Psikiater** | `[Preview Ringkasan Dokter]`<br>*(Tambahkan screenshot Ringkasan Konsultasi)* | Laporan klinis terstruktur untuk sesi konsultasi psikiater/psikolog yang merangkum **Matriks Klinis Utama** (Stabilitas Afek, Tidur Sirkadian, Kepatuhan Obat, Keteraturan Makan), **Catatan Terapi**, dan **Agenda Tanya Pasien ke Dokter** (lengkap dengan fitur Tambah, Edit, & Hapus berkonfirmasi). |
| **6. Tab Chart (Dynamic Bar Charts)** | `[Preview Tab Chart]`<br>*(Tambahkan screenshot Tab Chart)* | Visualisasi grafik batang (*Bar Chart*) 100% dinamis meliputi **Bar Chart Durasi Tidur & Mood Harian** per minggu, **Grouped Bar Chart Obat vs Makan** (Pagi/Siang/Malam), **Frekuensi Level Mood**, dan **Distribusi Kualitas Tidur**. |
| **7. Pengaturan Privasi & Sinkronisasi** | `[Preview Pengaturan]`<br>*(Tambahkan screenshot Pengaturan)* | Pengaturan profil pengguna, penguncian biometrik/PIN, pengingat lembut bebas tekanan, tautan Google Spreadsheet pribadi, ekspor CSV/PDF, serta tombol **Kunci Ruang Teduh Sementara**. |

---

<p align="center">
  Dibuat dengan penuh empati untuk menjaga setiap perasaan dan jejak harianmu tetap teduh. 🌿
</p>
