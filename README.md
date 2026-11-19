# DBLP-Mining (IF4041)

Analisis popularitas konferensi serta Frequent Pattern Mining & Association Rule Mining (Apriori dan FP-Growth) pada dataset publikasi DBLP periode **2015–2025**.

## Struktur Direktori

```
.
├── data/
│   ├── raw/                  # File mentah DBLP (dblp.xml.gz, dblp.dtd, metadata.json)
│   └── processed/            # Dataset hasil parsing & preprocessing (.parquet)
├── notebooks/                # Jupyter notebooks untuk EDA, mining, dan visualisasi
├── outputs/
│   └── figures/              # Grafik/visualisasi hasil eksperimen
├── src/
│   ├── download.py           # Script unduh dataset DBLP + pencatatan checksum SHA-256
│   ├── parser.py             # Parser XML streaming (lxml iterparse) ke format Parquet
│   ├── preprocessing.py      # Preprocessing & normalisasi data
│   └── transactions.py       # Konstruksi transactional database
├── tables/                   # Tabel ringkasan hasil eksperimen
└── requirements.txt          # Daftar dependensi Python
```

## Setup Environment (Reproducible)

Disarankan menggunakan `uv` (atau `python -m venv`):

```bash
# Menggunakan uv
uv venv .venv
source .venv/bin/activate
uv pip install -r requirements.txt
```

Atau menggunakan `pip` standar:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Cara Reproduksi Data Loading

Seluruh proses pengunduhan dan ekstraksi data dapat direproduksi dari awal dengan dua perintah berikut:

### 1. Unduh Dataset Mentah DBLP

```bash
python -m src.download
```

Script `src/download.py` akan:
- Mengunduh `dblp.dtd` dan `dblp.xml.gz` dari mirror resmi DBLP (`https://dblp.org/xml/`, dengan fallback otomatis ke `https://dblp.uni-trier.de/xml/`) ke `data/raw/`.
- Melewati file yang sudah ada (gunakan `--force` untuk mengunduh ulang).
- Menyimpan metadata unduhan beserta checksum **SHA-256** ke `data/raw/metadata.json`.

### 2. Parsing XML ke Parquet (2015–2025)

```bash
python -m src.parser
```

Opsi CLI yang tersedia:
- `--input` (default: `data/raw/dblp.xml.gz`)
- `--output` (default: `data/processed/dblp_2015_2025_raw.parquet`)
- `--year-min` (default: `2015`)
- `--year-max` (default: `2025`)

Script `src/parser.py` menggunakan `lxml.etree.iterparse` (streaming + DTD entity resolution) untuk menyaring record bertipe `<inproceedings>` pada rentang tahun 2015–2025 dan menyimpannya ke Parquet.

### 3. Preprocessing & Normalisasi

```bash
python -m src.preprocessing
```

Opsi CLI yang tersedia:
- `--input` (default: `data/processed/dblp_2015_2025_raw.parquet`)
- `--output` (default: `data/processed/dblp_2015_2025_clean.parquet`)
- `--summary` (default: `data/processed/preprocessing_summary.json`)
- `--year-min` (default: `2015`)
- `--year-max` (default: `2025`)

Tahapan yang dijalankan `src/preprocessing.py`:
1. Validasi konsistensi tahun publikasi (`2015–2025`, `int32`).
2. Penghapusan missing values (`venue` kosong, `authors` kosong, `key`/`title` kosong).
3. Normalisasi nama author (Unicode NFC + whitespace collapse, **mempertahankan** suffix disambiguasi DBLP seperti `0001`).
4. Normalisasi nama conference/venue (penyeragaman `(Workshops)` -> `Workshops`, spasi `@`, alias `NIPS` -> `NeurIPS`, dan canonical casing berdasarkan bentuk penulisan paling sering).
5. Deduplikasi berdasarkan `key` dan `(normalized_title, year, venue)`.

## Informasi & Provenance Dataset

- **Sumber**: DBLP XML Dump (`https://dblp.org/xml/` / `https://dblp.uni-trier.de/xml/`)
- **Tanggal Pengambilan**: 18 November 2026 UTC (19 November 2026 WIB)
- **File Mentah** (tercatat di `data/raw/metadata.json`):
  - `dblp.dtd`: `13,134` bytes (`sha256: 03ec35cb34a4227572a0e89da407b06b6e44a6cc23e19cabc3b49b702a5f897d`)
  - `dblp.xml.gz`: `1,121,100,825` bytes / ~1.04 GiB (`sha256: 33d24f877422768b477c5174c385cc3806a2c390af66ecb426b0cd1e23b097ec`)
- **Hasil Ekstraksi (`data/processed/dblp_2015_2025_raw.parquet`)**:
  - Total `<inproceedings>` yang dipindai: `4,001,762` record
  - Total record periode 2015–2025: **`2,004,117` baris**, `5` kolom (`203 MB`)
  - Kolom:
    - `key` (`string`): identifier unik publikasi di DBLP
    - `title` (`string`): judul publikasi
    - `authors` (`list[string]`): daftar nama penulis
    - `year` (`int64`): tahun publikasi (`2015`–`2025`)
    - `venue` (`string`): nama konferensi/workshop (`<booktitle>`)
  - Catatan awal kualitas data mentah (untuk ditangani di tahap preprocessing): `190` baris memiliki `venue` null dan `2,255` baris memiliki daftar `authors` kosong.
