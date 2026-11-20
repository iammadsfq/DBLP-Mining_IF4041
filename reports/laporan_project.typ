#set document(
  title: "Conference Popularity and Association Pattern Mining Using DBLP Dataset (2015–2025)",
  author: "Kelompok Project IF4041 Penambangan Data",
)

#set page(
  paper: "a4",
  margin: (top: 2.3cm, bottom: 2.3cm, left: 2.4cm, right: 2.4cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 8.5pt, fill: luma(110))
      IF4041 Penambangan Data — DBLP Conference Popularity & Association Pattern Mining
      #h(1fr)
      2015–2025
      #line(length: 100%, stroke: 0.4pt + luma(180))
    ]
  },
  footer: context {
    if counter(page).get().first() > 1 [
      #line(length: 100%, stroke: 0.4pt + luma(180))
      #set text(size: 8.5pt, fill: luma(110))
      Laporan Project Data Mining
      #h(1fr)
      Halaman #counter(page).display("1 / 1", both: true)
    ]
  },
)

#set text(font: ("Helvetica Neue", "Arial"), size: 10pt, lang: "id")
#set par(justify: true, leading: 0.65em, spacing: 0.85em)
#set heading(numbering: "1.1.")

#show heading.where(level: 1): it => block(above: 1.5em, below: 0.7em)[
  #set text(size: 13pt, weight: "bold", fill: rgb("#0F4D92"))
  #it
  #v(-0.4em)
  #line(length: 100%, stroke: 0.8pt + rgb("#0F4D92"))
]

#show heading.where(level: 2): it => block(above: 1.1em, below: 0.5em)[
  #set text(size: 11pt, weight: "bold", fill: rgb("#1E3A5F"))
  #it
]

#show table: set text(size: 8.8pt)
#set table(
  stroke: (x, y) => (
    top: if y == 0 { 1.2pt + rgb("#0F4D92") } else if y == 1 { 0.8pt + rgb("#0F4D92") } else { 0.3pt + luma(210) },
    bottom: 0.5pt + luma(190),
    left: none,
    right: none,
  ),
  fill: (x, y) => if y == 0 { rgb("#EAF1F8") } else if calc.odd(y) { white } else { rgb("#F8FAFC") },
  inset: (x: 6pt, y: 5pt),
)

// ===================== COVER PAGE =====================
#align(center)[
  #v(1.2cm)
  #text(size: 11pt, weight: "bold", fill: rgb("#0F4D92"), tracking: 1.2pt)[LAPORAN PROJECT DATA MINING (IF4041)]
  #v(0.8cm)
  #text(size: 20pt, weight: "bold", fill: rgb("#102A43"))[
    Conference Popularity and Association Pattern Mining Using DBLP Dataset
  ]
  #v(0.35cm)
  #text(size: 12pt, fill: luma(80))[
    Analisis Popularitas Konferensi, Frequent Pattern Mining (Apriori & FP-Growth), Association Rule Mining, dan Analisis Asosiasi Temporal pada Publikasi Ilmu Komputer (2015–2025)
  ]
  #v(1.2cm)
  #line(length: 65%, stroke: 1.5pt + rgb("#0F4D92"))
  #v(1.2cm)

  #box(width: 82%, inset: 14pt, radius: 6pt, fill: rgb("#F8FAFC"), stroke: 0.6pt + luma(210))[
    #align(left)[
      #text(weight: "bold", fill: rgb("#0F4D92"))[Informasi Kelompok]
      #v(0.3cm)
      #grid(
        columns: (130pt, 1fr),
        row-gutter: 6pt,
        [Mata Kuliah], [: IF4041 — Penambangan Data],
        [Anggota Kelompok], [: _[Isi Nama & NIM Anggota 1]_, _[Anggota 2]_, _[Anggota 3]_],
        [Dosen Pengampu], [: _[Isi Nama Dosen Pengampu]_],
        [Periode Dataset], [: DBLP XML Dump (Publikasi Konferensi & Workshop 2015–2025)],
        [Tanggal Snapshot], [: 19 November 2026 (DBLP Official Mirror)],
      )
    ]
  ]

  #v(1.5cm)
  #box(width: 88%, inset: 12pt, radius: 6pt, fill: rgb("#EAF1F8"))[
    #set text(size: 9.2pt)
    *Ringkasan Eksekutif*: Project ini mengekstrak dan membersihkan *2.000.757* publikasi konferensi & workshop (`<inproceedings>`) dari *13,13 juta* entri DBLP XML pada periode 2015–2025, melibatkan *1.822.489* author unik dan *8.780* venue unik. *NeurIPS* merupakan konferensi paling populer baik dari jumlah publikasi (*25.004*) maupun author unik (*56.073*). Eksperimen *Frequent Pattern Mining* dengan Apriori dan FP-Growth menghasilkan himpunan itemsets *100% identik* (1.197 itemsets dan 730 association rules pada `min_support = 0.1%`, `min_confidence = 50%`), dengan *FP-Growth* menghemat memori hingga ~50%. Analisis temporal *Author-Year* (4,09 juta transaksi) mengungkap lonjakan dramatis ko-publikasi multi-konferensi pada periode 2021–2025 yang didominasi ekosistem AI/ML, Computer Vision, dan NLP.
  ]
]

