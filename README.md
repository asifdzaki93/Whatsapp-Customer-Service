# WhatsApp Customer Service

Proyek ini adalah aplikasi manajemen layanan pelanggan berbasis WhatsApp yang terdiri dari backend dan frontend. Aplikasi ini menggunakan **Node.js** untuk backend, **PostgreSQL** sebagai database, dan **Redis** untuk caching dan queue.

## Kebutuhan Sistem (Windows)
- **Node.js** (Backend)
- **PostgreSQL** (Database)
- **Redis** (Caching dan Queue)

---

## Instalasi Backend

1. **Buat Database PostgreSQL**  
   Buat database baru di PostgreSQL.

2. **Konfigurasi `.env`**  
   Sesuaikan nama dan password database pada file `.env`.

3. **Install Dependencies**  
   Jalankan perintah berikut untuk menginstal semua dependensi:
   ```bash
   npm install
   ```

4. **Build Backend**  
   Jalankan perintah berikut untuk membangun backend:
   ```bash
   npm run build
   ```

5. **Migrasi Database**  
   Jalankan migrasi database:
   ```bash
   npx sequelize db:migrate
   ```

6. **Seed Data**  
   Isi database dengan data awal:
   ```bash
   npx sequelize db:seed:all
   ```

---

## Instalasi Frontend

1. **Konfigurasi `.env`**  
   Sesuaikan file `.env` untuk frontend.

2. **Install Dependencies**  
   Jalankan perintah berikut untuk menginstal semua dependensi:
   ```bash
   npm install
   ```

---

## Menjalankan Aplikasi

### Start Backend
Jalankan perintah berikut untuk memulai backend:
```bash
npm start
```

### Start Frontend
Jalankan perintah berikut untuk memulai frontend:
```bash
npm start
```

---

## Catatan
Pastikan semua kebutuhan sistem telah diinstal dan dikonfigurasi dengan benar sebelum menjalankan aplikasi.