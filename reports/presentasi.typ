#import "@preview/diatypst:0.10.1": *

#show: slides.with(
  title: "Conference Popularity and Association Pattern Mining",
  subtitle: "Analisis Dataset DBLP (2015–2025): Apriori, FP-Growth & Temporal Analysis",
  footer-title: "IF4041 Penambangan Data",
  footer-subtitle: "DBLP Mining (2015–2025)",
  date: "22 November 2026",
  authors: ("Anggota 1", "Anggota 2", "Anggota 3"),
  institute: "Program Studi Teknik Informatika — Project Data Mining",
  ratio: 16/9,
  layout: "medium",
  title-color: rgb("#0F4D92"),
  count: "number",
  toc: false,
  theme: "normal",
)

#set text(size: 10.5pt, lang: "id")
#show table: set text(size: 8.2pt)
#show table: set table(stroke: 0.6pt + black, fill: none, inset: (x: 4.5pt, y: 3.1pt))

// =========================================================================
// OUTLINE
// =========================================================================
== Daftar Materi Presentasi

#outline(depth: 1, title: none)

// =========================================================================
= Pendahuluan & Ketentuan Dataset
// =========================================================================

== Deskripsi & Tujuan Project (Bagian A & B)

#grid(
  columns: (1fr, 1.15fr),
  column-gutter: 16pt,
  [
    / *Deskripsi*: Analisis basis data bibliografi *DBLP* (Digital Bibliography & Library Project) untuk mengungkap *popularitas konferensi* dan *pola hubungan antar-konferensi* dari riwayat publikasi peneliti.
    / *Metrik Popularitas*: Diukur secara ketat berdasarkan *aktivitas publikasi* (jumlah makalah & jumlah _author_ unik).
    / *Teknik Utama*: _Frequent Pattern Mining_ & _Association Rule Mining_ dengan *Apriori* dan *FP-Growth*.
  ],
  [
    *7 Tujuan Project (Bagian B)*:
    + Memahami dan melakukan _preprocessing_ dataset bibliografi.
    + Mengubah data bibliografi menjadi _transactional database_.
    + Mengimplementasikan algoritma *Apriori* dan *FP-Growth*.
    + Menemukan _frequent itemsets_ pada berbagai _minimum support_.
    + Menghasilkan dan menganalisis _association rules_.
    + Mengevaluasi performa algoritma FPM (Apriori vs FP-Growth).
    + Menginterpretasikan hasil _mining_ menjadi wawasan bermakna.
  ],
)

== Ketentuan & Provenance Dataset DBLP (Bagian C)

#grid(
  columns: (1.1fr, 1fr),
  column-gutter: 16pt,
  [
    *Ketentuan Dataset*:
    - *Sumber*: DBLP XML Dump resmi (`https://dblp.org/xml/`).
    - *Cakupan*: Publikasi dari seluruh bidang _Computer Science_.
    - *Periode*: Tahun publikasi *2015–2025* (11 tahun).
    - *Fokus*: Publikasi konferensi & _workshop_ (`<inproceedings>`).
    - *Atribut*: `key`, `title`, `authors`, `year`, `venue` (`<booktitle>`).
  ],
  [
    *Provenance & Snapshot*:
    #table(
      columns: (auto, 1fr),
      align: (left, left),
      [*Atribut*], [*Nilai Tercatat (`metadata.json`)*],
      [Tanggal Ambil], [19 November 2026 (03:06:47 UTC)],
      [Last-Modified], [`Thu, 19 Nov 2026 02:13:25 GMT`],
      [`dblp.dtd`], [13.134 bytes (`sha256: 03ec35cb...`)],
      [`dblp.xml.gz`], [1,12 GB / 1.070 MiB (`sha256: 812fd7d6...`)],
      [Total XML], [13.127.979 record (9 tipe publikasi)],
      [2015–2025 Raw], [2.004.202 `<inproceedings>`],
    )
  ],
)

// =========================================================================
= Task 1: Data Understanding & Preprocessing
// =========================================================================

== Task 1.1 — Struktur, Atribut & Jenis Publikasi XML

#grid(
  columns: (1fr, 1.1fr),
  column-gutter: 14pt,
  [
    #table(
      columns: (1fr, auto, auto),
      align: (left, right, right),
      [*Tipe Elemen XML*], [*Jumlah*], [*Pangsa*],
      [`article`], [4.527.388], [34,49%],
      [`www`], [4.247.510], [32,35%],
      [*`inproceedings`*], [*4.004.309*], [*30,50%*],
      [`phdthesis`], [158.395], [1,21%],
      [`incollection`], [71.264], [0,54%],
      [`proceedings`], [65.903], [0,50%],
      [`data` + `book` + `master`], [53.210], [0,40%],
      [*Total XML DBLP*], [*13.127.979*], [*100,00%*],
    )
    - Dari `4,00M` `<inproceedings>`, *2.004.202* berada pada 2015–2025.
    - Temuan awal: `190` `venue` null, `2.255` `authors` kosong.
  ],
  [
    #image("../outputs/figures/01_xml_publication_types.png", width: 100%)
  ],
)

== Task 1.2–1.3 — Preprocessing: Seleksi & Missing Values

#table(
  columns: (1fr, 1.3fr, 1.5fr),
  align: (left, left, left),
  [*Ketentuan*], [*Metode Diterapkan*], [*Alasan Pemilihan Metode*],
  [1. Pilih konferensi & _workshop_],
  [_Streaming_ `lxml.etree.iterparse` tag `<inproceedings>` + `load_dtd=True`],
  [File XML >4 GB tak terkompresi; _streaming_ hemat RAM & mendekode entitas karakter DTD secara presisi.],
  [2. Konsistensi tahun publikasi],
  [Konversi numerik `int32` + filter rentang `2015–2025`],
  [Memastikan seluruh data valid dalam rentang 11 tahun sebelum analisis tren & pembagian periode temporal.],
  [3. Penanganan _missing values_],
  [Hapus baris dengan `key`, `title`, `venue` kosong atau `authors` kosong (`-2.445` baris)],
  [`authors` & `venue` merupakan entitas dan _item_ transaksi wajib; tidak dapat diimputasi tanpa memicu asosiasi fiktif.],
)

== Task 1.2 & 1.3 — Preprocessing: Normalisasi & Deduplikasi