#pagebreak()

#outline(title: [Daftar Isi], indent: 1.5em, depth: 2)
#pagebreak()

// ===================== 1. PENDAHULUAN =====================
= Pendahuluan

== Latar Belakang
Publikasi ilmiah pada konferensi dan workshop merupakan saluran diseminasi utama di bidang Ilmu Komputer (*Computer Science*). *DBLP (Digital Bibliography & Library Project)* menyediakan basis data bibliografi terbuka yang mencatat jutaan publikasi beserta metadata penulis, judul, tahun, dan *venue* publikasi. Pertumbuhan pesat penelitian—terutama pada sub-bidang Kecerdasan Buatan, Pembelajaran Mesin, *Computer Vision*, dan *Natural Language Processing*—menciptakan dinamika popularitas konferensi serta pola keterkaitan antar-konferensi yang tercermin dari riwayat publikasi para peneliti.

== Rumusan Masalah dan Tujuan
Project ini bertujuan untuk:
1. Melakukan eksplorasi dan *preprocessing* dataset bibliografi DBLP (periode 2015–2025) menjadi data bersih yang siap ditambang.
2. Menganalisis popularitas konferensi berdasarkan jumlah publikasi, jumlah author unik, dan tren tahunan 2015–2025.
3. Mengonstruksi dua representasi *transactional database* (*Author-Based* dan *Author-Year-Based*) serta mengevaluasi karakteristik, kelebihan, dan keterbatasannya.
4. Mengimplementasikan dan membandingkan algoritma *Apriori* dan *FP-Growth* pada berbagai ambang batas *minimum support* (`0.1%`, `0.5%`, `1%`, `2%`).
5. Membangkitkan dan menginterpretasikan *association rules* (`min_confidence = 50%`) berdasarkan metrik *support*, *confidence*, dan *lift*.
6. Menganalisis evolusi pola asosiasi antar-konferensi secara temporal pada empat periode (`2015–2017`, `2018–2020`, `2021–2023`, `2024–2025`).

// ===================== 2. DESKRIPSI DATASET =====================
= Deskripsi Dataset

== Sumber, Provenance, dan Struktur Data
Dataset diperoleh dari dump XML resmi DBLP (`https://dblp.uni-trier.de/xml/` / `https://dblp.org/xml/`) yang diunduh secara reproducible melalui `src/download.py` beserta file definisi entitas `dblp.dtd` dan verifikasi checksum SHA-256 pada `data/raw/metadata.json` (snapshot 19 November 2026; ukuran `dblp.xml.gz` ~1.070 MiB).

Berdasarkan pemindaian streaming penuh pada `src/parser.py`, file XML mentah DBLP memuat total *13.127.979* record yang tersebar ke dalam 9 jenis elemen publikasi (Tabel 1 dan Gambar 1).

#figure(
  table(
    columns: (1fr, auto, auto),
    align: (left, right, right),
    [*Tipe Elemen XML*], [*Jumlah Record*], [*Proporsi (%)*],
    [`article` (Jurnal)], [4.527.388], [34,49%],
    [`www` (Halaman Web / Profil Penulis)], [4.247.510], [32,35%],
    [*`inproceedings` (Konferensi & Workshop)*], [*4.004.309*], [*30,50%*],
    [`phdthesis`], [158.395], [1,21%],
    [`incollection`], [71.264], [0,54%],
    [`proceedings`], [65.903], [0,50%],
    [`data`], [31.529], [0,24%],
    [`book`], [21.654], [0,16%],
    [`mastersthesis`], [27], [0,00%],
    [*Total DBLP XML*], [*13.127.979*], [*100,00%*],
  ),
  caption: [Distribusi seluruh jenis publikasi pada dump XML mentah DBLP.],
)

#figure(
  image("../outputs/figures/01_xml_publication_types.png", width: 85%),
  caption: [Distribusi jenis publikasi pada raw DBLP XML dump (`<inproceedings>` disorot biru).],
)

Sesuai spesifikasi project, hanya elemen `<inproceedings>` pada rentang tahun *2015–2025* yang diekstrak (*2.004.202* record mentah) dengan lima atribut utama: `key` (identifier unik DBLP), `title` (judul makalah), `authors` (daftar nama penulis), `year` (tahun publikasi), dan `venue` (nama konferensi/workshop dari tag `<booktitle>`).

// ===================== 3. METODOLOGI =====================
= Metodologi

