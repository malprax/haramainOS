# haramain_os Universitas Negeri Makassar

Travel
├── Jamaah
├── Mutawwif
├── Rombongan
├── Jadwal
├── Hotel
├── Transportasi
├── Dokumen
├── Pembayaran
├── Souvenir
└── Lokasi Jamaah

HAKI 1

HaramainOS Smart Jamaah Tracker

Artikel 1

Title

Design and Implementation of Smart Jamaah Tracker for Umrah and Hajj Pilgrim Monitoring Using Flutter Mobile Application

Novelty:
Real-time pilgrim monitoring
Last known location
Status tracking

HAKI 2

HaramainOS Smart Group Manager

Artikel 2

Title

Development of Smart Group Manager for Managing Pilgrim Groups in Umrah and Hajj Travel Services

Novelty:
Group management
Bus allocation
Room allocation
Mutawwif assignment

HAKI 3

HaramainOS Emergency Jamaah Button

Artikel 3

Title

Mobile-Based Emergency Reporting System for Enhancing Pilgrim Safety During Umrah and Hajj Activities

Novelty:
Emergency button
Location sharing
Incident reporting
Emergency response workflow

Admin
├─ Add Group
├─ Add Jamaah
├─ Assign Bus
├─ Assign Hotel
└─ Assign Mutawwif


Tahap 1 — Booking Seat Jamaah

Saat ini jamaah sudah bisa melihat paket.

Target berikut:

⬜ Jamaah klik paket
⬜ Muncul kotak seat sesuai kapasitas
⬜ Klik seat kosong → booking
⬜ Seat berubah putih ➜ kuning (pending)
⬜ Nama jamaah tersimpan di booking

⸻

Tahap 2 — Approval Admin

Admin buka Kelola Booking

⬜ Seat kuning tampil nama jamaah
⬜ Tombol Approve
⬜ Tombol Tolak
⬜ Tombol Reset

Status:

🟨 Pending
🟩 Approved
🟥 Rejected
⬜ Kosong

⸻

Tahap 3 — Dashboard Jamaah

Setelah booking berhasil:

Daripada muncul tombol “Beli Paket”, tampilkan:

Tahap 4 — Sinkronisasi Real Time Supabase

Agar admin dan jamaah melihat perubahan langsung tanpa refresh:


Menurut saya sekarang jangan lompat dulu ke:

* Tracking GPS
* Checklist Umrah
* Manasik
* Broadcast

Karena modul Booking Paket + Seat + Approval adalah jantung bisnis travel. Kalau modul ini selesai 100%, baru fitur lain tinggal pelengkap.

Saya sarankan berikutnya kita selesaikan seat booking jamaah → pending → approve admin → muncul di dashboard jamaah sampai benar-benar beres.



HAKI #1

Travel CMS Umrah dan Haji Berbasis Flutter Web dan Mobile

⸻

HAKI #2

Smart Seat Booking Management untuk Travel Umrah

⸻

HAKI #3

Realtime Visual Seat Status Engine Berbasis GetX dan Supabase

⸻

Jika target artikel ilmiah

Saya melihat paling kuat:

Artikel 1

Implementasi Sistem Booking Seat Visual untuk Travel Umrah Berbasis Flutter

⸻

Artikel 2

Evaluasi Metode Polling Realtime pada Sistem Reservasi Multi User Menggunakan Supabase

⸻

Artikel 3

Desain Dashboard Adaptif untuk Pengelolaan Jamaah Umrah Digita