#table(
  columns: (1fr, 1.3fr, 1.5fr),
  align: (left, left, left),
  [*Ketentuan*], [*Metode Diterapkan*], [*Alasan Pemilihan Metode*],
  [4. Normalisasi nama _author_],
  [Unicode NFC + kolaps spasi + dedup per paper, *pertahankan* suffix DBLP (`0001`)],
  [NFC menyatukan karakter beraksen; suffix `0001` krusial untuk membedakan peneliti homonim agar transaksi tidak tercampur.],
  [5. Normalisasi nama _venue_],
  [Seragamkan `@`, `(Workshops) -> Workshops`, alias `NIPS -> NeurIPS`, _canonical casing_],
  [Menyatukan varian nama konferensi yang berganti nama (NIPS $arrow$ NeurIPS) & perbedaan kapitalisasi agar _support_ tidak terpecah.],
  [6. Hilangkan data duplikat],
  [Deduplikasi 2 level: `key` DBLP, lalu `(normalized_title, year, venue)` (`-1.000` baris)],
  [Menghapus entri ganda akibat _cross-indexing_ prosiding atau perbedaan tanda baca judul di tahun dan _venue_ yang sama.],
)

== Task 1.4 — Statistik Dataset Setelah Preprocessing

#grid(
  columns: (1.25fr, 1fr),
  column-gutter: 16pt,
  [
    #table(
      columns: (1.5fr, auto, auto),
      align: (left, right, right),
      [*Tahap Preprocessing*], [*Jumlah*], [*Persen*],
      [Raw (`<inproceedings>` 2015–2025)], [2.004.202], [100,00%],
      [Dropped: invalid year], [0], [0,00%],
      [Dropped: missing `key`/`title`], [0], [0,00%],
      [Dropped: missing/empty `venue`], [-190], [-0,01%],
      [Dropped: empty `authors`], [-2.255], [-0,11%],
      [Dropped: duplicate `key`], [0], [0,00%],
      [Dropped: dup `(title_norm, year, venue)`], [-1.000], [-0,05%],
      [*Cleaned records*], [*2.000.757*], [*99,83%*],
    )
  ],
  [
    / *Total Publikasi Bersih*: *2.000.757* makalah (`conf`: 1.997.597; `journals`: 3.120; `books`: 40)
    / *Total Author Unik*: *1.822.489* peneliti
    / *Total Conference/Venue Unik*: *8.780* _venue_
  ],
)

== Task 1.4 — Distribusi Publikasi per Tahun (2015–2025)

#grid(
  columns: (0.95fr, 1.35fr),
  column-gutter: 14pt,
  [
    #table(
      columns: (auto, auto, auto),
      align: (center, right, right),
      [*Tahun*], [*Publikasi*], [*Pangsa*],
      [2015], [161.306], [8,06%],
      [2016], [162.168], [8,11%],
      [2017], [168.130], [8,40%],
      [2018], [176.634], [8,83%],
      [2019], [188.767], [9,43%],
      [2020], [172.070], [8,60%],
      [2021], [178.488], [8,92%],
      [2022], [178.329], [8,91%],
      [2023], [201.702], [10,08%],
      [2024], [213.580], [10,67%],
      [2025], [199.583], [9,98%],
    )
  ],
  [
    #image("../outputs/figures/01_publications_per_year.png", width: 100%)
    - Pertumbuhan +32,4% dari 2015 ke puncak 2024.
    - Koreksi 2020 (-8,8%) akibat pandemi COVID-19; 2025 sedikit turun karena jeda indeksasi akhir tahun.
  ],
)

== Task 1.4 — Distribusi Publikasi per Conference/Venue

#grid(
  columns: (0.85fr, 1.35fr),
  column-gutter: 14pt,
  [
    *Statistik Sebaran (8.780 Venue)*:
    #table(
      columns: (1fr, auto),
      align: (left, right),
      [*Statistik*], [*Nilai*],
      [Total Venue Unik], [8.780],
      [Rata-rata / Venue], [227,88],
      [Simpangan Baku], [847,02],
      [Median / Q1 / Q3], [48,5 / 16 / 180],
      [Min / Maks], [1 / 25.004],
      [Venue $gt.eq 100$ paper], [3.146],
      [Pangsa Top 10], [8,34%],
    )
    Distribusi sangat _right-skewed_ (ekor panjang / _long-tail_).
  ],
  [
    #image("../outputs/figures/01_top20_venues.png", width: 100%)
  ],
)

// =========================================================================
= Task 2: Conference Popularity Analysis
// =========================================================================

== Task 2.1 — Top 10 Konferensi: Jumlah Publikasi

#grid(
  columns: (0.95fr, 1.2fr),
  column-gutter: 14pt,
  [
    #table(
      columns: (auto, 1fr, auto, auto),
      align: (center, left, right, right),
      [*Rank*], [*Conference*], [*Publikasi*], [*Pangsa*],
      [1], [*NeurIPS*], [25.004], [1,25%],
      [2], [ICASSP], [21.125], [1,06%],
      [3], [IGARSS], [19.685], [0,98%],
      [4], [AAAI], [18.406], [0,92%],
      [5], [CVPR], [17.435], [0,87%],
      [6], [EMBC], [14.676], [0,73%],
      [7], [ICML], [13.617], [0,68%],
      [8], [IROS], [12.832], [0,64%],
      [9], [ICRA], [12.361], [0,62%],
      [10], [CDC], [11.666], [0,58%],
    )
  ],
  [
    #image("../outputs/figures/02a_top10_publications.png", width: 100%)
    - *NeurIPS* memimpin jauh (\#1) dengan 25.004 publikasi (+18,4% di atas ICASSP).
  ],
)

== Task 2.2 — Top 10 Konferensi: Author Unik

#grid(
  columns: (0.95fr, 1.2fr),
  column-gutter: 14pt,
  [
    #table(
      columns: (auto, 1fr, auto, auto),
      align: (center, left, right, right),
      [*Rank*], [*Conference*], [*Author Unik*], [*Proporsi*],
      [1], [*NeurIPS*], [56.073], [3,08%],
      [2], [AAAI], [44.604], [2,45%],
      [3], [ICASSP], [41.097], [2,25%],
      [4], [EMBC], [39.318], [2,16%],
      [5], [IGARSS], [35.229], [1,93%],
      [6], [CVPR], [34.970], [1,92%],
      [7], [ICML], [31.397], [1,72%],
      [8], [IROS], [31.200], [1,71%],
      [9], [IJCNN], [29.803], [1,64%],
      [10], [ICLR], [28.751], [1,58%],
    )
  ],
  [
    #image("../outputs/figures/02b_top10_unique_authors.png", width: 100%)
    - *IJCNN* (\#9) dan *ICLR* (\#10) masuk menggantikan ICRA dan CDC pada metrik partisipasi peneliti.
  ],
)