== Pipeline Preprocessing
Pipeline pembersihan data (`src/preprocessing.py`) dirancang secara deterministik dalam enam tahap:
1. *Seleksi Tipe & Tahun*: Ekstraksi streaming `lxml.etree.iterparse` khusus `<inproceedings>` diikuti validasi ketat `year` (`int32`, rentang `2015–2025`). Streaming dipilih agar file XML mentah (>4 GB tak terkompresi) dapat diproses dengan RAM rendah.
2. *Penanganan Missing Values*: Baris dengan `key`, `title`, `venue` kosong, atau daftar `authors` kosong dihapus karena `authors` dan `venue` adalah komponen esensial pembentuk transaksi yang tidak dapat diimputasi.
3. *Normalisasi Nama Author*: Penerapan Unicode NFC, penghapusan spasi ganda, dan deduplikasi penulis per makalah, dengan *mempertahankan* suffix numerik disambiguasi DBLP (mis. `0001`) agar peneliti homonim tidak tergabung keliru.
4. *Normalisasi Nama Venue*: Penyeragaman spasi sekitar simbol `@`, penyatuan `(Workshops)` menjadi `Workshops`, pemetaan alias historis (`NIPS` → `NeurIPS`), serta *canonical casing* berbasis bentuk penulisan paling dominan.
5. *Deduplikasi Dua Level*: Penghapusan duplikat berdasarkan `key` DBLP, lalu berdasarkan kunci konten `(normalized_title, year, venue)` untuk mengatasi duplikasi indexing lintas prosiding.

== Representasi Transactional Database
Dataset bersih ditransformasi menjadi dua basis data transaksional (`src/transactions.py`):
- *Author-Based Transaction*: setiap transaksi merepresentasikan satu author unik, berisi himpunan unik seluruh venue tempat ia memublikasikan paper selama 2015–2025.
- *Author-Year-Based Transaction*: setiap transaksi merepresentasikan pasangan `(author, year)`, berisi himpunan unik venue pada tahun tersebut.

== Frequent Pattern Mining, Association Rules, dan Strategi Skalabilitas
Pada *Author-Based Transactional Database* ($N = 1.822.489$ transaksi, $8.780$ venue), matriks *dense* boolean akan membutuhkan ~16 GiB RAM. Oleh karena itu, `src/mining.py` menerapkan *exact lossless column pruning* berdasarkan sifat *downward closure* (item dengan frekuensi $< ceil("min_support" times N)$ secara matematis tidak mungkin masuk ke frequent itemset mana pun) lalu membangun matriks sparse `scipy.sparse.csr_matrix` berdimensi $(N times K_"freq")$ dengan *mempertahankan seluruh $N$ baris* agar nilai *support* 100% eksak.

Kedua algoritma (*Apriori* dengan `low_memory=True` dan *FP-Growth*) dievaluasi pada `min_support` $in {0.1%, 0.5%, 1%, 2%}$ menggunakan `mlxtend`. Association rules dibangkitkan pada `min_confidence = 50%` dengan tiga metrik utama:
$ "Support"(A -> B) = P(A union B), quad "Confidence"(A -> B) = (P(A union B)) / P(A), quad "Lift"(A -> B) = ("Confidence"(A -> B)) / P(B) $

// ===================== 4. HASIL PREPROCESSING =====================
= Hasil Preprocessing

Proses preprocessing menghapus total *3.445* record bermasalah (*0,17%* dari data mentah), menyisakan *2.000.757* publikasi bersih, *1.822.489* author unik, dan *8.780* conference/workshop unik (Tabel 2).

#figure(
  table(
    columns: (1fr, auto),
    align: (left, right),
    [*Tahap Preprocessing*], [*Jumlah Record*],
    [Raw records (`<inproceedings>` 2015–2025)], [2.004.202],
    [Dropped: invalid year], [0],
    [Dropped: missing key/title], [0],
    [Dropped: missing/empty venue], [-190],
    [Dropped: empty authors], [-2.255],
    [Dropped: duplicate key], [0],
    [Dropped: duplicate `(title_norm, year, venue)`], [-1.000],
    [*Cleaned records*], [*2.000.757*],
    [Total author unik], [1.822.489],
    [Total conference/venue unik], [8.780],
  ),
  caption: [Ringkasan hasil preprocessing dan statistik akhir dataset bersih (2015–2025).],
)

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    image("../outputs/figures/01_publications_per_year.png", width: 100%),
    image("../outputs/figures/01_top20_venues.png", width: 100%),
  ),
  caption: [Distribusi publikasi bersih berdasarkan tahun (kiri) dan Top 20 conference/venue (kanan).],
)

Jumlah publikasi tahunan meningkat konsisten dari 161.306 (2015) hingga puncak 213.553 (2024), dengan penurunan sementara pada 2020 (172.070) akibat disrupsi pandemi COVID-19 serta sedikit penurunan pada 2025 (~199.525) karena jeda indexing sebagian prosiding akhir tahun.

// ===================== 5. CONFERENCE POPULARITY =====================
= Hasil Conference Popularity Analysis

Analisis popularitas mengukur dua dimensi komplementer: total volume publikasi dan luas partisipasi peneliti (author unik).

