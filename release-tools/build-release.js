#!/usr/bin/env node
/**
 * build-release.js
 * =================
 * Dijalankan oleh MAINTAINER (bukan end-user) sebelum build & push image
 * Docker publik. Tugasnya: ambil source asli dari app/, hasilkan versi
 * ter-obfuscate/minify di dist/, yang nanti jadi ISI SATU-SATUNYA dari
 * image publik -- source asli (app/) tidak pernah ikut masuk image.
 *
 * Cara pakai:
 *   cd brun-pam
 *   node release-tools/build-release.js
 *   docker build -f release-tools/Dockerfile.release -t <registry>/brun-app:<tag> .
 *   docker push <registry>/brun-app:<tag>
 */

const fs = require('fs');
const path = require('path');
const obfuscator = require('javascript-obfuscator');
const { minify: minifyHtml } = require('html-minifier-terser');

const ROOT = path.join(__dirname, '..');
const SRC_APP = path.join(ROOT, 'app');
const DIST = path.join(ROOT, 'dist');

const OBFUSCATOR_OPTIONS = {
  compact: true,
  controlFlowFlattening: true,
  controlFlowFlatteningThreshold: 0.75,
  deadCodeInjection: true,
  deadCodeInjectionThreshold: 0.4,
  identifierNamesGenerator: 'hexadecimal',
  stringArray: true,
  stringArrayEncoding: ['base64'],
  stringArrayThreshold: 0.75,
  renameGlobals: false,
  selfDefending: true,
  // sourceMap sengaja TIDAK diaktifkan -- source map akan membongkar balik
  // semua nama variabel/struktur asli, meniadakan seluruh tujuan obfuscation.
};

function obfuscateJs(code) {
  return obfuscator.obfuscate(code, OBFUSCATOR_OPTIONS).getObfuscatedCode();
}

async function main() {
  console.log('== Brun release build ==');

  // Bersihkan dist/ lama
  fs.rmSync(DIST, { recursive: true, force: true });
  fs.mkdirSync(path.join(DIST, 'public'), { recursive: true });

  // 1) Obfuscate server.js
  const serverSrc = fs.readFileSync(path.join(SRC_APP, 'server.js'), 'utf8');
  fs.writeFileSync(path.join(DIST, 'server.js'), obfuscateJs(serverSrc));
  console.log('✓ server.js obfuscated');

  // 2) Obfuscate common.js
  const commonSrc = fs.readFileSync(path.join(SRC_APP, 'public', 'common.js'), 'utf8');
  fs.writeFileSync(path.join(DIST, 'public', 'common.js'), obfuscateJs(commonSrc));
  console.log('✓ common.js obfuscated');

  // 3) Untuk tiap HTML: obfuscate inline <script>, lalu minify seluruh file
  const publicDir = path.join(SRC_APP, 'public');
  const htmlFiles = fs.readdirSync(publicDir).filter((f) => f.endsWith('.html'));

  for (const file of htmlFiles) {
    let html = fs.readFileSync(path.join(publicDir, file), 'utf8');

    // ganti isi tiap <script>...</script> INLINE (bukan <script src=...>)
    // dengan versi obfuscated-nya, sebelum di-minify keseluruhan.
    html = html.replace(/<script>([\s\S]*?)<\/script>/g, (match, jsCode) => {
      const obfuscated = obfuscateJs(jsCode);
      return `<script>${obfuscated}</script>`;
    });

    const minified = await minifyHtml(html, {
      collapseWhitespace: true,
      removeComments: true,
      minifyJS: false, // sudah di-obfuscate manual di atas, jangan di-minify ulang (bisa merusak)
      minifyCSS: true,
    });

    fs.writeFileSync(path.join(DIST, 'public', file), minified);
    console.log(`✓ ${file} obfuscated + minified`);
  }

  // 4) Copy file yang tidak perlu diproses (CSS, Dockerfile referensi, package.json)
  fs.copyFileSync(path.join(publicDir, 'style.css'), path.join(DIST, 'public', 'style.css'));
  fs.copyFileSync(path.join(SRC_APP, 'package.json'), path.join(DIST, 'package.json'));
  if (fs.existsSync(path.join(SRC_APP, 'package-lock.json'))) {
    fs.copyFileSync(path.join(SRC_APP, 'package-lock.json'), path.join(DIST, 'package-lock.json'));
  }
  console.log('✓ static assets copied');

  console.log('\nSelesai. Hasil ada di dist/ -- ini yang akan di-COPY ke image Docker,');
  console.log('BUKAN folder app/ aslinya. Lanjut ke:');
  console.log('  docker build -f release-tools/Dockerfile.release -t <registry>/brun-app:<tag> .');
}

main().catch((err) => {
  console.error('Build gagal:', err);
  process.exit(1);
});