== Task 2.3 — Tren Jumlah Publikasi Tahunan (2015–2025)

#grid(
  columns: (1.25fr, 0.9fr),
  column-gutter: 14pt,
  [
    #image("../outputs/figures/02_top10_conferences_trend.png", width: 100%)
  ],
  [
    *Perubahan Aktivitas Publikasi*:
    - *2015*: Didominasi konferensi teknik (`EMBC` 2.004, `IGARSS` 1.353, `CDC` 1.258).
    - *2018–2025*: Lonjakan eksponensial AI/ML & Vision:
      - *NeurIPS*: `403 -> 5.823` (*14,4×*)
      - *ICML*: `270 -> 3.257` (*12,1×*)
      - *AAAI*: `673 -> 3.485` (*5,2×*)
      - *CVPR*: `601 -> 2.871` (*4,8×*)
    - *Catatan*: `IGARSS` & `EMBC` bernilai `0` di 2025 karena jeda indeksasi prosiding IEEE di _snapshot_ DBLP.
  ],
)

== Task 2.4 — Perbandingan Ranking: Publikasi vs Author Unik

#grid(
  columns: (1.15fr, 1fr),
  column-gutter: 12pt,
  [
    #table(
      columns: (1fr, auto, auto, auto, auto, auto),
      align: (left, right, right, center, center, right),
      [*Venue*], [*Pub*], [*Auth*], [*R.Pub*], [*R.Auth*], [*Diff*],
      [NeurIPS], [25.004], [56.073], [1], [1], [0],
      [ICASSP], [21.125], [41.097], [2], [3], [-1],
      [IGARSS], [19.685], [35.229], [3], [5], [-2],
      [AAAI], [18.406], [44.604], [4], [2], [*+2*],
      [CVPR], [17.435], [34.970], [5], [6], [-1],
      [EMBC], [14.676], [39.318], [6], [4], [*+2*],
      [ICML], [13.617], [31.397], [7], [7], [0],
      [CDC], [11.666], [14.393], [10], [*35*], [*-25*],
      [IJCNN], [11.583], [29.803], [11], [*9*], [+2],
      [INTERSPEECH], [10.749], [17.834], [15], [*25*], [-10],
    )
  ],
  [
    #image("../outputs/figures/02_pub_vs_authors_scatter.png", width: 100%)
    - Korelasi Spearman global (8.780 _venue_): *$rho = 0,9811$*.
  ],
)

== Task 2.5 — Interpretasi Analisis Popularitas Konferensi

/ *1. Konferensi paling populer berdasarkan jumlah publikasi?*:
  *NeurIPS* menempati peringkat \#1 dengan *25.004* publikasi sepanjang 2015–2025, unggul atas ICASSP (21.125) dan IGARSS (19.685).

/ *2. Apakah publikasi terbanyak = author unik terbanyak?*:
  *Ya di peringkat \#1* (*NeurIPS*: 56.073 _author_ unik), namun peringkat di bawahnya bergeser: *AAAI* (\#4 $arrow$ \#2) dan *EMBC* (\#6 $arrow$ \#4; 2,68 _author_/paper) memiliki tim kolaborasi besar, sedangkan *CDC* (\#10 $arrow$ \#35; 1,23 _author_/paper) dan *INTERSPEECH* (\#15 $arrow$ \#25) didominasi penulis berulang dalam komunitas yang lebih kecil.

/ *3. Bagaimana perubahan aktivitas publikasi selama 2015–2025?*:
  Terjadi pergeseran pusat gravitasi riset dari konferensi sinyal/kendali/biomedis klasik (2015–2017) ke pertumbuhan eksplosif AI/ML dan _Computer Vision_ (2018–2025).

// =========================================================================
= Task 3: Transactional Database Construction
// =========================================================================

== Task 3.1 — Konstruksi Dua Transactional Database

#grid(
  columns: (1fr, 1fr),
  column-gutter: 16pt,
  [
    / *A. Author-Based Transaction*:
      - *Definisi*: 1 transaksi = 1 _author_ unik.
      - *Item*: daftar unik konferensi tempat _author_ memublikasikan paper selama 2015–2025.
      - *Proses (`src/transactions.py`)*: `explode("authors")` $arrow$ `drop_duplicates(["author", "venue"])` $arrow$ agregasi `sorted(list)`.
      - *Output*: `tx_author_based.parquet` (*1.822.489* transaksi).
  ],
  [
    / *B. Author-Year-Based Transaction*:
      - *Definisi*: 1 transaksi = 1 pasangan `(author, year)`.
      - *Item*: daftar unik konferensi tempat _author_ memublikasikan paper pada tahun tersebut.
      - *Proses (`src/transactions.py`)*: `explode("authors")` $arrow$ `drop_duplicates(["author", "year", "venue"])` $arrow$ agregasi `sorted(list)`.
      - *Output*: `tx_author_year_based.parquet` (*4.088.557* transaksi).
  ],
)

== Task 3.2a — Contoh Data: 10 Transaksi Author-Based

#table(
  columns: (auto, 1fr, auto, 2.3fr),
  align: (center, left, center, left),
  [*No*], [*Author*], [*Jml*], [*Items (Daftar Conference / Venue)*],
  [1], [Simone Bianco 0001], [27], [`ACIVS, AI*IA, CCIW, CIC, CVPR, CVPR Workshops, ECAI, ECCV Workshops (3), ... (+19)`],
  [2], [Dominic Price], [10], [`AIES (Main Track III), CHI, Designing Interactive Systems, ... (+7)`],
  [3], [Jingtao Zhou], [8], [`CHI, CHI Extended Abstracts, ICASSP, ICCMA, KSEM (1), SIGGRAPH Asia, UIST (Adjunct), VR Workshops`],
  [4], [Vaidyanathan P. Ramaswamy], [7], [`AAAI, CP, ICCS (2), ICTAI, NSE@ICSE, NeurIPS, UAI`],
  [5], [Raquel Robinson], [7], [`CHI Extended Abstracts, CHI PLAY, CHI PLAY (Companion), EMPATHICH, FDG, ICIDS, TEI`],
  [6], [Zixi Zhang], [3], [`CDC, FCCM, ICBCT`],
  [7], [Honghai Ma], [3], [`CISP-BMEI, IECON, IROS`],
  [8], [Luis R. Castrejon], [2], [`EMBC, ICORR`],
  [9], [Saghar Irandoust], [2], [`ICRA, NeurIPS`],
  [10], [Nihar Ranja Sahoo], [1], [`AAAI`],
)