#figure(
  table(
    columns: (auto, 1fr, auto, auto, auto, auto, auto),
    align: (center, left, right, right, center, center, right),
    [*Rank Pub*], [*Conference*], [*Publikasi*], [*Author Unik*], [*Rank Auth*], [*Selisih*], [*Auth/Paper*],
    [1], [*NeurIPS*], [25.004], [56.073], [1], [0], [2,24],
    [2], [ICASSP], [21.125], [41.097], [3], [-1], [1,95],
    [3], [IGARSS], [19.685], [35.230], [5], [-2], [1,79],
    [4], [AAAI], [18.406], [44.604], [2], [+2], [2,42],
    [5], [CVPR], [17.435], [34.970], [6], [-1], [2,01],
    [6], [EMBC], [14.676], [39.318], [4], [+2], [2,68],
    [7], [ICML], [13.617], [31.396], [7], [0], [2,31],
    [8], [IROS], [12.832], [31.199], [8], [0], [2,43],
    [9], [ICRA], [12.361], [28.542], [11], [-2], [2,31],
    [10], [CDC], [11.666], [14.393], [35], [-25], [1,23],
  ),
  caption: [Perbandingan Top 10 konferensi berdasarkan jumlah publikasi vs peringkat author unik (2015–2025).],
)

#figure(
  image("../outputs/figures/02_top10_pub_vs_unique_authors.png", width: 96%),
  caption: [Top 10 konferensi berdasarkan jumlah publikasi (kiri) dan jumlah author unik (kanan).],
)

#figure(
  image("../outputs/figures/02_top10_conferences_trend.png", width: 88%),
  caption: [Tren pertumbuhan publikasi tahunan Top 10 konferensi selama periode 2015–2025.],
)

*Interpretasi Utama (Task 2)*:
- *Konferensi paling populer*: *NeurIPS* menempati peringkat #1 baik dari jumlah publikasi (*25.004*) maupun jumlah author unik (*56.073*).
- *Perbedaan ranking publikasi vs author unik*: Di bawah peringkat #1 terjadi pergeseran signifikan. *AAAI* (#4 publikasi) naik ke #2 author unik (44.604) dan *EMBC* (#6) naik ke #4 (39.318) karena rata-rata tim penulis per paper yang lebih besar. Sebaliknya, *CDC* (#10 publikasi, 11.666 paper) turun drastis ke peringkat #35 author unik (14.393; rasio 1,23 author unik/paper), menandakan komunitas riset kendali (*control*) yang relatif kecil namun berulang kali memublikasikan di venue yang sama.
- *Dinamika 2015–2025*: Konferensi AI/ML & Computer Vision (*NeurIPS*, *AAAI*, *CVPR*, *ICML*) mengalami pertumbuhan eksponensial sejak 2018–2025, melampaui konferensi teknik klasik seperti *ICASSP*, *IGARSS*, dan *CDC* yang cenderung stabil.

// ===================== 6. TRANSACTIONAL DB =====================
= Konstruksi Transactional Database (Task 3)

Tabel 4 merangkum karakteristik kedua representasi transaksional yang dihasilkan oleh `src/transactions.py`.

#figure(
  table(
    columns: (1.3fr, auto, auto),
    align: (left, right, right),
    [*Metrik*], [*Author-Based*], [*Author-Year-Based*],
    [Jumlah Transaksi], [1.822.489], [4.088.557],
    [Jumlah Item Unik (Venue)], [8.780], [8.780],
    [Total Kemunculan Item], [5.207.747], [6.652.015],
    [Transaksi Single-Item (`n = 1`)], [1.046.461 (57,42%)], [2.873.525 (70,28%)],
    [Transaksi Multi-Item (`n >= 2`)], [776.028 (42,58%)], [1.215.032 (29,72%)],
    [Rata-rata Item per Transaksi], [2,8575 (±5,0835)], [1,6270 (±1,4890)],
    [Median / P90 / P95 / P99 / Max], [1 / 6 / 10 / 23 / 396], [1 / 3 / 4 / 8 / 88],
  ),
  caption: [Perbandingan statistik Author-Based dan Author-Year-Based Transactional Database.],
)

#figure(
  image("../outputs/figures/03_tx_length_distribution.png", width: 96%),
  caption: [Distribusi panjang transaksi pada Author-Based vs Author-Year-Based (keseluruhan dan zoom-in multi-item).],
)

*Analisis Perbedaan, Kelebihan, dan Keterbatasan*:
- *Author-Based* menggabungkan seluruh riwayat 11 tahun per peneliti sehingga proporsi transaksi multi-item jauh lebih besar (*42,58%* vs *29,72%*). Kelebihannya adalah mampu menangkap hubungan konferensi lintas tahun (termasuk konferensi biennial seperti *ICCV* dan *ECCV* yang selalu jatuh pada tahun berbeda), namun keterbatasannya adalah hilangnya dimensi waktu.
- *Author-Year-Based* memecah riwayat ke per tahun sehingga memiliki 2,24× lebih banyak transaksi (4,09 juta) tetapi jauh lebih *sparse* (*70,28%* hanya 1 venue/tahun). Kelebihannya adalah mempertahankan informasi waktu untuk analisis temporal, namun keterbatasannya adalah support ko-okurensi jauh lebih kecil dan tidak dapat menangkap asosiasi antar-konferensi biennial.
*(Minimal 15 contoh transaksi masing-masing representasi tersimpan pada `tables/task3_sample_author_tx.csv`, `tables/task3_sample_author_year_tx.csv`, dan ditampilkan lengkap di `notebooks/02_transactional_db.ipynb`.)*

