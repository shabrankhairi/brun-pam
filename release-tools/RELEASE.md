# Brun — Release & Distribution Guide

Panduan ini untuk **kamu (maintainer)**, bukan untuk end-user. Ini
menjelaskan cara publish Brun supaya orang lain bisa install lewat
`wget` tanpa pernah menerima source code yang bisa dibaca.

## Kejujuran teknis dulu, sebelum lanjut

**Tidak ada cara membuat JavaScript yang jalan di browser 100% tidak
bisa di-reverse.** Begitu kode itu dikirim ke browser orang untuk
dieksekusi, siapa pun yang buka DevTools bisa membacanya — ini hukum
dasar bagaimana browser bekerja, bukan celah keamanan yang bisa
ditambal.

Yang bisa (dan sudah) dilakukan di sini:
1. **Obfuscation + minify** semua kode (frontend & backend) — mengubah
   nama variabel jadi hex acak, mengacak alur kontrol, encode semua
   string — jadi *sangat* tidak nyaman dibaca manusia meski secara
   teknis masih bisa "dijalankan mundur" dengan alat & waktu yang cukup.
2. **Installer tidak pernah mengirim source code sama sekali** — cuma
   menarik image Docker yang sudah jadi. Orang yang install ini di
   server mereka tidak pernah menerima file `server.js` atau `*.html`
   yang bisa dibuka dan diedit langsung.
3. Server-side code (`server.js`) jauh lebih terlindungi daripada
   frontend, karena tidak pernah dikirim ke browser siapa pun — cuma
   jalan di dalam container. Frontend (HTML/JS) tetap terkirim ke
   browser user (itu keharusan supaya UI-nya bisa dipakai), jadi
   itu yang paling lemah perlindungannya meski sudah di-obfuscate.

Target realistis: menghalangi orang iseng/kompetitor casual yang cuma
`view-source` atau `docker exec cat server.js`. Bukan menghalangi
reverse engineer yang benar-benar niat dan punya waktu.

## Struktur folder

```
brun-pam/
├── app/                          <- source ASLI (jangan pernah di-publish ke registry publik)
├── dist/                         <- hasil obfuscate, di-generate otomatis, git-ignored
├── release-tools/
│   ├── build-release.js          <- script obfuscate app/ -> dist/
│   ├── package.json              <- dependency tool build (obfuscator, minifier)
│   ├── Dockerfile.release        <- Dockerfile image publik (isi dist/ doang)
│   ├── docker-compose.release.yml <- compose file yang didownload installer
│   └── pam.conf                  <- nginx config yang didownload installer
└── install.sh                    <- installer publik (di-wget end-user)
```

**Tambahkan `dist/` ke `.gitignore`** — itu hasil build, jangan di-commit.

## Setup sekali di awal

### 1. Buat GitHub Container Registry (ghcr.io) token

- Buka GitHub → Settings → Developer settings → Personal access tokens
- Buat token dengan scope `write:packages`
- Login Docker ke ghcr.io:
  ```bash
  echo "<token>" | docker login ghcr.io -u <github-username> --password-stdin
  ```

### 2. Ganti placeholder di file-file ini

Cari `REPLACE_WITH_YOUR_GITHUB_USERNAME` di:
- `install.sh` (variabel `GITHUB_USER`)
- `release-tools/docker-compose.release.yml` (default value `BRUN_IMAGE`)

Ganti dengan username GitHub kamu yang sebenarnya.

### 3. Push `install.sh`, `release-tools/*` ke repo GitHub publik kamu

Ini folder yang boleh publik — isinya cuma config deployment, bukan
source aplikasi (asal kamu **tidak** ikut push folder `app/` ke repo
yang sama, atau kalau mau tetap di satu repo, pastikan `app/` di
private submodule/branch terpisah).

## Proses release (tiap kali mau publish versi baru)

```bash
cd brun-pam

# 1. Obfuscate & minify semua source -> dist/
npm install --prefix release-tools
node release-tools/build-release.js

# 2. Build image dari dist/ (BUKAN dari app/)
docker build -f release-tools/Dockerfile.release \
  -t ghcr.io/<username>/brun-app:latest \
  -t ghcr.io/<username>/brun-app:v1.1 \
  .

# 3. Push ke registry
docker push ghcr.io/<username>/brun-app:latest
docker push ghcr.io/<username>/brun-app:v1.1

# 4. Buat image-nya public (sekali saja per package):
#    GitHub -> Packages -> brun-app -> Package settings -> Change visibility -> Public
```

## Apa yang dialami end-user

```bash
wget -qO- https://raw.githubusercontent.com/<username>/brun-pam/main/install.sh | bash
```

Script ini akan:
1. Cek/install Docker
2. Download **cuma** `docker-compose.yml` + config nginx (bukan source)
3. Generate password admin acak, JWT secret, cipher key — otomatis
4. Generate sertifikat TLS self-signed
5. `docker compose pull` (tarik image jadi dari ghcr.io) + `docker compose up -d`
6. Tampilkan URL + kredensial login

End-user tidak pernah melihat `server.js`, tidak pernah melihat isi
`public/*.html` yang asli — yang mereka dapat cuma container yang
sudah jalan.

## Testing sebelum publish

Sebelum push image beneran, selalu test dulu `dist/` hasil obfuscate
bisa jalan normal:

```bash
cd dist
npm install
JWT_SECRET=test ADMIN_USERNAME=admin ADMIN_PASSWORD=test123 \
  TOKEN_CIPHER_KEY=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
  GUACD_HOST=localhost node server.js
# buka browser ke localhost:3000, coba login, coba semua fitur
```

Kalau ada fitur yang rusak setelah obfuscate (jarang terjadi, tapi bisa
kalau ada penggunaan `eval`/reflection yang tidak biasa), turunkan
tingkat agresivitas obfuscation di `release-tools/build-release.js`
(matikan `controlFlowFlattening` atau `deadCodeInjection` dulu untuk
isolasi masalahnya).

## Update versi berikutnya

Sama seperti awal — jalankan proses release, push dengan tag versi
baru. End-user tinggal jalankan:

```bash
cd /opt/brun
docker compose pull
docker compose up -d
```

tidak perlu jalankan `install.sh` lagi dari awal.