== Task 3.2b — Contoh Data: 10 Transaksi Author-Year-Based

#table(
  columns: (auto, 1fr, auto, auto, 2fr),
  align: (center, left, center, center, left),
  [*No*], [*Author*], [*Tahun*], [*Jml*], [*Items (Daftar Conference / Venue)*],
  [1], [A. David Marshall], [2015], [4], [`AVSP, BMVC, KES, SAS`],
  [2], [Yuxi Chen], [2025], [4], [`EASE, ICANN (2), ICRA, MICCAI (11)`],
  [3], [Natalija Gucevska], [2021], [3], [`EASE, ESEM, ICSE (SEIP)`],
  [4], [Haiyang Jiang 0002], [2025], [3], [`CVPR, ICCVW, ICLR`],
  [5], [Chuanbin Liu 0001], [2022], [3], [`ACM Multimedia, ICMR, NeurIPS`],
  [6], [Qingsong Yan], [2025], [3], [`3DV, ICME, IROS`],
  [7], [Damiano Varagnolo], [2018], [2], [`ECC, IECON`],
  [8], [Nicola Costantino], [2015], [2], [`EMPIRE@RecSys, IEEM`],
  [9], [Shadi Saleh], [2018], [1], [`CLEF (Working Notes)`],
  [10], [Markus Fält], [2021], [1], [`ICSRS`],
)

== Task 3.3–3.4 — Jumlah Transaksi & Distribusi Panjang

#grid(
  columns: (0.95fr, 1.25fr),
  column-gutter: 12pt,
  [
    #table(
      columns: (1.2fr, auto, auto),
      align: (left, right, right),
      [*Metrik*], [*Author*], [*Author-Year*],
      [Transaksi ($N$)], [1.822.489], [4.088.557],
      [Item Unik], [8.780], [8.780],
      [Single-Item (`1`)], [57,42%], [70,28%],
      [Multi-Item (`>=2`)], [42,58%], [29,72%],
      [Mean ($plus.minus$ SD)], [2,86 ($plus.minus$5,08)], [1,63 ($plus.minus$1,49)],
      [Median / P95 / Max], [1 / 10 / 396], [1 / 4 / 88],
      [Panjang `>10`], [81.581 (4,48%)], [15.806 (0,39%)],
    )
  ],
  [
    #image("../outputs/figures/03_tx_length_distribution.png", width: 100%)
  ],
)

== Task 3.5–3.6 — Perbedaan, Kelebihan & Keterbatasan

#table(
  columns: (auto, 1.1fr, 1.1fr),
  align: (left, left, left),
  [*Aspek*], [*Author-Based Transaction*], [*Author-Year-Based Transaction*],
  [*Perbedaan Kunci*],
  [Menggabungkan seluruh riwayat 11 tahun per peneliti (keranjang lebih padat: 42,58% multi-item).],
  [Memecah riwayat per tahun aktif (2,24× lebih banyak transaksi namun sangat _sparse_: 70,28% 1-item).],
  [*Kelebihan FPM*],
  [- Menangkap pola lintas-tahun termasuk konferensi _biennial_ (`ICCV`–`ECCV`).\ - Menghasilkan _itemsets_ & _rules_ jauh lebih kaya pada `min_support` sama.],
  [- Mempertahankan dimensi waktu untuk *Temporal Association Analysis*.\ - Menangkap ko-publikasi intensif simultan dalam tahun yang sama.],
  [*Keterbatasan FPM*],
  [- Menghilangkan informasi kronologis (2015 dan 2025 dianggap setara).\ - Bisa mencampur pergeseran bidang riset jangka panjang.],
  [- _Support_ kombinasi sangat kecil akibat tingginya transaksi 1-item.\ - Gagal menangkap asosiasi konferensi _biennial_ di tahun berbeda.],
)

// =========================================================================
= Task 4: Frequent Pattern Mining
// =========================================================================

== Task 4 — Metodologi Implementasi Apriori & FP-Growth

- *Basis Data*: _Author-Based Transactional Database_ ($N = 1.822.489$ transaksi, $8.780$ _venue_ unik).
- *4 Nilai Minimum Support*: `0,1%` ($0,001$), `0,5%` ($0,005$), `1%` ($0,01$), dan `2%` ($0,02$).
- *Optimasi Memori (`src/mining.py`)*: Matriks _dense_ `1,82M × 8.780` membutuhkan \~16 GiB RAM. Diterapkan *exact lossless column pruning* (hanya _venue_ dengan frekuensi $gt.eq ceil("min_sup" times N)$) dalam `scipy.sparse.csr_matrix` sambil mempertahankan seluruh $N = 1.822.489$ baris sehingga nilai `support` *100% eksak*.
- *Algoritma*: `mlxtend.frequent_patterns.apriori(..., low_memory=True)` dan `fpgrowth(...)` pada matriks sparse identik, disertai verifikasi kesetaraan himpunan _itemsets_.

== Task 4.1 & 4.2 — Identifikasi Frequent 1-, 2-, dan 3-Itemsets

#grid(
  columns: (1.05fr, 1fr),
  column-gutter: 12pt,
  [
    #table(
      columns: (auto, auto, auto, auto, auto, auto),
      align: (center, right, right, right, right, right),
      [*Min Sup*], [*1-IS*], [*2-IS*], [*3-IS*], [*4/5-IS*], [*Total*],
      [0,1%], [534], [333], [237], [93], [1.197],
      [0,5%], [63], [11], [1], [0], [75],
      [1,0%], [24], [1], [0], [0], [25],
      [2,0%], [4], [0], [0], [0], [4],
    )
    - *0,5%*: 11 pasang 2-IS + 1 trio `{ICLR, ICML, NeurIPS}`.
    - *1,0%*: 24 1-IS + tepat 1 pasang (`{ICML, NeurIPS}`), 0 trio.
    - *2,0%*: hanya 4 1-IS (`NeurIPS`, `AAAI`, `ICASSP`, `EMBC`).
  ],
  [
    #image("../outputs/figures/04a_itemsets_by_size.png", width: 100%)
  ],
)