// ===================== 7. FREQUENT PATTERN MINING =====================
= Hasil Frequent Pattern Mining (Task 4)

Eksperimen pada *Author-Based Transactional Database* ($N = 1.822.489$) dijalankan dengan empat ambang batas `min_support`: `0.1%`, `0.5%`, `1%`, dan `2%`.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    align: (center, right, right, right, right, right, right),
    [*Min Support*], [*1-Itemsets*], [*2-Itemsets*], [*3-Itemsets*], [*4+-Itemsets*], [*Total Itemsets*], [*Rules (conf ≥ 50%)*],
    [0,1%], [534], [333], [237], [93], [1.197], [730],
    [0,5%], [63], [11], [1], [0], [75], [6],
    [1,0%], [24], [1], [0], [0], [25], [1],
    [2,0%], [4], [0], [0], [0], [4], [0],
  ),
  caption: [Jumlah frequent itemsets berdasarkan ukuran dan jumlah association rules pada setiap `min_support`.],
)

#figure(
  image("../outputs/figures/04_fpm_itemsets_analysis.png", width: 96%),
  caption: [Pengaruh `min_support` terhadap jumlah frequent itemsets per ukuran (kiri) dan Top 12 kombinasi 2-konferensi (kanan).],
)

*Temuan & Interpretasi Frequent Patterns*:
- *Pengaruh Minimum Support*: Kenaikan `min_support` memangkas jumlah frequent itemsets secara eksponensial akibat sifat *anti-monotone*. Pada `2%` hanya 4 konferensi raksasa yang lolos sebagai 1-itemset (*NeurIPS*, *AAAI*, *ICASSP*, *EMBC*) dan tidak ada satupun pasangan konferensi yang memenuhi syarat. Pada `1%` hanya satu pasangan konferensi yang lolos, yakni `{ICML, NeurIPS}` (*1,0008%*, 18.239 author). Pada `0,5%` muncul 11 pasangan dan 1 trio: `{ICLR, ICML, NeurIPS}` (*0,5445%*, 9.924 author).
- *Kombinasi Konferensi Terkuat (`0.1%`)*: 2-itemsets teratas didominasi oleh ekosistem Machine Learning (`{ICML, NeurIPS}` 1,00%, `{ICLR, NeurIPS}` 0,93%, `{AAAI, NeurIPS}` 0,85%), Computer Vision (`{CVPR, NeurIPS}` 0,77%, `{CVPR, ICCV}` 0,75%), Robotics (`{ICRA, IROS}` 0,65%), General AI (`{AAAI, IJCAI}` 0,60%), dan Telecommunications (`{GLOBECOM, ICC}` 0,49%). Sementara 3-itemsets teratas mencakup `{ICLR, ICML, NeurIPS}` (0,54%), `{CVPR, ICCV, NeurIPS}` (0,43%), dan `{AAAI, ICML, NeurIPS}` (0,41%).

// ===================== 8. ASSOCIATION RULE MINING =====================
= Hasil Association Rule Mining (Task 5)

Dengan `min_confidence = 50%`, dihasilkan *730* association rules pada `min_support = 0,1%`, *6* rules pada `0,5%`, *1* rule pada `1,0%` (`ICML -> NeurIPS`), dan *0* rules pada `2,0%`.

#figure(
  table(
    columns: (auto, 1.8fr, auto, auto, auto, auto),
    align: (center, left, right, right, right, right),
    [*No*], [*Association Rule*], [*Support (%)*], [*Confidence (%)*], [*Lift*], [*Author*],
    [1], [`ACM Multimedia, CVPR, NeurIPS -> AAAI, ICCV`], [0,1276], [55,33], [122,68], [2.325],
    [2], [`CVPR, IJCAI, NeurIPS -> AAAI, ICCV`], [0,1072], [55,11], [122,18], [1.953],
    [3], [`ICCV, ICML, NeurIPS -> CVPR, ICLR`], [0,1321], [56,44], [122,14], [2.407],
    [4], [`ICCV, IJCAI, NeurIPS -> AAAI, CVPR`], [0,1072], [67,72], [113,66], [1.953],
    [5], [`ACM Multimedia, ICCV, NeurIPS -> AAAI, CVPR`], [0,1276], [66,56], [111,72], [2.325],
    [6], [`ICLR, IJCAI, NeurIPS -> AAAI, ICML`], [0,1215], [56,77], [107,18], [2.214],
    [7], [`ICML, IJCAI, NeurIPS -> AAAI, ICLR`], [0,1215], [52,24], [105,20], [2.214],
    [8], [`AAAI, CVPR, ICLR -> ICCV, NeurIPS`], [0,1376], [58,72], [102,54], [2.508],
    [9], [`AAAI, CVPR, ICML -> ICCV, NeurIPS`], [0,1243], [57,02], [99,57], [2.265],
    [10], [`ICCV, IJCAI -> AAAI, CVPR`], [0,1309], [59,09], [99,18], [2.386],
  ),
  caption: [Top 10 Association Rules dengan nilai Lift tertinggi (`min_support = 0,1%`, `min_confidence = 50%`).],
)

#figure(
  image("../outputs/figures/05_association_rules_analysis.png", width: 96%),
  caption: [Sebaran Support vs Confidence dengan warna Lift (kiri) dan Top 10 Association Rules berdasarkan Lift (kanan).],
)

*Analisis & Interpretasi (Task 5)*:
1. *Apakah support tinggi selalu menghasilkan lift tinggi?* *Tidak.* Rule dengan *support* tertinggi adalah `ICML -> NeurIPS` (*1,0008%*, confidence *58,09%*), tetapi *lift*-nya hanya *18,88×* karena $P("NeurIPS")$ sebagai penyebut sangat besar (*3,08%* dari seluruh author DBLP). Sebaliknya, rule multi-venue seperti `ACM Multimedia, CVPR, NeurIPS -> AAAI, ICCV` memiliki support lebih kecil (*0,1276%*) namun *lift* mencapai *122,68×*, yang berarti peneliti dengan rekam jejak di ketiga konferensi antecedent tersebut memiliki peluang *122,7 kali lipat* lebih tinggi untuk juga memublikasikan di `{AAAI, ICCV}` dibandingkan probabilitas acak.
2. *Perbedaan Support, Confidence, dan Lift*: *Support* mengukur cakupan populasi, *Confidence* mengukur kekuatan arah implikasi bersyarat (rentan bias terhadap consequent populer), sedangkan *Lift* menormalisasi terhadap popularitas consequent sehingga membedakan asosiasi sejati dari kebetulan statistik.
3. *Pola Publikasi Antar-Konferensi*: Ditemukan klaster riset lintas-konferensi yang sangat erat antara *Vision + Multimedia + General AI* (`CVPR`, `ICCV`, `ACM Multimedia`, `AAAI`, `IJCAI`) serta poros inti *Deep Learning* (`NeurIPS`, `ICML`, `ICLR`, dengan `ICLR, ICML -> NeurIPS` mencapai confidence *80,78%*).

// ===================== 9. ALGORITHM COMPARISON =====================
= Perbandingan Performa Algoritma (Task 6)

Tabel 7 dan Gambar 7 merangkum hasil benchmark *Apriori* vs *FP-Growth* pada matriks sparse yang identik.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto),
    align: (center, right, right, center, right, right, right, right),
    [*Min Sup*], [*Itemsets (Ap/FP)*], [*Rules (Ap/FP)*], [*Identik?*], [*Apriori (s)*], [*FP-Growth (s)*], [*Apriori (MB)*], [*FP-Growth (MB)*],
    [0,1%], [1.197 / 1.197], [730 / 730], [Ya], [21,26], [77,93], [1.893,3], [952,0],
    [0,5%], [75 / 75], [6 / 6], [Ya], [1,02], [53,59], [240,3], [125,6],
    [1,0%], [25 / 25], [1 / 1], [Ya], [0,35], [57,76], [100,0], [55,4],
    [2,0%], [4 / 4], [0 / 0], [Ya], [0,05], [50,61], [30,8], [18,3],
  ),
  caption: [Perbandingan performa Apriori dan FP-Growth pada Author-Based Transactional Database ($N = 1.822.489$).],
)

#figure(
  image("../outputs/figures/06_algorithm_performance_comparison.png", width: 96%),
  caption: [Perbandingan waktu eksekusi (kiri) dan peak traced memory (kanan) antara Apriori dan FP-Growth.],
)

*Evaluasi Performa (Task 6)*:
1. *Pengaruh `min_support`*: Penurunan `min_support` dari `2%` ke `0,1%` menyebabkan lonjakan waktu Apriori sebesar >400× (`0,05s` → `21,26s`) dan lonjakan memori >61× (`30,8 MB` → `1.893,3 MB`) karena bertambahnya pembangkitan kandidat. Pada FP-Growth, waktu eksekusi relatif stabil (`50,61s` → `77,93s`) dan memorinya selalu *~50% lebih hemat*.
2. *Kesamaan Hasil*: Kedua algoritma menghasilkan himpunan frequent itemsets dan association rules yang *100% identik* di seluruh threshold (`itemsets_identical = True`, galat support $< 10^(-12)$).
3. *Algoritma Paling Sesuai*: Terdapat trade-off implementasi yang menarik. Secara *efisiensi memori dan skalabilitas teoritis* pada threshold rendah (`<= 0,1%`), *FP-Growth* lebih sesuai untuk DBLP karena menghindari *candidate generation* dan hanya membutuhkan setengah RAM Apriori (`952 MB` vs `1.893 MB`). Namun, secara *kecepatan eksekusi praktis* di pustaka Python `mlxtend` pada `min_support` `0,1%–2%`, *Apriori (`low_memory=True` pada matriks sparse)* lebih cepat karena memanfaatkan vektorisasi SciPy/NumPy, sedangkan `mlxtend.fpgrowth` mengalami *fixed overhead* ~50 detik saat membangun FP-Tree baris demi baris di pure Python atas 1,82 juta transaksi.