== Task 4.3a — Top 10 Itemsets (`0,1%` & `0,5%`)

#table(
  columns: (auto, 1.3fr, auto, auto, auto, 1.3fr, auto, auto, auto),
  align: (center, left, center, right, right, left, center, right, right),
  [*No*], [*Itemset (0,1%)*], [*Len*], [*Sup (%)*], [*Tx*], [*Itemset (0,5%)*], [*Len*], [*Sup (%)*], [*Tx*],
  [1], [NeurIPS], [1], [3,08%], [56.073], [NeurIPS], [1], [3,08%], [56.073],
  [2], [AAAI], [1], [2,45%], [44.604], [AAAI], [1], [2,45%], [44.604],
  [3], [ICASSP], [1], [2,26%], [41.097], [ICASSP], [1], [2,26%], [41.097],
  [4], [EMBC], [1], [2,16%], [39.318], [EMBC], [1], [2,16%], [39.318],
  [5], [IGARSS], [1], [1,93%], [35.229], [IGARSS], [1], [1,93%], [35.229],
  [6], [CVPR], [1], [1,92%], [34.970], [CVPR], [1], [1,92%], [34.970],
  [7], [ICML], [1], [1,72%], [31.397], [ICML], [1], [1,72%], [31.397],
  [8], [IROS], [1], [1,71%], [31.200], [IROS], [1], [1,71%], [31.200],
  [9], [IJCNN], [1], [1,64%], [29.803], [IJCNN], [1], [1,64%], [29.803],
  [10], [ICLR], [1], [1,58%], [28.751], [ICLR], [1], [1,58%], [28.751],
)
#text(size: 9pt)[
  _Catatan_: Pada `0,5%`, kombinasi multi-item tertinggi berada di peringkat \#26 (`{ICML, NeurIPS}`, `1,00%`) dan \#70 (`{ICLR, ICML, NeurIPS}`, `0,54%`).
]

== Task 4.3b — Top 10 Itemsets (`1,0%` & `2,0%`)

#grid(
  columns: (1.15fr, 1fr),
  column-gutter: 14pt,
  [
    *Eksperimen `min_support = 1,0%` (Total 25 Itemsets)*:
    #table(
      columns: (auto, 1.3fr, auto, auto, auto),
      align: (center, left, center, right, right),
      [*No*], [*Itemset*], [*Len*], [*Sup (%)*], [*Author*],
      [1], [NeurIPS], [1], [3,08%], [56.073],
      [2], [AAAI], [1], [2,45%], [44.604],
      [3], [ICASSP], [1], [2,26%], [41.097],
      [4], [EMBC], [1], [2,16%], [39.318],
      [5], [IGARSS], [1], [1,93%], [35.229],
      [6], [CVPR], [1], [1,92%], [34.970],
      [7], [ICML], [1], [1,72%], [31.397],
      [8], [IROS], [1], [1,71%], [31.200],
      [9], [IJCNN], [1], [1,64%], [29.803],
      [10], [ICLR], [1], [1,58%], [28.751],
    )
    #text(size: 8.8pt)[_(Satu-satunya 2-itemset di 1%: `{ICML, NeurIPS}`, `1,0008%` / 18.239 author)_]
  ],
  [
    *Eksperimen `min_support = 2,0%` (Total 4 Itemsets)*:
    #table(
      columns: (auto, 1fr, auto, auto, auto),
      align: (center, left, center, right, right),
      [*No*], [*Itemset*], [*Len*], [*Sup (%)*], [*Author*],
      [1], [NeurIPS], [1], [3,08%], [56.073],
      [2], [AAAI], [1], [2,45%], [44.604],
      [3], [ICASSP], [1], [2,26%], [41.097],
      [4], [EMBC], [1], [2,16%], [39.318],
    )
    #v(0.2cm)
    Pada ambang `2,0%`, hanya 4 konferensi raksasa yang lolos sebagai 1-itemset dan *tidak ada* pola kombinasi antar-konferensi.
  ],
)

== Task 4.4 — Pengaruh Perubahan Minimum Support

#grid(
  columns: (1fr, 1.05fr),
  column-gutter: 14pt,
  [
    - Kenaikan `min_support` memangkas jumlah _frequent itemsets_ secara *eksponensial / non-linear* (sifat _anti-monotone_):
      `1.197` (`0,1%`) $arrow$ `75` (`0,5%`, turun 93,7%) $arrow$ `25` (`1,0%`) $arrow$ `4` (`2,0%`).
    - *Penyebab*: Basis data bibliografi berjumlah 8.780 _venue_ bersifat sangat _long-tail_, sehingga konferensi \#1 sekalipun hanya mencakup `3,08%` peneliti.
    - *Implikasi*: Ambang `1%–2%` terlalu ketat untuk studi ko-publikasi; ambang `0,1%` ($gt.eq 1.823$ _author_) paling informatif memetakan komunitas riset.
  ],
  [
    #image("../outputs/figures/04a_itemsets_by_size.png", width: 100%)
  ],
)

== Task 4.5 — Kombinasi Conference Paling Sering Bersama

#grid(
  columns: (1fr, 1fr),
  column-gutter: 12pt,
  [
    #image("../outputs/figures/04b_top_cooccurring_2itemsets.png", width: 100%)
    - 2-itemset \#1: *`{ICML, NeurIPS}`* (`1,00%` / 18.239 _author_), diikuti `{ICLR, NeurIPS}` (`0,93%`) & `{CVPR, ICCV}` (`0,75%`).
  ],
  [
    #image("../outputs/figures/04c_top_cooccurring_3itemsets.png", width: 100%)
    - 3-itemset \#1: *`{ICLR, ICML, NeurIPS}`* (`0,54%` / 9.924 _author_), diikuti `{CVPR, ICCV, NeurIPS}` (`0,43%`).
  ],
)

== Task 4.6 — Interpretasi Hasil Frequent Patterns