// ===================== 10. TEMPORAL ANALYSIS =====================
= Temporal Association Analysis (Bagian E)

Analisis temporal dilakukan pada *Author-Year-Based Transactional Database* (4.088.557 transaksi) yang dibagi menjadi empat periode waktu. Karena transaksi tahunan jauh lebih *sparse*, analisis dijalankan pada baseline `0,10%` dan sensitivitas `0,05%` (`min_confidence = 50%`).

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    align: (center, right, right, right, right, right, right),
    [*Periode*], [*Transaksi*], [*Multi-Item (%)*], [*Itemsets (0,1%)*], [*Rules (0,1%)*], [*Itemsets (0,05%)*], [*Rules (0,05%)*],
    [2015–2017], [922.999], [29,99%], [302], [1], [799], [1],
    [2018–2020], [1.081.611], [28,98%], [279], [0], [763], [0],
    [2021–2023], [1.196.891], [28,79%], [306], [2], [792], [15],
    [2024–2025], [887.056], [31,58%], [420], [37], [1.065], [212],
  ),
  caption: [Statistik frequent itemsets dan association rules per periode pada Author-Year-Based Database.],
)

#figure(
  image("../outputs/figures/07_temporal_counts.png", width: 96%),
  caption: [Perbandingan jumlah frequent itemsets (kiri) dan association rules (kanan) antarperiode.],
)

#figure(
  image("../outputs/figures/08_temporal_rules_heatmap.png", width: 92%),
  caption: [Evolusi nilai Lift Top 15 Association Rules melintasi empat periode (`min_support = 0,05%`, `conf >= 50%`).],
)

*Analisis Evolusi Pola Antarperiode*:
- *Pola Declining / Historis (2015–2017)*: Satu-satunya rule yang lolos `conf >= 50%` pada 2015–2017 adalah `ECOC -> OFC` (komunikasi optik; *lift 59,83×*, *conf 51,59%*). Memasuki 2018–2020, tidak ada satupun rule tahunan yang melewati `conf >= 50%`.
- *Pola Bertahan/Stabil di Era Modern (2021–2025)*: Dua belas rule inti AI/ML, Vision, dan NLP bertahan kuat sepanjang 2021–2023 hingga 2024–2025, antara lain `ACL (1), EMNLP (Findings) -> EMNLP` (lift 84,69× → 32,44×), `ICCV, NeurIPS -> CVPR` (30,58× → 19,86×), `ICCV, ICLR -> CVPR` (32,10× → 20,42×), dan `ICLR, ICML -> NeurIPS` (24,37× → 12,12×). Penurunan angka *lift* di 2024–2025 meski *support* meningkat menandakan konferensi tujuan (`NeurIPS`, `CVPR`, `EMNLP`) semakin menjadi *mainstream* dengan basis partisipan jauh lebih luas.
- *Ledakan Emerging Patterns (2024–2025)*: Jumlah rules melonjak drastis dari 2 → *37* (pada `0,1%`) dan dari 15 → *212* (pada `0,05%`), didorong oleh booming riset *Large Language Models* dan *Multimodal AI* (keterkaitan kuat antar-track `ACL (1)`, `ACL (Findings)`, `EMNLP`, `EMNLP (Findings)`, `ICLR`, `NeurIPS`, `CVPR`, dan `AAAI`).

// ===================== 11. KETERBATASAN & ASUMSI =====================
= Keterbatasan Dataset dan Asumsi Analisis

1. *Cakupan & Jeda Indexing DBLP*: DBLP berfokus pada Ilmu Komputer; data tahun 2025 dapat sedikit lebih rendah dari 2024 karena keterlambatan indexing prosiding akhir tahun 2025.
2. *Granularitas Nama Venue*: Meskipun normalisasi alias (`NIPS` → `NeurIPS`), spasi `@`, dan *canonical casing* telah diterapkan, beberapa konferensi seperti ACL/EMNLP di DBLP memisahkan *main track* (`ACL (1)`) dan *Findings* (`ACL (Findings)`). Pemisahan ini dipertahankan karena mencerminkan struktur prosiding resmi DBLP, namun turut memunculkan rule intra-komunitas NLP yang sangat kuat pada 2021–2025.
3. *Disambiguasi Author*: Suffix numerik DBLP (`0001`) dipertahankan dengan asumsi disambiguasi DBLP akurat; potensi kecil pemecahan/penggabungan profil author masih mungkin terjadi pada nama-nama sangat umum.
4. *Popularitas Berbasis Aktivitas*: Popularitas diukur murni dari volume publikasi dan jumlah author unik, bukan dari *acceptance rate*, sitasi, atau peringkat prestise (seperti CORE/h5-index).

// ===================== 12. KESIMPULAN (BAGIAN H) =====================
= Kesimpulan dan Jawaban Pertanyaan Kesimpulan

Berdasarkan seluruh hasil eksperimen yang telah diverifikasi pada dataset DBLP 2015–2025, berikut jawaban eksplisit atas tujuh pertanyaan kesimpulan:

1. *Konferensi dengan popularitas publikasi tertinggi*: *NeurIPS* menempati peringkat #1 baik dari jumlah publikasi (*25.004* paper) maupun jumlah author unik (*56.073* author), disusul *ICASSP* (21.125 paper) dan *IGARSS* (19.685 paper) dari sisi publikasi, serta *AAAI* (44.604) dan *ICASSP* (41.097) dari sisi author unik.
2. *Apakah konferensi paling populer juga memiliki asosiasi paling kuat (lift tertinggi)?* *Tidak selalu.* *NeurIPS* memang muncul dalam rule ber-*support* tertinggi (`ICML -> NeurIPS`, support 1,0008%, conf 58,09%), namun *lift*-nya moderat (*18,88×*) karena basis partisipan NeurIPS sangat besar. *Lift* tertinggi justru dicapai oleh kombinasi spesifik lintas-konferensi seperti `ACM Multimedia, CVPR, NeurIPS -> AAAI, ICCV` (*lift 122,68×*).
3. *Kombinasi konferensi yang paling sering muncul bersama*: Untuk 2-konferensi adalah `{ICML, NeurIPS}` (18.239 author; support 1,0008%), diikuti `{ICLR, NeurIPS}` (16.882; 0,9263%), `{AAAI, NeurIPS}` (15.554; 0,8534%), `{CVPR, NeurIPS}` (14.006; 0,7685%), dan `{CVPR, ICCV}` (13.588; 0,7456%). Untuk 3-konferensi adalah `{ICLR, ICML, NeurIPS}` (9.924 author; 0,5445%).
4. *Association rule dengan lift tertinggi dan maknanya*: `ACM Multimedia, CVPR, NeurIPS -> AAAI, ICCV` (*support = 0,1276%*, *confidence = 55,33%*, *lift = 122,68×*, 2.325 author). Maknanya: peneliti yang telah memublikasikan di `ACM Multimedia`, `CVPR`, dan `NeurIPS` memiliki kecenderungan 122,68 kali lebih besar dibandingkan rata-rata populasi untuk juga aktif memublikasikan di `AAAI` dan `ICCV`—mencerminkan klaster peneliti *Multimodal AI & Computer Vision* yang sangat kohesif.
5. *Perbedaan pola Author-Based vs Author-Year-Based*: *Ya, sangat signifikan.* *Author-Based* menghasilkan pola jauh lebih banyak (1.197 itemsets, 730 rules pada 0,1%) dan menangkap asosiasi lintas-tahun (termasuk konferensi biennial seperti CVPR–ICCV), sedangkan *Author-Year-Based* lebih *sparse* (70,28% transaksi 1-item) sehingga hanya meloloskan ko-publikasi intensif di tahun yang sama, namun berhasil mengungkap lonjakan historis multi-konferensi AI/NLP di 2021–2025.
6. *Algoritma dengan performa terbaik*: Keduanya menghasilkan output *100% identik*. *FP-Growth* terbaik dari sisi *efisiensi memori dan skalabilitas* (memangkas *peak memory* ~50%: 952 MB vs 1.893 MB pada 0,1%), sementara pada implementasi Python `mlxtend` di `min_support` `0,1%–2%`, *Apriori (`low_memory=True` sparse)* unggul pada *waktu eksekusi* (21,26s vs 77,93s) karena vektorisasi SciPy/NumPy.
7. *Insight utama*: Lanskap riset Ilmu Komputer 2015–2025 mengalami pergeseran struktural besar menuju ekosistem *AI, Machine Learning, Computer Vision, dan NLP*, ditandai dengan dominasi *NeurIPS/AAAI/CVPR/ICML*, terbentuknya klaster publikasi lintas-konferensi yang erat, serta lonjakan >14× jumlah association rules tahunan dari 2021–2023 ke 2024–2025.

// ===================== 13. REFERENSI =====================
= Referensi

1. Ley, M. (2009). *DBLP — Some Lessons Learned*. Proceedings of the VLDB Endowment, 2(2), 1493–1500. Dataset XML: `https://dblp.org/xml/`.
2. Agrawal, R., & Srikant, R. (1994). *Fast Algorithms for Mining Association Rules in Large Databases*. Proceedings of the 20th International Conference on Very Large Data Bases (VLDB), 487–499.
3. Han, J., Pei, J., & Yin, Y. (2000). *Mining Frequent Patterns without Candidate Generation*. ACM SIGMOD Record, 29(2), 1–12.
4. Raschka, S. (2018). *MLxtend: Providing machine learning and data science utilities and extensions to Python's scientific computing stack*. Journal of Open Source Software, 3(24), 638.