Kombinasi _frequent itemsets_ pada `min_support = 0,1%` menyingkap *5 klaster komunitas riset utama*:
+ *Machine Learning & Deep Learning*: `{ICLR, ICML, NeurIPS}` (9.924 _author_) sebagai poros peneliti pembelajaran mesin modern.
+ *Computer Vision*: `{CVPR, ICCV}` (13.588 _author_) dan `{CVPR, ICCV, ECCV}` (meski `ICCV` ganjil & `ECCV` genap).
+ *Artificial Intelligence Umum*: `{AAAI, IJCAI}` (11.010 _author_) yang juga beririsan kuat dengan ML (`{AAAI, ICML, NeurIPS}`) dan Vision (`{AAAI, CVPR, ICCV}`).
+ *Robotika*: `{ICRA, IROS}` (11.859 _author_; `0,65%`) sebagai duopol konferensi utama robotika.
+ *Telekomunikasi*: `{GLOBECOM, ICC}` (8.906 _author_; `0,49%`) dengan kohesi tinggi antar peneliti jaringan & komunikasi.

// =========================================================================
= Task 5: Association Rule Mining
// =========================================================================

== Task 5.1 & 5.2a — Top 10 Rules Berdasarkan Lift

- Dengan `min_confidence = 50%`: dihasilkan *730 rules* (`0,1%`), *6 rules* (`0,5%`), *1 rule* (`1,0%`), dan *0 rules* (`2,0%`).

#table(
  columns: (auto, 2fr, auto, auto, auto, auto),
  align: (center, left, right, right, right, right),
  [*No*], [*Association Rule (`min_support = 0,1%`)*], [*Sup (%)*], [*Conf (%)*], [*Lift*], [*Author*],
  [1], [`ACM Multimedia, CVPR, NeurIPS -> AAAI, ICCV`], [0,1276], [55,33], [*122,68*], [2.325],
  [2], [`CVPR, IJCAI, NeurIPS -> AAAI, ICCV`], [0,1072], [55,11], [122,18], [1.953],
  [3], [`ICCV, ICML, NeurIPS -> CVPR, ICLR`], [0,1321], [56,44], [122,14], [2.407],
  [4], [`ICCV, IJCAI, NeurIPS -> AAAI, CVPR`], [0,1072], [67,72], [113,66], [1.953],
  [5], [`ACM Multimedia, ICCV, NeurIPS -> AAAI, CVPR`], [0,1276], [66,56], [111,72], [2.325],
  [6], [`ICLR, IJCAI, NeurIPS -> AAAI, ICML`], [0,1215], [56,77], [107,18], [2.214],
  [7], [`ICML, IJCAI, NeurIPS -> AAAI, ICLR`], [0,1215], [52,24], [105,20], [2.214],
  [8], [`AAAI, CVPR, ICLR -> ICCV, NeurIPS`], [0,1376], [58,72], [102,54], [2.508],
  [9], [`AAAI, CVPR, ICML -> ICCV, NeurIPS`], [0,1243], [57,02], [99,57], [2.265],
  [10], [`ICCV, IJCAI -> AAAI, CVPR`], [0,1309], [59,09], [99,18], [2.386],
)

== Task 5.2b — Rules Support & Confidence Tertinggi

#grid(
  columns: (1.05fr, 1fr),
  column-gutter: 12pt,
  [
    #image("../outputs/figures/05b_top10_rules_lift.png", width: 100%)
  ],
  [
    *Seluruh Rules di `0,5%` (6) & `1,0%` (1)*:
    #table(
      columns: (1.4fr, auto, auto, auto),
      align: (left, right, right, right),
      [*Rule*], [*Sup*], [*Conf*], [*Lift*],
      [`ICML, NeurIPS -> ICLR`], [0,54%], [54,4%], [34,5×],
      [`ICLR, NeurIPS -> ICML`], [0,54%], [58,8%], [34,1×],
      [`ICCV -> CVPR`], [0,75%], [56,4%], [29,4×],
      [`ICLR, ICML -> NeurIPS`], [0,54%], [*80,8%*], [26,3×],
      [`ICLR -> NeurIPS`], [0,93%], [58,7%], [19,1×],
      [`ICML -> NeurIPS` (juga 1%)], [*1,00%*], [58,1%], [18,9×],
    )
    #text(size: 8.8pt)[_Conf tertinggi (0,1%)_: `AAAI, ICCV, ICLR, ICML -> NeurIPS` (*93,85%*, Lift 30,5×).]
  ],
)

== Task 5.3–5.4 — Asosiasi Menarik & Support vs Lift

#grid(
  columns: (1fr, 1.05fr),
  column-gutter: 14pt,
  [
    #image("../outputs/figures/05a_rules_scatter.png", width: 100%)
  ],
  [
    / *Asosiasi Menarik (Task 5.3)*:
      - *Multimodal–Vision–AI*: `ACM Multimedia, CVPR, NeurIPS -> AAAI, ICCV` (*Lift 122,68×*).
      - *Konfidensi >93%*: Penulis di `{AAAI, ICCV, ICLR, ICML}` 93,85% juga menerbitkan di `NeurIPS`.
      - *Domain Control*: `ACC, ECC -> CDC` (*Conf 73,35%*, *Lift 92,88×*).
    / *Support Tinggi $arrow.r.not$ Lift Tinggi (Task 5.4)*:
      - *Tidak.* `ICML -> NeurIPS` (Sup *1,00%*) hanya punya Lift *18,88×* karena $P("NeurIPS") = 3,08\%$ besar; rule spesifik punya Lift >100×.
  ],
)

== Task 5.5–5.6 — Interpretasi Metrik & Pola Asosiasi

#grid(
  columns: (1fr, 1fr),
  column-gutter: 16pt,
  [
    *Perbedaan Support, Confidence & Lift (Task 5.5)*:
    - *Support* ($P(A union B)$): mengukur *cakupan/popularitas* kombinasi dalam populasi.
    - *Confidence* ($P(B mid A)$): mengukur *kekuatan implikasi bersyarat*; rentan bias bila $B$ sangat populer.
    - *Lift* ($P(B mid A) / P(B)$): mengukur *kekuatan asosiasi sejati* di atas ekspektasi independen ($"Lift" > 1$ positif).
  ],
  [
    *Pola Publikasi Antar-Konferensi (Task 5.6)*:
    + *Poros Trio Deep Learning*: `ICLR, ICML -> NeurIPS` (Conf 80,78%) menunjukkan mobilitas peneliti ML yang sangat terpusat.
    + *Jembatan Vision–AI*: Peneliti Computer Vision aktif menggabungkan `CVPR–ICCV` dengan `NeurIPS`, `AAAI`, & `ACM Multimedia`.
    + *Kohesi Sub-bidang Khusus*: Domain lebih kecil seperti *Control* (`ACC, ECC -> CDC`) & *NLP* (`ACL`/`EMNLP`) membentuk ikatan eksklusif ber-_lift_ ~90×.
  ],
)

// =========================================================================
= Task 6: Algorithm Performance Comparison
// =========================================================================

== Task 6.1–6.2 — Jumlah Itemsets & Association Rules

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto),
  align: (center, right, right, right, center, right, right, right, right),
  [*Min Sup*], [*Kandidat*], [*Apriori IS*], [*FP-Growth IS*], [*Identik?*], [*Apriori Rules*], [*FP Rules*], [*Ap/FP (s)*], [*Ap/FP (MB)*],
  [0,1%], [534], [1.197], [1.197], [*Ya*], [730], [730], [21,26 / 77,93], [1.893,3 / 952,0],
  [0,5%], [63], [75], [75], [*Ya*], [6], [6], [1,02 / 53,59], [240,3 / 125,6],
  [1,0%], [24], [25], [25], [*Ya*], [1], [1], [0,35 / 57,76], [100,0 / 55,4],
  [2,0%], [4], [4], [4], [*Ya*], [0], [0], [0,05 / 50,61], [30,8 / 18,3],
)
#v(0.2cm)
- Jumlah _frequent itemsets_ (`1.197`, `75`, `25`, `4`) dan _association rules_ (`730`, `6`, `1`, `0`) dari kedua algoritma *100% identik* di setiap tingkat `min_support` (`galat support < 10^(-12)`).

== Task 6.Q1 & Q2 — Pengaruh `min_support` & Kesamaan Hasil

#grid(
  columns: (1.3fr, 0.9fr),
  column-gutter: 12pt,
  [
    #image("../outputs/figures/06_algorithm_performance_comparison.png", width: 100%)
  ],
  [
    - *Pengaruh `min_support`*:
      - Menurunkan `min_support` (`2% -> 0,1%`) menaikkan kandidat `4 -> 534`.
      - Waktu *Apriori* melonjak *414×* (`0,05s -> 21,26s`) & RAM *61,5×* (`30,8 -> 1.893,3 MB`).
      - Waktu *FP-Growth* relatif stabil (`50,6s -> 77,9s`) & RAM konsisten *\~50% lebih hemat*.
    - *Kesamaan*: Output *100% identik*.
  ],
)

== Task 6.Q3 — Algoritma Paling Sesuai untuk Dataset DBLP

#grid(
  columns: (1fr, 1fr),
  column-gutter: 16pt,
  [
    / *FP-Growth (Unggul Skalabilitas & Memori)*:
      - Memangkas _peak memory_ hingga *~50%* (`952 MB` vs `1.893 MB` di `0,1%`).
      - Menghindari ledakan _candidate generation_ sehingga paling aman dan skalabel untuk `N = 1,82M` transaksi saat mengeksplorasi `min_support <= 0,1%` di lingkungan RAM terbatas.
  ],
  [
    / *Catatan Implementasi `mlxtend`*:
      - Pada `0,1%–2%`, *Apriori (`low_memory=True` sparse)* mencatat _wall-clock_ lebih cepat (`21,3s` vs `77,9s`) berkat vektorisasi array NumPy/SciPy pada matriks CSR.
      - `mlxtend.fpgrowth` menanggung _overhead_ tetap \~50s membangun FP-Tree di _pure Python_.
  ],
)

// =========================================================================
= Bagian E: Temporal Association Analysis
// =========================================================================

== Bagian E.1–E.2 — Frequent Itemsets per Periode

Eksperimen dijalankan pada *Author-Year-Based Transactional Database* (`4.088.557` transaksi) dalam 4 periode:

#table(
  columns: (auto, auto, 1.35fr, 1.55fr),
  align: (center, right, left, left),
  [*Periode*], [*Tx (Multi%)*], [*Top 3 1-Itemsets (`0,10%`)*], [*Top 3 2-Itemsets (`0,10%`)*],
  [2015–2017], [922.999 (30,0%)], [`EMBC` (1,87%), `IGARSS` (1,49%), `ICC` (1,12%)], [`GLOBECOM, ICC` (0,25%), `ACC, CDC` (0,20%), `ICRA, IROS` (0,19%)],
  [2018–2020], [1.081.611 (29,0%)], [`IGARSS` (1,78%), `EMBC` (1,62%), `AAAI` (1,34%)], [`ICML, NeurIPS` (0,24%), `ICRA, IROS` (0,20%), `AAAI, IJCAI` (0,20%)],
  [2021–2023], [1.196.891 (28,8%)], [`NeurIPS` (2,59%), `CVPR` (1,86%), `AAAI` (1,76%)], [`ICML, NeurIPS` (0,45%), `ICLR, NeurIPS` (0,41%), `CVPR, ICCV` (0,39%)],
  [2024–2025], [887.056 (31,6%)], [`NeurIPS` (4,93%), `AAAI` (2,90%), `ICLR` (2,81%)], [`ICLR, NeurIPS` (1,04%), `ICML, NeurIPS` (0,98%), `CVPR, NeurIPS` (0,77%)],
)
#v(0.1cm)
#text(size: 9.2pt)[Terlihat pergeseran peringkat \#1 dari *EMBC/IGARSS* (2015–2020) menjadi *NeurIPS* (2021–2025) beserta pasangan `{ICLR/ICML, NeurIPS}`.]

== Bagian E.3 — Association Rules per Periode

#grid(
  columns: (1.05fr, 1fr),
  column-gutter: 12pt,
  [
    #table(
      columns: (auto, auto, auto, auto, auto),
      align: (center, right, right, right, right),
      [*Periode*], [*IS (0,1%)*], [*Rules (0,1%)*], [*IS (0,05%)*], [*Rules (0,05%)*],
      [2015–2017], [302], [1], [799], [1],
      [2018–2020], [279], [0], [763], [0],
      [2021–2023], [306], [2], [792], [15],
      [2024–2025], [420], [*37*], [1.065], [*212*],
    )
    - *2015–2017*: `ECOC -> OFC` (Conf 51,6%, Lift 59,8×).
    - *2021–2023*: `ICCV, NeurIPS -> CVPR` & `ICLR, ICML -> NeurIPS` (0,1%).
    - *2024–2025*: Lonjakan masif hingga *37* (`0,1%`) dan *212* rules (`0,05%`).
  ],
  [
    #image("../outputs/figures/07_temporal_counts.png", width: 100%)
  ],
)

== Bagian E.4–E.5 — Pola Bertahan vs Berubah Antarperiode

#grid(
  columns: (1.15fr, 0.95fr),
  column-gutter: 12pt,
  [
    #image("../outputs/figures/08_temporal_rules_heatmap.png", width: 100%)
  ],
  [
    *Klasifikasi Evolusi (`min_sup = 0,05%`)*:
    - *Declining / Hilang (2015–2017)*: `ECOC -> OFC` (Lift `59,8×`), hilang setelah 2017.
    - *Stabil Modern (2021–2025)*: *12 rules* bertahan kuat lintas 2021–2023 & 2024–2025 (`ICLR, ICML -> NeurIPS`, `ICCV, NeurIPS -> CVPR`, `ACL (1), EMNLP (Findings) -> EMNLP`).
    - *Emerging Masif (2024–2025)*: *200 rules baru* muncul di 2024–2025, didominasi asosiasi 3–4 konferensi AI/NLP (`ACL/EMNLP` + `ICLR/NeurIPS/ICML`).
  ],
)

== Bagian E.6 — Perubahan Tren Publikasi (2015–2025)

+ *Pergeseran Fokus Sub-bidang*: Pada 2015–2020, ko-publikasi tahunan yang erat didominasi komunitas teknik elektro/optik/kendali (`ECOC–OFC`, `GLOBECOM–ICC`, `ACC–CDC`). Pasca-2020, pusat aktivitas bergeser mutlak ke riset AI/ML, _Computer Vision_, dan _NLP_.
+ *Dampak Ledakan Deep Learning, LLM & Multimodal AI (2021–2025)*: Peningkatan dukungan komputasi, model fondasi (*LLM*), dan konvergensi visi-bahasa mendorong peneliti menerbitkan banyak makalah dalam satu tahun kalender di klaster `NeurIPS–ICML–ICLR–CVPR–ACL–EMNLP` (proporsi multi-item naik ke *31,58%*).
+ *Efek Normalisasi Lift*: Nilai *lift* ke `NeurIPS` atau `CVPR` menurun di 2024–2025 meski *support* naik 2–3× karena jumlah partisipan dasar konferensi tujuan membesar hampir dua kali lipat (*semakin mainstream*).

// =========================================================================
= Keterbatasan & Kesimpulan (Bagian F & H)
// =========================================================================

== Bagian F.8 — Keterbatasan Dataset & Asumsi Analisis

+ *Jeda Indeksasi Parsial Tahun 2025*: Beberapa prosiding IEEE tahun 2025 (`IGARSS`, `EMBC`) belum terindeks pada *snapshot* 19 November 2026 (`0` record di 2025), sehingga total volume 2025 sedikit lebih rendah dari 2024.
+ *Granularitas Prosiding Track/Findings*: Pemisahan `ACL (1)` vs `ACL (Findings)` dan `EMNLP` vs `EMNLP (Findings)` dipertahankan sesuai metadata DBLP, yang turut memicu aturan intra-komunitas NLP ber-*lift* tinggi di 2021–2025.
+ *Ketergantungan Disambiguasi DBLP*: Suffix numerik (`0001`) dipertahankan dengan asumsi DBLP akurat memisahkan peneliti homonim.
+ *Popularitas Berbasis Aktivitas*: Popularitas mencerminkan volume publikasi & partisipasi peneliti, bukan tingkat selektivitas (*acceptance rate*) atau dampak sitasi.

== Bagian H — Jawaban Pertanyaan Kesimpulan (1–4)

+ *Konferensi dengan popularitas publikasi tertinggi?*
  *NeurIPS* (\#1 jumlah publikasi: *25.004*; \#1 _author_ unik: *56.073*), diikuti *ICASSP* (21.125) & *IGARSS* (19.685) pada publikasi, serta *AAAI* (44.604) pada _author_ unik.
+ *Apakah konferensi paling populer memiliki asosiasi paling kuat?*
  *Tidak selalu.* `NeurIPS` memuncaki rule ber-_support_ tertinggi (`ICML -> NeurIPS`, `1,0008%`), tetapi *lift*-nya moderat (*18,88×*) karena popularitas dasar NeurIPS sangat besar (`3,08%`).
+ *Kombinasi konferensi paling sering muncul bersama?*
  2-konferensi: *`{ICML, NeurIPS}`* (`1,0008%` / 18.239 _author_), `{ICLR, NeurIPS}` (`0,93%`), `{CVPR, ICCV}` (`0,75%`). \
  3-konferensi: *`{ICLR, ICML, NeurIPS}`* (`0,5445%` / 9.924 _author_).
+ *Association rule dengan lift tertinggi & maknanya?*
  *`ACM Multimedia, CVPR, NeurIPS -> AAAI, ICCV`* (*Lift 122,68×*, Conf `55,33%`, Sup `0,1276%`): peneliti dengan rekam jejak di ketiga konferensi tersebut berkecenderungan 122,68× lebih tinggi untuk juga aktif di AAAI dan ICCV (klaster _Multimodal AI & Vision_).

== Bagian H — Jawaban Pertanyaan Kesimpulan (5–7) & Penutup

+ *Perbedaan pola Author-Based vs Author-Year-Based?*
  *Ya, sangat signifikan.* *Author-Based* jauh lebih padat (`1.197` itemsets, `730` rules di `0,1%`) dan menangkap hubungan _biennial_ (`CVPR–ICCV`). *Author-Year-Based* sangat _sparse_ (`70,28%` 1-item) namun mampu melacak evolusi temporal.
+ *Algoritma dengan performa terbaik?*
  Hasil *100% identik*. *FP-Growth* paling unggul pada efisiensi memori (\~50% lebih hemat: `952 MB` vs `1.893 MB` di `0,1%`) dan skalabilitas tanpa kandidat; *Apriori sparse (`mlxtend`)* lebih cepat secara _wall-clock_ di `0,1%–2%` berkat vektorisasi SciPy/NumPy.
+ *Insight utama penelitian?*
  Riset Ilmu Komputer 2015–2025 bergeser kuat ke ekosistem *AI/ML, Vision, dan NLP*, ditunjukkan oleh dominasi pertumbuhan `NeurIPS/ICML/AAAI/CVPR`, klaster riset lintas-konferensi yang erat, dan lonjakan `>14×` aturan asosiasi tahunan pada 2024–2025 (`15 -> 212` rules di `0,05%`).
