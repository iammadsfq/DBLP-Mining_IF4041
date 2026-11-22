#import "@preview/jilid:0.2.0": (
  appendix, frontmatter, jilid, signature, signatures,
)

#show: jilid.with(
  title: [Conference Popularity and Association Pattern Mining Using DBLP Dataset],
  subtitle: [Analisis Aktivitas Publikasi Konferensi, Frequent Pattern Mining (Apriori & FP-Growth), Association Rule Mining, dan Analisis Asosiasi Temporal Periode 2015–2025],
  kind: [Laporan Project Data Mining],
  course: "IF4041 — Penambangan Data",
  lecturers: (name: "Nama Dosen Pengampu", id: "10000000000000000"),
  students: (
    (name: "Nama Anggota 1", id: "1000000001"),
    (name: "Nama Anggota 2", id: "1000000002"),
    (name: "Nama Anggota 3", id: "1000000003"),
  ),
  program: "Teknik Informatika",
  faculty: "Fakultas Teknik / Informatika",
  university: "Nama Universitas",
  year: "2026",
  bibliography: bibliography("refs.bib", style: "apa"),
  cover: (
    kind-pos: "top",
    title: (size: 17pt, weight: "bold", upper: true),
    subtitle: (size: 11.5pt, weight: "medium", upper: false),
  ),
  typography: (
    font-size: 11pt,
    table-size: 8.8pt,
    caption-size: 9.5pt,
  ),
  footer: (
    left: [IF4041 — Project DBLP Mining (2015–2025)],
  ),
)

// Cegah heading yatim di akhir halaman
#show heading: set block(sticky: true)

// Styling tabel kotak hitam biasa
#set table(
  stroke: 0.6pt + black,
  fill: none,
  inset: (x: 5pt, y: 4.5pt),
)

// =========================================================================
// HALAMAN DEPAN (FRONT MATTER)
// =========================================================================

#frontmatter(title: [Lembar Pengesahan])[
  #v(0.8cm)
  #signatures(
    header: [Kota, 22 November 2026 \ Mengetahui,],
    signature(
      role: [Dosen Pengampu],
      name: "Nama Dosen Pengampu",
      id: "10000000000000000",
    ),
    signature(
      role: [Perwakilan Kelompok],
      name: "Nama Anggota 1",
      id-label: "NIM",
      id: "1000000001",
    ),
  )
]

#frontmatter(title: [Abstrak], label: <abstrak>)[
  Publikasi konferensi dan workshop memegang peranan sentral dalam diseminasi riset Ilmu Komputer. Penelitian ini menganalisis popularitas konferensi serta pola asosiasi antar-konferensi menggunakan dataset bibliografi resmi *DBLP (Digital Bibliography & Library Project)* pada periode publikasi *2015–2025*. Dari total *13.127.979* entri pada berkas XML mentah DBLP, diekstrak *2.004.202* record bertipe `<inproceedings>` pada rentang tahun 2015–2025, yang setelah melalui proses _preprocessing_ sistematis menghasilkan *2.000.757* publikasi bersih, *1.822.489* _author_ unik, dan *8.780* _conference/venue_ unik. Analisis popularitas menunjukkan bahwa *NeurIPS* menempati peringkat pertama baik berdasarkan jumlah publikasi (*25.004* makalah) maupun jumlah _author_ unik (*56.073* peneliti), sedangkan konferensi dengan komunitas terspesialisasi seperti *CDC* mengalami pergeseran tajam dari peringkat \#10 publikasi ke \#35 _author_ unik. Selanjutnya dibentuk dua representasi _transactional database_, yakni *Author-Based* (*1.822.489* transaksi; *42,58%* multi-item) dan *Author-Year-Based* (*4.088.557* transaksi; *29,72%* multi-item). Implementasi algoritma *Apriori* dan *FP-Growth* pada *Author-Based Database* pada nilai *minimum support* `0,1%`, `0,5%`, `1%`, dan `2%` menghasilkan himpunan _frequent itemsets_ yang *100% identik* (berturut-turut 1.197, 75, 25, dan 4 itemsets), dengan *FP-Growth* menghemat penggunaan memori puncak hingga \~50% (`952,0 MB` vs `1.893,3 MB` pada `0,1%`). Pada `min_confidence = 50%`, ditemukan *730* _association rules_ pada `min_support = 0,1%` dengan nilai _lift_ tertinggi *122,68×* pada aturan `ACM Multimedia, CVPR, NeurIPS -> AAAI, ICCV`. Terakhir, analisis temporal pada empat periode (`2015–2017`, `2018–2020`, `2021–2023`, `2024–2025`) menggunakan *Author-Year-Based Database* mengungkapkan pergeseran lanskap riset dari dominasi komunikasi optik pada 2015–2017 (`ECOC -> OFC`) menuju lonjakan pesat ko-publikasi lintas-konferensi AI, _Computer Vision_, dan *NLP* pada 2021–2025.

  *Kata kunci:* DBLP, _Frequent Pattern Mining_, _Association Rule Mining_, Apriori, FP-Growth, Analisis Temporal
]

#frontmatter(title: [Kata Pengantar])[
  Puji dan syukur penulis panjatkan ke hadirat Tuhan Yang Maha Esa karena atas rahmat dan karunia-Nya, laporan project mata kuliah Penambangan Data berjudul _"Conference Popularity and Association Pattern Mining Using DBLP Dataset"_ ini dapat diselesaikan dengan baik.

  Laporan ini disusun untuk mendokumentasikan secara menyeluruh seluruh tahapan pengerjaan project mulai dari pemahaman dan _preprocessing_ data bibliografi DBLP, analisis popularitas konferensi, konstruksi _transactional database_, implementasi serta evaluasi performa algoritma Apriori dan FP-Growth, pembangkitan _association rules_, hingga analisis asosiasi temporal pada periode 2015–2025.

  Penulis mengucapkan terima kasih kepada dosen pengampu mata kuliah Penambangan Data atas arahan dan spesifikasi project yang terstruktur, serta kepada seluruh anggota kelompok atas kerja sama dalam perancangan, eksperimen, validasi kode, dan penyusunan laporan. Penulis menyadari bahwa laporan ini masih memiliki keterbatasan sebagaimana didokumentasikan pada bagian akhir analisis; oleh karena itu, kritik dan saran yang membangun sangat diharapkan.

  #align(right)[Kota, 22 November 2026 \ Tim Penyusun]
]

// =========================================================================
// BAB I — PENDAHULUAN
// =========================================================================
= Pendahuluan <bab-pendahuluan>

== Latar Belakang
Dalam disiplin ilmu _Computer Science_, konferensi dan *workshop* ilmiah berperan sebagai jalur diseminasi riset utama yang bergerak cepat dibandingkan jurnal konvensional. *DBLP (Digital Bibliography & Library Project)* menghimpun jutaan metadata publikasi ilmiah di bidang Ilmu Komputer, mencakup judul makalah, daftar penulis, tahun terbit, serta _venue_ publikasi @ley2009dblp. Seiring pesatnya perkembangan sub-bidang seperti _Machine Learning_, _Computer Vision_, _Natural Language Processing_, robotika, dan sistem komunikasi, muncul kebutuhan untuk memahami konferensi mana yang memiliki aktivitas publikasi paling tinggi serta bagaimana keterkaitan antar-konferensi terbentuk melalui riwayat publikasi para peneliti.

Ringkasan eksekutif penelitian ini tersaji pada @abstrak. Dengan menerapkan teknik _Frequent Pattern Mining_ (FPM) dan _Association Rule Mining_ (ARM) menggunakan algoritma *Apriori* @agrawal1994fast dan *FP-Growth* @han2000mining pada dataset DBLP periode *2015–2025*, kita dapat mengekstrak pola ko-publikasi antar-konferensi secara kuantitatif, membandingkan efisiensi kedua algoritma pada basis data berskala jutaan transaksi, serta mengamati bagaimana ekosistem riset Ilmu Komputer berevolusi dari waktu ke waktu.

== Rumusan Masalah
Berdasarkan spesifikasi project, permasalahan utama yang dijawab dalam penelitian ini meliputi:
+ Bagaimana karakteristik dataset mentah DBLP dan bagaimana tahapan _preprocessing_ yang tepat untuk menghasilkan data konferensi/workshop bersih pada periode 2015–2025?
+ Konferensi apa saja yang paling populer berdasarkan aktivitas publikasi dan jumlah _author_ unik, serta bagaimana tren dan perbandingan kedua peringkat tersebut selama 2015–2025?
+ Bagaimana perbedaan konstruksi, distribusi panjang transaksi, kelebihan, dan keterbatasan antara representasi *Author-Based* dan *Author-Year-Based Transactional Database*?
+ Pola kombinasi konferensi (_frequent itemsets_) dan aturan asosiasi (_association rules_) apa saja yang ditemukan oleh algoritma Apriori dan FP-Growth pada berbagai nilai *minimum support* (`0,1%`, `0,5%`, `1%`, `2%`) dan `min_confidence = 50%`?
+ Bagaimana perbandingan performa serta kesamaan hasil algoritma Apriori dan FP-Growth pada dataset DBLP berskala besar?
+ Bagaimana dinamika evolusi _frequent itemsets_ dan _association rules_ antarperiode waktu (`2015–2017`, `2018–2020`, `2021–2023`, `2024–2025`)?

== Tujuan Project
Tujuan project ini mengacu langsung pada capaian pembelajaran yang ditetapkan:
+ Memahami dan melakukan _preprocessing_ terhadap dataset bibliografi DBLP.
+ Mengubah data bibliografi bersih menjadi dua bentuk _transactional database_.
+ Mengimplementasikan algoritma Apriori dan FP-Growth secara *reproducible*.
+ Menemukan _frequent itemsets_ pada berbagai ambang batas *minimum support*.
+ Menghasilkan dan menganalisis _association rules_ menggunakan metrik _support_, _confidence_, dan _lift_.
+ Mengevaluasi performa algoritma _Frequent Pattern Mining_ (Apriori vs FP-Growth).
+ Menginterpretasikan hasil *mining* menjadi pengetahuan dan wawasan yang bermakna.

== Keterbatasan dan Asumsi Awal
Untuk menjaga objektivitas interpretasi, ditetapkan asumsi dan ruang lingkup berikut: (a) dataset mencakup seluruh bidang _Computer Science_ yang terindeks pada DBLP untuk tipe `<inproceedings>` tahun 2015–2025; (b) popularitas konferensi diukur secara ketat berdasarkan *aktivitas publikasi* (jumlah makalah dan jumlah _author_ unik), bukan metrik sitasi, _acceptance rate_, atau pemeringkatan eksternal seperti CORE; dan (c) data tahun 2025 merefleksikan _snapshot_ indeks DBLP hingga tanggal pengambilan 19 November 2026 sehingga prosiding akhir tahun yang belum terindeks dapat memengaruhi angka 2025.

// =========================================================================
// BAB II — TINJAUAN PUSTAKA & DESKRIPSI DATASET
// =========================================================================
= Tinjauan Pustaka dan Deskripsi Dataset <bab-dataset>

== Landasan Teori Frequent Pattern & Association Rule Mining
Misalkan $cal(I) = {i_1, i_2, dots, i_m}$ adalah himpunan seluruh _item_ unik (_conference/venue_) dan $cal(D) = {T_1, T_2, dots, T_N}$ adalah basis data transaksi berukuran $N$, dengan setiap transaksi $T subset.eq cal(I)$. Untuk suatu _itemset_ $X subset.eq cal(I)$ dan aturan implikasi $A arrow B$ (dengan $A, B subset.eq cal(I)$ dan $A inter B = emptyset$), tiga metrik evaluasi utama didefinisikan sebagai berikut:

$ "Support"(X) = (|{T in cal(D) mid X subset.eq T}|) / N $ <eq-support>

$ "Confidence"(A arrow B) = ("Support"(A union B)) / ("Support"(A)) = P(B mid A) $ <eq-confidence>

$ "Lift"(A arrow B) = ("Confidence"(A arrow B)) / ("Support"(B)) = ("Support"(A union B)) / ("Support"(A) times "Support"(B)) $ <eq-lift>

Sebagaimana dirumuskan pada @eq-support, _support_ mengukur proporsi transaksi dalam basis data yang memuat itemset $X$. Pada @eq-confidence, _confidence_ mengukur probabilitas bersyarat munculnya $B$ apabila $A$ telah muncul, sedangkan @eq-lift mendefinisikan _lift_ untuk mengukur seberapa besar peluang munculnya $B$ meningkat dengan kehadiran $A$ dibandingkan peluang dasar $B$ secara independen. Nilai $"Lift" > 1$ menandakan korelasi positif, $"Lift" = 1$ menandakan independensi statistik, dan $"Lift" < 1$ menandakan korelasi negatif.

Algoritma *Apriori* @agrawal1994fast bekerja secara _level-wise_ dengan prinsip _anti-monotone_ (_downward closure_): setiap himpunan bagian dari _frequent itemset_ pasti juga *frequent*. Apriori membangkitkan kandidat $C_k$ dari $L_(k-1)$ lalu memindai basis data pada setiap iterasi $k$. Sebaliknya, *FP-Growth* @han2000mining mengompresi basis data transaksi ke dalam struktur pohon prefiks *FP-Tree* hanya dalam dua kali pemindaian basis data, lalu menambang _frequent itemsets_ secara rekursif melalui _conditional pattern base_ tanpa membangkitkan kandidat secara eksplisit.

== Ketentuan dan Provenance Dataset DBLP
Seluruh eksperimen menggunakan data resmi DBLP XML Dump @dblp2026xml sesuai ketentuan project:
- *Sumber Resmi*: `https://dblp.org/xml/` (diunduh melalui mirror resmi `https://dblp.uni-trier.de/xml/` dengan skrip otomatis `src/download.py`).
- *Tanggal Pengambilan (Snapshot)*: *19 November 2026*, pukul `03:06:47 UTC` (`10:06:47 WIB`), dengan _header_ `Last-Modified` server DBLP `Thu, 19 Nov 2026 02:13:25 GMT`.
- *Berkas Mentah & Integritas (tercatat di `data/raw/metadata.json`)*:
  - `dblp.dtd`: `13.134` _bytes_ (`sha256: 03ec35cb34a4227572a0e89da407b06b6e44a6cc23e19cabc3b49b702a5f897d`).
  - `dblp.xml.gz`: `1.121.975.282` _bytes_ (\~1.070,0 MiB / \~1,04 GiB, `sha256: 812fd7d6860295a902fbc01a96c55306d1df05038560055f269148a49646685f`).
- *Cakupan*: Publikasi dari seluruh bidang Ilmu Komputer pada periode *2015–2025*, difokuskan pada tipe publikasi konferensi dan *workshop* (`<inproceedings>`).
- *Atribut yang Digunakan*: `key` (identifier unik DBLP), `title` (judul makalah), `authors` (daftar seluruh penulis), `year` (tahun publikasi), dan `venue` (nama konferensi/workshop dari elemen XML `<booktitle>`).

== Eksplorasi Struktur, Jumlah Record, dan Jenis Publikasi (Task 1.1)
Berkas XML DBLP menggunakan skema DTD (`dblp.dtd`) yang menyimpan berbagai entitas karakter HTML/LaTeX dan sembilan tipe elemen publikasi utama. Pemindaian _streaming_ penuh oleh `src/parser.py` mencatat sebanyak *13.127.979* record publikasi mentah di seluruh riwayat DBLP, dengan rincian distribusi pada @tabel-xml-types dan @gambar-xml-types.

#figure(
  table(
    columns: (auto, 1.4fr, auto, auto),
    align: (center, left, right, right),
    [*No*], [*Tipe Elemen XML*], [*Jumlah Record*], [*Proporsi (%)*],
    [1], [`article` (Artikel Jurnal)], [4.527.388], [34,49%],
    [2], [`www` (Halaman Web / Profil Penulis)], [4.247.510], [32,35%],
    [3], [*`inproceedings` (Konferensi & Workshop)*], [*4.004.309*], [*30,50%*],
    [4], [`phdthesis` (Disertasi Doktoral)], [158.395], [1,21%],
    [5], [`incollection` (Bab Buku)], [71.264], [0,54%],
    [6], [`proceedings` (Volume Prosiding)], [65.903], [0,50%],
    [7], [`data` (Dataset Riset)], [31.529], [0,24%],
    [8], [`book` (Buku)], [21.654], [0,16%],
    [9], [`mastersthesis` (Tesis Magister)], [27], [0,00%],
    [], [*Total Seluruh Record DBLP XML*], [*13.127.979*], [*100,00%*],
  ),
  caption: [Distribusi seluruh jenis publikasi pada berkas XML mentah DBLP (`data/processed/xml_publication_types.json`).],
) <tabel-xml-types>

#figure(
  image("../outputs/figures/01_xml_publication_types.png", width: 88%),
  caption: [Distribusi seluruh jenis publikasi pada raw DBLP XML dump (`<inproceedings>` disorot biru).],
) <gambar-xml-types>

Dari *4.004.309* entri `<inproceedings>` lintas tahun, penyaringan rentang publikasi *2015–2025* menghasilkan *2.004.202* record mentah (\~50,05% dari seluruh publikasi konferensi/workshop sepanjang sejarah DBLP) yang disimpan pada `data/processed/dblp_2015_2025_raw.parquet`. Inspeksi kualitas data awal pada dataset mentah ini menemukan *190* baris dengan `venue` kosong (`null`), *2.255* baris dengan daftar `authors` kosong (`[]`), serta sejumlah indikasi duplikasi judul pada tahun dan _venue_ yang sama.

// =========================================================================
// BAB III — METODOLOGI
// =========================================================================
= Metodologi <bab-metodologi>

== Alur Kerja Pipeline End-to-End
Seluruh proses dari akuisisi data mentah hingga evaluasi temporal dirancang secara modular dan deterministik agar 100% dapat direproduksi. Alur kerja pipeline ditunjukkan pada @gambar-alur-pipeline.

#figure(
  {
    import "@preview/fletcher:0.5.8": diagram, edge, node
    diagram(
      node-stroke: 0.7pt + black,
      node-fill: none,
      node-corner-radius: 0pt,
      edge-stroke: 0.7pt + black,
      spacing: (1.4em, 1.4em),
      node((0, 0), [`src/download.py`\ Unduh XML & DTD]),
      edge("-|>"),
      node((1, 0), [`src/parser.py`\ Ekstrak `<inproceedings>`]),
      edge("-|>"),
      node((2, 0), [`src/preprocessing.py`\ Bersihkan & Normalisasi]),
      edge((2, 0), (2, 1), "-|>"),
      node((2, 1), [`src/transactions.py`\ 2 Representasi DB]),
      edge((2, 1), (1, 1), "-|>"),
      node((1, 1), [`src/mining.py`\ Apriori, FP-Growth & ARM]),
      edge((2, 1), (2, 2), "-|>"),
      node((2, 2), [`src/temporal.py`\ Analisis Temporal 4 Periode]),
      edge((1, 1), (0, 1), "-|>"),
      node((0, 1), [Evaluasi & Visualisasi\ (Notebook 01–04)]),
    )
  },
  caption: [Diagram alur pipeline end-to-end project DBLP-Mining.],
) <gambar-alur-pipeline>

== Tahapan Preprocessing dan Alasan Pemilihan Metode (Task 1.2 & 1.3)
Tahapan pembersihan pada `src/preprocessing.py` memenuhi keenam ketentuan Task 1.2 dengan rasionalisasi teknis pada tiap langkah:

+ *Pemilihan Publikasi Konferensi dan Workshop (`<inproceedings>`)*:
  - *Metode*: Menggunakan `lxml.etree.iterparse` dengan `load_dtd=True`, `resolve_entities=True`, dan `huge_tree=True` khusus menyaring elemen `<inproceedings>` serta membuang elemen DOM setelah diproses (`elem.clear()`).
  - *Alasan*: Berkas XML tak terkompresi berukuran >4 GiB sehingga pemuatan DOM penuh akan menghabiskan memori. *Streaming parser* menjaga penggunaan memori konstan dan memastikan entitas karakter khusus DBLP (seperti umlaut dan aksen nama penulis) ter-dekode sempurna. Pada data bersih, 99,84% (`1.997.597`) ber-prefix `conf/`, sedangkan sisanya (`3.120` `journals/` dan `40` `books/`) adalah prosiding konferensi yang diterbitkan dalam seri jurnal/buku (mis. *PVLDB*, *PACMPL*, *LNCS*) sehingga tetap valid sebagai `<inproceedings>`.
+ *Konsistensi Atribut Tahun Publikasi*:
  - *Metode*: Konversi eksplisit kolom `year` ke numerik (`pd.to_numeric(..., errors="coerce")`), pemfilteran rentang inklusif `2015–2025`, dan konversi tipe ke `int32`.
  - *Alasan*: Menjamin tidak ada tahun di luar cakupan 11 tahun pengamatan, nilai tidak valid/non-numerik, atau inkonsistensi tipe sebelum pengelompokan tahunan dan pembagian periode temporal.
+ *Penanganan Missing Values*:
  - *Metode*: Penghapusan baris (_listwise deletion_) apabila `key` kosong, `title` kosong, `venue` kosong, atau panjang daftar `authors` sama dengan nol.
  - *Alasan*: Dalam konstruksi transaksi `author -> {venues}`, atribut `authors` dan `venue` berperan sebagai entitas dan item transaksi. Nilai kosong pada kedua atribut tersebut tidak mungkin diimputasi secara statistik tanpa menciptakan bias atau asosiasi fiktif, dan proporsinya sangat kecil (kurang dari 0,13% dari 2 juta record).
+ *Normalisasi Nama Author*:
  - *Metode*: Normalisasi Unicode bentuk *NFC* (`unicodedata.normalize("NFC", ...)`), pelipatan spasi ganda/berlebih (`\s+ -> " "`), pemangkasan spasi tepi, deduplikasi penulis dalam makalah yang sama (_order-preserving_), serta *mempertahankan* angka disambiguasi DBLP (contoh: `Donghyun Lee 0001`).
  - *Alasan*: Unicode NFC menyatukan representasi karakter beraksen yang identik secara visual namun berbeda urutan byte. Sebaliknya, suffix numerik `0001`, `0002`, dst. *sengaja dipertahankan* karena merupakan mekanisme resmi DBLP untuk membedakan peneliti berbeda yang kebetulan memiliki nama sama (homonim)—menghapusnya akan menggabungkan riwayat publikasi banyak orang menjadi satu transaksi artifisial.
+ *Normalisasi Nama Conference/Venue*:
  - *Metode*: Normalisasi Unicode NFC & spasi, penyeragaman spasi di sekitar simbol `@` (mis. `EMPIRE @ RecSys` $arrow$ `EMPIRE@RecSys`), penyatuan variasi tanda kurung `(Workshops)` menjadi `Workshops`, pemetaan alias historis penggantian nama konferensi (`nips` $arrow$ `NeurIPS`), serta _canonical case folding_ dengan memilih bentuk kapitalisasi yang paling sering muncul di korpus.
  - *Alasan*: Konferensi besar seperti *NeurIPS* resmi berganti nama dari *NIPS* pada tahun 2018; tanpa pemetaan alias, riwayat publikasi sebelum dan sesudah 2018 akan terpecah menjadi dua item terpisah. Begitu pula perbedaan spasi atau kapitalisasi minor perlu disatukan agar nilai _support_ dihitung secara akurat.
+ *Penghilangan Data Duplikat (Deduplikasi Dua Level)*:
  - *Metode*: Deduplikasi tahap pertama pada `key` unik DBLP (`keep="first"`), diikuti deduplikasi konten berdasarkan tupel `(normalized_title, year, venue)` setelah tanda baca judul dihilangkan dan diubah menjadi huruf kecil.
  - *Alasan*: Satu makalah yang sama terkadang muncul dua kali akibat perbedaan *key* lintas prosiding atau sedikit variasi tanda baca pada judul di tahun dan _venue_ yang sama. Deduplikasi dua tingkat memastikan setiap makalah hanya dihitung satu kali dalam transaksi _author_.

== Metodologi Konstruksi Transactional Database (Task 3)
Dataset bersih `dblp_2015_2025_clean.parquet` diolah oleh `src/transactions.py` menjadi dua format keranjang transaksi (_market-basket_):
+ *Author-Based Transactional Database*: Setiap baris makalah di-_explode_ menurut daftar `authors`, dideduplikasi pada pasangan `(author, venue)`, lalu diagregasi per `author` menjadi daftar unik _venue_ terurut secara leksikografis. Satu transaksi merepresentasikan seluruh _venue_ publikasi seorang peneliti sepanjang 2015–2025.
+ *Author-Year-Based Transactional Database*: Prosedur serupa namun deduplikasi dilakukan pada tripel `(author, year, venue)` dan diagregasi per `(author, year)`. Satu transaksi merepresentasikan seluruh _venue_ tempat seorang peneliti menerbitkan makalah pada satu tahun tertentu.

Kedua basis data disimpan dalam format Apache Parquet (`tx_author_based.parquet` dan `tx_author_year_based.parquet`) beserta statistik deskriptif (`min`, `median`, `mean`, `std`, `p90`, `p95`, `p99`, `max`), distribusi panjang transaksi (`1` hingga `>10`), dan masing-masing 15 sampel transaksi untuk audit kualitatif.

== Metodologi Frequent Pattern Mining, Association Rules & Benchmarking (Task 4, 5, 6)
Eksperimen FPM dijalankan pada *Author-Based Transactional Database* ($N = 1.822.489$ transaksi, $8.780$ _item_ unik) dengan empat ambang batas *minimum support*: `0,1%` ($0,001$), `0,5%` ($0,005$), `1%` ($0,01$), dan `2%` ($0,02$).

Mengingat matriks _dense boolean_ berukuran $1.822.489 times 8.780$ akan membutuhkan sekitar 16 GiB RAM, `src/mining.py` menerapkan strategi _exact lossless column pruning_:
- Hanya kolom/_venue_ dengan frekuensi kemunculan $gt.eq ceil("min_support" times N)$ yang dipertahankan sebagai fitur (sesuai prinsip _downward closure_, item di bawah `min_support` secara matematis mustahil menjadi anggota _frequent itemset_ mana pun).
- Seluruh $N = 1.822.489$ baris transaksi tetap dipertahankan utuh ke dalam `scipy.sparse.csr_matrix` bertipe `bool`, lalu dikonversi ke `pd.DataFrame.sparse.from_spmatrix` agar nilai penyebut $N$ pada perhitungan `support` bersifat *100% eksak*.

Pada matriks sparse yang sama persis untuk setiap nilai `min_support`, dijalankan dua implementasi `mlxtend` @raschka2018mlxtend:
+ `apriori(sparse_df, min_support=ms, use_colnames=True, low_memory=True)`
+ `fpgrowth(sparse_df, min_support=ms, use_colnames=True)`

Setiap eksekusi diukur _wall-clock runtime_ (`time.perf_counter`) dan _peak traced Python memory_ (`tracemalloc`), serta diverifikasi secara terprogram bahwa himpunan _frequent itemsets_ antara Apriori dan FP-Growth *100% identik* (toleransi selisih support $< 10^(-12)$). Selanjutnya, dibangkitkan _association rules_ melalui `association_rules(..., metric="confidence", min_threshold=0.50)`.

== Metodologi Temporal Association Analysis (Bagian E)
Untuk menganalisis perubahan pola asosiasi dari waktu ke waktu, digunakan *Author-Year-Based Transactional Database* ($N = 4.088.557$ transaksi) yang dipartisi menjadi empat jendela periode: *2015–2017*, *2018–2020*, *2021–2023*, dan *2024–2025*.

Pada tiap periode dijalankan algoritma FP-Growth dan pembangkitan _association rules_ (`min_confidence = 50%`). Sebagai ambang utama digunakan `min_support = 0,10%` agar konsisten dengan Task 4. Karena transaksi tahunan bersifat jauh lebih _sparse_ (mayoritas peneliti hanya menerbitkan di 1 _venue_ per tahun), disediakan pula analisis sensitivitas pada `min_support = 0,05%` ($0,0005$) sehingga dinamika evolusi aturan lintas periode dapat diamati secara lebih kaya dan komparatif. Aturan yang ditemukan dikelompokkan berdasarkan kemunculannya ke dalam kategori _Persisten_ (4 periode), _Stabil_ (3 periode), _Emerging_ (2021–2025), dan *Declining/Hilang* (hanya 2015–2020).

// =========================================================================
// BAB IV — HASIL DAN PEMBAHASAN
// =========================================================================
= Hasil dan Pembahasan <bab-hasil>

== Hasil Preprocessing dan Statistik Dataset Bersih (Task 1.4)
Eksekusi `src/preprocessing.py` menyaring *2.004.202* record mentah dan membuang *3.445* record bermasalah (*0,17%*), menyisakan *2.000.757* publikasi bersih, *1.822.489* _author_ unik, dan *8.780* _conference/venue_ unik. Ringkasan lengkap proses pembersihan disajikan pada @tabel-prep-summary.

#figure(
  table(
    columns: (1.5fr, auto, auto),
    align: (left, right, right),
    [*Tahap Preprocessing*], [*Jumlah Record*], [*Persentase (%)*],
    [Raw records (`<inproceedings>` 2015–2025)], [2.004.202], [100,00%],
    [Dropped: invalid year (di luar 2015–2025)], [0], [0,00%],
    [Dropped: missing `key` atau `title`], [0], [0,00%],
    [Dropped: missing / empty `venue`], [-190], [-0,01%],
    [Dropped: empty `authors`], [-2.255], [-0,11%],
    [Dropped: duplicate `key`], [0], [0,00%],
    [Dropped: duplicate `(title_norm, year, venue)`], [-1.000], [-0,05%],
    [*Cleaned records (Total Publikasi Bersih)*], [*2.000.757*], [*99,83%*],
    [*Total Author Unik*], [*1.822.489*], [—],
    [*Total Conference / Venue Unik*], [*8.780*], [—],
  ),
  caption: [Ringkasan hasil _preprocessing_ dan statistik utama dataset DBLP bersih (2015–2025).],
) <tabel-prep-summary>

Distribusi publikasi bersih berdasarkan tahun (2015–2025) ditampilkan secara lengkap pada @tabel-pub-per-year dan divisualisasikan pada @gambar-pub-per-year. Terlihat tren pertumbuhan yang konsisten dari *161.306* publikasi pada tahun 2015 hingga puncak *213.580* publikasi pada tahun 2024 (+32,4%). Penurunan pada tahun 2020 (*172.070*, turun -8,8% dari 2019) mencerminkan disrupsi pandemi COVID-19 terhadap penyelenggaraan konferensi ilmiah, sedangkan angka 2025 (*199.583*) sedikit di bawah 2024 karena sejumlah prosiding akhir 2025 belum sepenuhnya terindeks pada _snapshot_ DBLP.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (center, right, right, center, right, right),
    [*Tahun*], [*Publikasi*], [*Proporsi (%)*], [*Tahun*], [*Publikasi*], [*Proporsi (%)*],
    [2015], [161.306], [8,06%], [2021], [178.488], [8,92%],
    [2016], [162.168], [8,11%], [2022], [178.329], [8,91%],
    [2017], [168.130], [8,40%], [2023], [201.702], [10,08%],
    [2018], [176.634], [8,83%], [2024], [213.580], [10,67%],
    [2019], [188.767], [9,43%], [2025], [199.583], [9,98%],
    [2020], [172.070], [8,60%], [*Total*], [*2.000.757*], [*100,00%*],
  ),
  caption: [Distribusi jumlah publikasi bersih berdasarkan tahun (2015–2025).],
) <tabel-pub-per-year>

#figure(
  image("../outputs/figures/01_publications_per_year.png", width: 88%),
  caption: [Grafik distribusi jumlah publikasi konferensi dan workshop DBLP per tahun (2015–2025).],
) <gambar-pub-per-year>

Untuk distribusi publikasi berdasarkan _conference/venue_, statistik deskriptif atas *8.780* _venue_ unik menunjukkan sebaran yang sangat miring ke kanan (_right-skewed_): rata-rata *227,88* makalah per _venue_ (simpangan baku *847,02*), nilai tengah (*median*) *48,50*, kuartil bawah ($Q_1$) *16*, kuartil atas ($Q_3$) *180*, minimum *1* makalah (pada 8 _venue_), dan maksimum *25.004* makalah (`NeurIPS`). Sebanyak *3.146* _venue_ memiliki minimal 100 publikasi, sementara 10 konferensi teratas sendiri menyumbang *8,34%* dari seluruh dua juta makalah. Distribusi 20 _venue_ dengan volume terbesar diperlihatkan pada @gambar-top20-venues.

#figure(
  image("../outputs/figures/01_top20_venues.png", width: 88%),
  caption: [Top 20 _conference/venue_ berdasarkan jumlah publikasi selama periode 2015–2025.],
) <gambar-top20-venues>

== Hasil Conference Popularity Analysis (Task 2)
=== 10 Konferensi dengan Jumlah Publikasi Terbanyak (Task 2.1)
Berdasarkan total makalah pada periode 2015–2025, 10 konferensi dengan aktivitas publikasi tertinggi dirangkum pada @tabel-top10-pub dan @gambar-top10-pub. *NeurIPS* memimpin jauh dengan *25.004* publikasi, diikuti konferensi pemrosesan sinyal *ICASSP* (*21.125*), penginderaan jauh *IGARSS* (*19.685*), AI umum *AAAI* (*18.406*), dan _Computer Vision_ *CVPR* (*17.435*).

#figure(
  table(
    columns: (auto, 1fr, auto, auto),
    align: (center, left, right, right),
    [*Peringkat*], [*Conference / Venue*], [*Jumlah Publikasi*], [*Pangsa Total (%)*],
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
  ),
  caption: [10 konferensi dengan jumlah publikasi terbanyak pada DBLP (2015–2025).],
) <tabel-top10-pub>

#figure(
  image("../outputs/figures/02a_top10_publications.png", width: 85%),
  caption: [Visualisasi Top 10 konferensi berdasarkan jumlah publikasi (2015–2025).],
) <gambar-top10-pub>

=== 10 Konferensi dengan Jumlah Author Unik Terbanyak (Task 2.2)
Untuk mengukur luasnya basis partisipasi peneliti, dihitung jumlah _author_ unik per _venue_. Hasil Top 10 tertera pada @tabel-top10-auth dan @gambar-top10-auth. *NeurIPS* tetap berada di peringkat \#1 dengan *56.073* _author_ unik, diikuti *AAAI* (*44.604*), *ICASSP* (*41.097*), *EMBC* (*39.318*), dan *IGARSS* (*35.229*). Berbeda dari daftar publikasi, dua konferensi jaringan saraf & *deep learning* yaitu *IJCNN* (*29.803*) dan *ICLR* (*28.751*) berhasil masuk ke Top 10 _author_ unik menggantikan ICRA dan CDC.

#figure(
  table(
    columns: (auto, 1fr, auto, auto),
    align: (center, left, right, right),
    [*Peringkat*], [*Conference / Venue*], [*Jumlah Author Unik*], [*Proporsi Author (%)*],
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
  ),
  caption: [10 konferensi dengan jumlah _author_ unik terbanyak pada DBLP (2015–2025).],
) <tabel-top10-auth>

#figure(
  image("../outputs/figures/02b_top10_unique_authors.png", width: 85%),
  caption: [Visualisasi Top 10 konferensi berdasarkan jumlah _author_ unik (2015–2025).],
) <gambar-top10-auth>

=== Tren Jumlah Publikasi Tahunan 2015–2025 (Task 2.3)
Perkembangan tahunan kesepuluh konferensi terpopuler dirangkum dalam @tabel-trend-tahunan dan divisualisasikan pada @gambar-trend-tahunan.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    align: (center, right, right, right, right, right, right, right, right, right, right),
    [*Tahun*], [*NeurIPS*], [*ICASSP*], [*IGARSS*], [*AAAI*], [*CVPR*], [*EMBC*], [*ICML*], [*IROS*], [*ICRA*], [*CDC*],
    [2015], [403], [1.198], [1.353], [673], [601], [2.004], [270], [970], [940], [1.258],
    [2016], [566], [1.322], [1.905], [691], [643], [1.578], [322], [830], [693], [1.213],
    [2017], [677], [1.321], [1.569], [785], [783], [1.123], [434], [878], [795], [1.023],
    [2018], [1.009], [1.395], [2.208], [1.100], [979], [1.473], [621], [1.086], [816], [1.054],
    [2019], [1.426], [1.735], [2.273], [1.340], [1.294], [1.669], [773], [934], [1.024], [1.195],
    [2020], [1.898], [1.863], [1.641], [1.864], [1.465], [1.462], [1.085], [1.128], [1.073], [768],
    [2021], [2.334], [1.723], [2.152], [1.960], [1.660], [1.639], [1.183], [1.032], [1.386], [935],
    [2022], [2.834], [1.864], [1.936], [1.623], [2.071], [1.105], [1.234], [1.213], [929], [980],
    [2023], [3.540], [2.720], [2.059], [2.020], [2.353], [1.237], [1.828], [1.195], [1.341], [1.119],
    [2024], [4.494], [2.678], [2.589], [2.865], [2.715], [1.386], [2.610], [1.581], [1.760], [1.107],
    [2025], [5.823], [3.306], [0], [3.485], [2.871], [0], [3.257], [1.985], [1.604], [1.014],
  ),
  caption: [Tren jumlah publikasi tahunan Top 10 konferensi selama periode 2015–2025.],
) <tabel-trend-tahunan>

#figure(
  image("../outputs/figures/02_top10_conferences_trend.png", width: 92%),
  caption: [Grafik tren jumlah publikasi tahunan Top 10 konferensi periode 2015–2025.],
) <gambar-trend-tahunan>

Terlihat pergeseran struktural yang mencolok: pada tahun 2015, konferensi dengan volume terbesar adalah *EMBC* (2.004), *IGARSS* (1.353), *CDC* (1.258), dan *ICASSP* (1.198), sementara *NeurIPS* (403) dan *ICML* (270) masih relatif kecil. Namun dalam kurun satu dekade hingga 2025, konferensi AI/ML melonjak tajam—*NeurIPS* tumbuh *14,4×* (`403 -> 5.823`), *ICML* *12,1×* (`270 -> 3.257`), *AAAI* *5,2×* (`673 -> 3.485`), dan *CVPR* *4,8×* (`601 -> 2.871`). Nilai `0` pada `IGARSS` dan `EMBC` di tahun 2025 mengindikasikan kedua prosiding IEEE tahun 2025 tersebut belum terindeks ke dalam _snapshot_ DBLP per 19 November 2026.

=== Perbandingan Ranking Publikasi vs Author Unik & Interpretasi (Task 2.4 & 2.5)
Secara global atas seluruh *8.780* _venue_, korelasi peringkat Spearman antara jumlah publikasi dan jumlah _author_ unik sangat tinggi ($rho = 0,9811$). Meskipun demikian, pada jajaran 15 besar (@tabel-cmp-pub-auth dan @gambar-pub-vs-auth-dual) terdapat perbedaan komposisi yang informatif.

#figure(
  table(
    columns: (1.1fr, auto, auto, auto, auto, auto, auto),
    align: (left, right, right, center, center, center, right),
    [*Conference*], [*Publikasi*], [*Author Unik*], [*Rank Pub*], [*Rank Auth*], [*Selisih*], [*Auth/Paper*],
    [NeurIPS], [25.004], [56.073], [1], [1], [0], [2,24],
    [ICASSP], [21.125], [41.097], [2], [3], [-1], [1,95],
    [IGARSS], [19.685], [35.229], [3], [5], [-2], [1,79],
    [AAAI], [18.406], [44.604], [4], [2], [+2], [2,42],
    [CVPR], [17.435], [34.970], [5], [6], [-1], [2,01],
    [EMBC], [14.676], [39.318], [6], [4], [+2], [2,68],
    [ICML], [13.617], [31.397], [7], [7], [0], [2,31],
    [IROS], [12.832], [31.200], [8], [8], [0], [2,43],
    [ICRA], [12.361], [28.542], [9], [11], [-2], [2,31],
    [CDC], [11.666], [14.393], [10], [35], [-25], [1,23],
    [IJCNN], [11.583], [29.803], [11], [9], [+2], [2,57],
    [ICC], [11.261], [22.052], [12], [15], [-3], [1,96],
    [IECON], [11.233], [24.038], [13], [13], [0], [2,14],
    [GLOBECOM], [11.078], [21.559], [14], [16], [-2], [1,95],
    [INTERSPEECH], [10.749], [17.834], [15], [25], [-10], [1,66],
  ),
  caption: [Perbandingan peringkat berdasarkan jumlah publikasi dan jumlah _author_ unik (Top 15 _venue_).],
) <tabel-cmp-pub-auth>

#figure(
  grid(
    columns: (1.15fr, 1fr),
    column-gutter: 8pt,
    image("../outputs/figures/02_top10_pub_vs_unique_authors.png", width: 100%),
    image("../outputs/figures/02_pub_vs_authors_scatter.png", width: 100%),
  ),
  caption: [Perbandingan Top 10 publikasi vs _author_ unik (kiri) dan sebaran _publikasi vs author unik_ pada Top 30 konferensi (kanan).],
) <gambar-pub-vs-auth-dual>

Menjawab ketiga pertanyaan analisis pada Task 2.5:
+ *Konferensi paling populer berdasarkan jumlah publikasi*: *NeurIPS* merupakan konferensi terpopuler dengan *25.004* publikasi (unggul +18,4% di atas peringkat \#2, ICASSP).
+ *Apakah konferensi dengan publikasi terbanyak juga memiliki author unik terbanyak?* *Ya pada peringkat \#1*, karena NeurIPS sekaligus menempati peringkat \#1 _author_ unik (*56.073*). Namun tidak identik di bawah peringkat \#1: *AAAI* (\#4 publikasi) naik ke \#2 _author_ unik (44.604) dan *EMBC* (\#6) naik ke \#4 (39.318; rasio `2,68` _author_ unik/paper) karena kolaborasi tim penulis lebih besar. Sebaliknya, *CDC* (\#10 publikasi, 11.666 paper) jatuh ke peringkat *\#35* _author_ unik (`14.393`; rasio hanya `1,23`), menandakan komunitas peneliti bidang kendali (_control_) yang relatif kecil namun berulang kali memublikasikan banyak makalah di konferensi tersebut. Hal serupa terlihat pada *INTERSPEECH* (\#15 publikasi $arrow$ \#25 _author_ unik; rasio `1,66`).
+ *Bagaimana perubahan aktivitas publikasi selama periode pengamatan?* Aktivitas publikasi bergeser dari dominasi konferensi teknik elektro/sinyal tradisional (2015–2017) menjadi ledakan eksponensial konferensi AI/ML & _Computer Vision_ sejak 2018–2025, sempat terkoreksi pada 2020 karena pandemi COVID-19 sebelum kembali mencetak rekor tertinggi pada 2023–2024.

== Hasil Transactional Database Construction (Task 3)
=== Pembentukan & Contoh Transaksi Kedua Representasi (Task 3.1 & 3.2)
Dengan skrip `src/transactions.py`, dataset bersih diubah menjadi *Author-Based Transactional Database* (1 baris = 1 _author_) dan *Author-Year-Based Transactional Database* (1 baris = 1 pasangan `author, year`). Sepuluh contoh representatif dari masing-masing basis data (mencakup transaksi multi-item dan single-item) ditampilkan pada @tabel-sample-author-tx dan @tabel-sample-ay-tx.

#figure(
  table(
    columns: (auto, 1fr, auto, 2.2fr),
    align: (center, left, center, left),
    [*No*], [*Author*], [*Jml Item*], [*Daftar Conference / Venue (Items)*],
    [1], [Simone Bianco 0001], [27], [`ACIVS, AI*IA, CCIW, CIC, CVPR, CVPR Workshops, ECAI, ECCV Workshops (3), ICCE-Berlin, ICIAP, ... (+17 venue)`],
    [2], [Dominic Price], [10], [`AIES (Main Track III & Student Abstracts), CHI, Conference on Designing Interactive Systems, ... (+7 venue)`],
    [3], [Jingtao Zhou], [8], [`CHI, CHI Extended Abstracts, ICASSP, ICCMA, KSEM (1), SIGGRAPH Asia, UIST (Adjunct Volume), VR Workshops`],
    [4], [Vaidyanathan Peruvemba Ramaswamy], [7], [`AAAI, CP, ICCS (2), ICTAI, NSE@ICSE, NeurIPS, UAI`],
    [5], [Raquel Robinson], [7], [`CHI Extended Abstracts, CHI PLAY, CHI PLAY (Companion), EMPATHICH, FDG, ICIDS, TEI`],
    [6], [Zixi Zhang], [3], [`CDC, FCCM, ICBCT`],
    [7], [Honghai Ma], [3], [`CISP-BMEI, IECON, IROS`],
    [8], [Luis R. Castrejon], [2], [`EMBC, ICORR`],
    [9], [Saghar Irandoust], [2], [`ICRA, NeurIPS`],
    [10], [Nihar Ranja Sahoo], [1], [`AAAI`],
  ),
  caption: [10 contoh transaksi dari *Author-Based Transactional Database* (`tables/task3_sample_author_tx.csv`).],
) <tabel-sample-author-tx>

#figure(
  table(
    columns: (auto, 1fr, auto, auto, 2fr),
    align: (center, left, center, center, left),
    [*No*], [*Author*], [*Tahun*], [*Jml Item*], [*Daftar Conference / Venue (Items)*],
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
  ),
  caption: [10 contoh transaksi dari *Author-Year-Based Transactional Database* (`tables/task3_sample_author_year_tx.csv`).],
) <tabel-sample-ay-tx>

=== Statistik Jumlah Transaksi, Item Unik & Distribusi Panjang (Task 3.3 & 3.4)
Perbandingan metrik agregat kedua representasi tersaji pada @tabel-tx-summary, sementara distribusi panjang transaksi dari `1` hingga `>10` item dirinci pada @tabel-tx-dist dan @gambar-tx-dist.

#figure(
  table(
    columns: (1.4fr, auto, auto),
    align: (left, right, right),
    [*Metrik Statistik*], [*Author-Based*], [*Author-Year-Based*],
    [Jumlah Total Transaksi ($N$)], [1.822.489], [4.088.557],
    [Jumlah Item Unik (*Conference/Venue*)], [8.780], [8.780],
    [Total Kemunculan Item ($sum n_"items"$)], [5.207.747], [6.652.015],
    [Transaksi *Single-Item* ($n = 1$)], [1.046.461 (57,42%)], [2.873.525 (70,28%)],
    [Transaksi *Multi-Item* ($n gt.eq 2$)], [776.028 (42,58%)], [1.215.032 (29,72%)],
    [Rata-rata Item per Transaksi ($plus.minus$ SD)], [2,8575 ($plus.minus$ 5,0835)], [1,6270 ($plus.minus$ 1,4890)],
    [Min / Median / P90 / P95 / P99 / Max], [1 / 1 / 6 / 10 / 23 / 396], [1 / 1 / 3 / 4 / 8 / 88],
  ),
  caption: [Ringkasan perbandingan jumlah transaksi, item unik, dan statistik panjang transaksi (Task 3.3 & 3.4).],
) <tabel-tx-summary>

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (center, right, right, right, right),
    [*Jumlah Item*], [*Author-Based (Tx)*], [*Author-Based (%)*], [*Author-Year (Tx)*], [*Author-Year (%)*],
    [1], [1.046.461], [57,42%], [2.873.525], [70,28%],
    [2], [291.188], [15,98%], [665.962], [16,29%],
    [3], [141.235], [7,75%], [259.202], [6,34%],
    [4], [84.518], [4,64%], [121.797], [2,98%],
    [5], [56.121], [3,08%], [64.298], [1,57%],
    [6], [39.296], [2,16%], [36.841], [0,90%],
    [7], [29.045], [1,59%], [22.174], [0,54%],
    [8], [22.233], [1,22%], [14.015], [0,34%],
    [9], [17.191], [0,94%], [9.032], [0,22%],
    [10], [13.620], [0,75%], [5.905], [0,14%],
    [>10], [81.581], [4,48%], [15.806], [0,39%],
  ),
  caption: [Distribusi jumlah item (_venue_ unik) per transaksi pada kedua representasi.],
) <tabel-tx-dist>

#figure(
  image("../outputs/figures/03_tx_length_distribution.png", width: 95%),
  caption: [Perbandingan distribusi panjang transaksi *Author-Based* vs *Author-Year-Based* (keseluruhan dan _zoom-in_ multi-item).],
) <gambar-tx-dist>

=== Analisis Perbedaan, Kelebihan, dan Keterbatasan (Task 3.5 & 3.6)
Perbedaan mendasar kedua representasi terletak pada *granularitas pengelompokan* dan *kepadatan (density)* keranjang:
+ *Author-Year-Based* menghasilkan *2,24× lebih banyak* transaksi (`4.088.557` vs `1.822.489`) karena riwayat peneliti dipecah per tahun aktif, dengan _item_ unik tetap identik (`8.780` _venue_).
+ Akibat pemecahan tahunan, proporsi transaksi _single-item_ meningkat dari *57,42%* (*Author-Based*) menjadi *70,28%* (*Author-Year-Based*), sehingga rata-rata panjang keranjang menyusut dari *2,86* menjadi *1,63* item (dan persentase keranjang panjang `>10` item turun dari `4,48%` menjadi hanya `0,39%`).
+ Dari sisi makna ko-okurensi, *Author-Based* menangkap keterkaitan komunitas riset sepanjang karier 11 tahun peneliti, sedangkan *Author-Year-Based* hanya menangkap ko-publikasi yang terjadi pada tahun kalender yang sama.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    align: (left, left, left),
    [*Aspek*], [*Author-Based Transaction*], [*Author-Year-Based Transaction*],
    [*Kelebihan*],
    [- Menangkap hubungan antar-konferensi lintas tahun, termasuk konferensi _biennial_ seperti `ICCV` (ganjil) dan `ECCV` (genap).\ - Proporsi transaksi multi-item lebih besar (`42,58%`) sehingga menghasilkan _frequent itemsets_ dan _association rules_ yang jauh lebih kaya.],
    [- Mempertahankan dimensi waktu eksplisit sehingga memungkinkan _Temporal Association Analysis_.\ - Memisahkan produktivitas tahunan secara spesifik dan menangkap kolaborasi intensif simultan pada tahun yang sama.],
    [*Keterbatasan*],
    [- Menghilangkan informasi kronologis (makalah tahun 2015 dan 2025 digabung dalam satu keranjang).\ - Dapat mencampur pergeseran bidang riset seorang peneliti selama 11 tahun menjadi satu asosiasi.],
    [- Sangat _sparse_ (`70,28%` hanya berisi 1 item) sehingga nilai _support_ pasangan _venue_ turun drastis.\ - Tidak mampu menangkap hubungan konferensi _biennial_ karena berlangsung di tahun yang berbeda.],
  ),
  caption: [Perbandingan kelebihan dan keterbatasan kedua representasi transaksi untuk _Frequent Pattern Mining_ (Task 3.6).],
) <tabel-tx-pros-cons>

== Hasil Frequent Pattern Mining (Task 4)
=== Ringkasan Jumlah 1-, 2-, dan 3-Itemsets di Seluruh Eksperimen (Task 4.1 & 4.2)
Implementasi Apriori dan FP-Growth pada *Author-Based Transactional Database* ($N = 1.822.489$) menghasilkan jumlah _frequent itemsets_ yang identik pada keempat nilai `min_support`, sebagaimana dirangkum pada @tabel-task4-sizes dan @gambar-task4-sizes.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    align: (center, right, right, right, right, right, right),
    [*Min Support*], [*1-Itemsets*], [*2-Itemsets*], [*3-Itemsets*], [*4- & 5-Itemsets*], [*Total Itemsets*], [*Rules (conf ≥ 50%)*],
    [0,1%], [534], [333], [237], [93 (85 + 8)], [1.197], [730],
    [0,5%], [63], [11], [1], [0], [75], [6],
    [1,0%], [24], [1], [0], [0], [25], [1],
    [2,0%], [4], [0], [0], [0], [4], [0],
  ),
  caption: [Jumlah _frequent itemsets_ menurut ukuran ($k$-itemset) dan jumlah _association rules_ pada setiap `min_support`.],
) <tabel-task4-sizes>

#figure(
  image("../outputs/figures/04a_itemsets_by_size.png", width: 86%),
  caption: [Pengaruh perubahan *minimum support* terhadap jumlah *frequent 1-, 2-, dan 3-itemsets*.],
) <gambar-task4-sizes>

=== Top 10 Frequent Itemsets untuk Setiap Eksperimen (Task 4.3)
Rincian 10 _frequent itemsets_ dengan nilai _support_ tertinggi pada masing-masing eksperimen (`0,1%`, `0,5%`, `1%`, `2%`) ditampilkan pada @tabel-top10-is-01-05 dan @tabel-top10-is-10-20, disertai identifikasi konkret *1-, 2-, dan 3-itemsets* tiap eksperimen:
- *Pada `min_support = 0,1%`*: ditemukan 534 *1-itemsets* (teratas: `NeurIPS` 3,08%, `AAAI` 2,45%, `ICASSP` 2,26%), 333 *2-itemsets* (teratas: `{ICML, NeurIPS}` 1,0008%), 237 *3-itemsets* (teratas: `{ICLR, ICML, NeurIPS}` 0,5445%), 85 *4-itemsets* (teratas: `{AAAI, ICLR, ICML, NeurIPS}` 0,2569%), serta 8 *5-itemsets*.
- *Pada `min_support = 0,5%`*: ditemukan 63 *1-itemsets*, *11 2-itemsets* (`{ICML, NeurIPS}` 1,0008%, `{ICLR, NeurIPS}` 0,9263%, `{AAAI, NeurIPS}` 0,8534%, `{CVPR, NeurIPS}` 0,7685%, `{CVPR, ICCV}` 0,7456%, `{ICLR, ICML}` 0,6741%, `{ICRA, IROS}` 0,6507%, `{AAAI, IJCAI}` 0,6041%, `{AAAI, CVPR}` 0,5958%, `{ICCV, NeurIPS}` 0,5727%, `{AAAI, ICML}` 0,5297%), dan *1 3-itemset* (`{ICLR, ICML, NeurIPS}` 0,5445%).
- *Pada `min_support = 1,0%`*: ditemukan 24 *1-itemsets*, tepat *1 2-itemset* (`{ICML, NeurIPS}` pada `1,0008%` / 18.239 _author_), dan *0 3-itemsets*.
- *Pada `min_support = 2,0%`*: hanya *4 1-itemsets* (`NeurIPS`, `AAAI`, `ICASSP`, `EMBC`) yang memenuhi ambang batas tanpa satupun *2-* atau *3-itemset*.

#figure(
  table(
    columns: (auto, 1.4fr, auto, auto, auto, 1.4fr, auto, auto, auto),
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
  ),
  caption: [Top 10 _frequent itemsets_ pada eksperimen `min_support = 0,1%` dan `0,5%` (kesepuluh posisi teratas diisi konferensi tunggal berpartisipan >28 ribu _author_).],
) <tabel-top10-is-01-05>

#figure(
  table(
    columns: (auto, 1.4fr, auto, auto, auto, 1.4fr, auto, auto, auto),
    align: (center, left, center, right, right, left, center, right, right),
    [*No*], [*Itemset (1,0%)*], [*Len*], [*Sup (%)*], [*Tx*], [*Itemset (2,0%)*], [*Len*], [*Sup (%)*], [*Tx*],
    [1], [NeurIPS], [1], [3,08%], [56.073], [NeurIPS], [1], [3,08%], [56.073],
    [2], [AAAI], [1], [2,45%], [44.604], [AAAI], [1], [2,45%], [44.604],
    [3], [ICASSP], [1], [2,26%], [41.097], [ICASSP], [1], [2,26%], [41.097],
    [4], [EMBC], [1], [2,16%], [39.318], [EMBC], [1], [2,16%], [39.318],
    [5], [IGARSS], [1], [1,93%], [35.229], [_(hanya 4 itemsets)_], [—], [—], [—],
    [6], [CVPR], [1], [1,92%], [34.970], [—], [—], [—], [—],
    [7], [ICML], [1], [1,72%], [31.397], [—], [—], [—], [—],
    [8], [IROS], [1], [1,71%], [31.200], [—], [—], [—], [—],
    [9], [IJCNN], [1], [1,64%], [29.803], [—], [—], [—], [—],
    [10], [ICLR], [1], [1,58%], [28.751], [—], [—], [—], [—],
  ),
  caption: [Top 10 _frequent itemsets_ pada eksperimen `min_support = 1,0%` dan seluruh _frequent itemsets_ (4 itemsets) pada `min_support = 2,0%`.],
) <tabel-top10-is-10-20>

=== Pengaruh Minimum Support, Kombinasi Conference Terkuat & Interpretasi (Task 4.4–4.6)
Kenaikan `min_support` menurunkan jumlah _frequent itemsets_ secara sangat tajam dan non-linear (dari *1.197* pada `0,1%` menjadi *75* pada `0,5%`, turun *93,7%*, lalu *25* pada `1%`, dan hanya *4* pada `2%`). Hal ini terjadi karena sifat _long-tail_ basis data bibliografi berskala besar (8.780 _venue_), sehingga bahkan konferensi \#1 (`NeurIPS`) hanya muncul pada `3,08%` transaksi _author_. Akibatnya, `min_support` yang terlalu tinggi (`1%–2%`) gagal menangkap pola ko-okurensi lintas-konferensi, sedangkan `0,1%` ($gt.eq 1.823$ _author_) ideal untuk menyingkap klaster komunitas riset Ilmu Komputer.

@tabel-top-combos dan @gambar-top-combos menampilkan kombinasi 2-konferensi dan 3-konferensi yang paling sering muncul bersama pada `min_support = 0,1%`.

#figure(
  table(
    columns: (auto, 1.5fr, auto, auto, 1.7fr, auto, auto),
    align: (center, left, right, right, left, right, right),
    [*No*], [*Top 2-Itemsets*], [*Sup (%)*], [*Author*], [*Top 3-Itemsets*], [*Sup (%)*], [*Author*],
    [1], [ICML, NeurIPS], [1,00%], [18.239], [ICLR, ICML, NeurIPS], [0,54%], [9.924],
    [2], [ICLR, NeurIPS], [0,93%], [16.882], [CVPR, ICCV, NeurIPS], [0,43%], [7.802],
    [3], [AAAI, NeurIPS], [0,85%], [15.554], [AAAI, ICML, NeurIPS], [0,41%], [7.456],
    [4], [CVPR, NeurIPS], [0,77%], [14.006], [AAAI, ICLR, NeurIPS], [0,38%], [7.005],
    [5], [CVPR, ICCV], [0,75%], [13.588], [AAAI, CVPR, NeurIPS], [0,37%], [6.756],
    [6], [ICLR, ICML], [0,67%], [12.285], [CVPR, ICLR, NeurIPS], [0,35%], [6.463],
    [7], [ICRA, IROS], [0,65%], [11.859], [AAAI, CVPR, ICCV], [0,33%], [6.022],
    [8], [AAAI, IJCAI], [0,60%], [11.010], [AAAI, IJCAI, NeurIPS], [0,32%], [5.847],
    [9], [AAAI, CVPR], [0,60%], [10.858], [CVPR, ICML, NeurIPS], [0,32%], [5.773],
    [10], [ICCV, NeurIPS], [0,57%], [10.437], [AAAI, ICCV, NeurIPS], [0,29%], [5.334],
  ),
  caption: [Top 10 kombinasi 2-konferensi dan 3-konferensi yang paling sering muncul bersama (`min_support = 0,1%`).],
) <tabel-top-combos>

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    image("../outputs/figures/04b_top_cooccurring_2itemsets.png", width: 100%),
    image("../outputs/figures/04c_top_cooccurring_3itemsets.png", width: 100%),
  ),
  caption: [Kombinasi 2-konferensi (kiri) dan 3-konferensi (kanan) paling sering muncul bersama pada `min_support = 0,1%`.],
) <gambar-top-combos>

*Interpretasi Domain Riset (Task 4.6)*: Pola kombinasi teratas membentuk lima klaster komunitas peneliti Ilmu Komputer yang sangat kohesif: (1) *Poros Inti Machine Learning / Deep Learning* (`{ICLR, ICML, NeurIPS}` beririsan pada 9.924 peneliti); (2) _Computer Vision_ (`{CVPR, ICCV}` beririsan 13.588 peneliti); (3) *Artificial Intelligence Umum* (`{AAAI, IJCAI}` 11.010 peneliti, serta irisan kuat dengan ML dan Vision); (4) *Robotika* (`{ICRA, IROS}` 11.859 peneliti); serta (5) *Telekomunikasi* (`{GLOBECOM, ICC}` dengan 8.906 peneliti, `0,49%`).

== Hasil Association Rule Mining (Task 5)
=== Pembangkitan Rules & Top 10 Rules Berdasarkan Lift (Task 5.1 & 5.2)
Dengan ambang batas `min_confidence = 50%`, dihasilkan *730* _association rules_ pada `min_support = 0,1%` (nilai _lift_ berkisar antara `16,48×` hingga `122,68×`, rata-rata `42,63×`), *6* rules pada `0,5%`, *1* rule pada `1,0%` (`ICML -> NeurIPS`), dan *0* rules pada `2,0%`. Sepuluh _association rules_ dengan nilai _lift_ tertinggi (dari `0,1%`) disajikan pada @tabel-top10-lift, seluruh 6 rules pada `0,5%` (beserta 1 rule `1,0%`) pada @tabel-rules-05-10, dan visualisasinya pada @gambar-arm-analysis.

#figure(
  table(
    columns: (auto, 2fr, auto, auto, auto, auto),
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
  caption: [Top 10 _association rules_ dengan nilai _lift_ tertinggi (`min_support = 0,1%`, `min_confidence = 50%`).],
) <tabel-top10-lift>

#figure(
  table(
    columns: (auto, 1.8fr, auto, auto, auto, auto, auto),
    align: (center, left, right, right, right, right, center),
    [*No*], [*Association Rule*], [*Support (%)*], [*Confidence (%)*], [*Lift*], [*Author*], [*Lolos di*],
    [1], [`ICML, NeurIPS -> ICLR`], [0,5445], [54,41], [34,49], [9.924], [0,5%],
    [2], [`ICLR, NeurIPS -> ICML`], [0,5445], [58,78], [34,12], [9.924], [0,5%],
    [3], [`ICCV -> CVPR`], [0,7456], [56,35], [29,37], [13.588], [0,5%],
    [4], [`ICLR, ICML -> NeurIPS`], [0,5445], [80,78], [26,26], [9.924], [0,5%],
    [5], [`ICLR -> NeurIPS`], [0,9263], [58,72], [19,08], [16.882], [0,5%],
    [6], [`ICML -> NeurIPS`], [1,0008], [58,09], [18,88], [18.239], [0,5% & 1,0%],
  ),
  caption: [Seluruh _association rules_ yang ditemukan pada `min_support = 0,5%` (6 rules) dan `1,0%` (1 rule).],
) <tabel-rules-05-10>

#figure(
  grid(
    columns: (1fr, 1.05fr),
    column-gutter: 8pt,
    image("../outputs/figures/05a_rules_scatter.png", width: 100%),
    image("../outputs/figures/05b_top10_rules_lift.png", width: 100%),
  ),
  caption: [Sebaran _support vs confidence_ 730 rules berwarna menurut _lift_ (kiri) dan Top 10 rules berdasarkan _lift_ (kanan).],
) <gambar-arm-analysis>

=== Asosiasi Menarik, Support Tinggi vs Lift Tinggi, dan Interpretasi (Task 5.3–5.6)
+ *Hubungan Asosiasi Antar-Konferensi yang Paling Menarik (Task 5.3)*:
  - *Jembatan Vision–Multimedia–AI*: Aturan dengan _lift_ tertinggi (*122,68×*) ialah `ACM Multimedia, CVPR, NeurIPS -> AAAI, ICCV` (`support = 0,1276%`, `conf = 55,33%`), diikuti `ICCV, ICML, NeurIPS -> CVPR, ICLR` (_lift_ *122,14×*), memperlihatkan mobilitas tinggi peneliti *multimodal vision-learning*.
  - *Konfidensi Tertinggi (>93%)*: Peneliti yang memublikasikan di `AAAI, ICCV, ICLR, ICML -> NeurIPS` mencapai _confidence_ *93,85%* (_lift_ 30,50×), menunjukkan hampir dapat dipastikan (`>9 dari 10` peneliti) mereka juga menerbitkan makalah di NeurIPS.
  - *Asosiasi Domain Terspesialisasi*: Pada sub-bidang kendali, aturan `ACC, ECC -> CDC` memiliki _confidence_ *73,35%* dengan _lift_ tinggi (*92,88×*, ranking \#16 secara keseluruhan), sementara pada NLP, `AAAI, ACL (1), EMNLP (Findings) -> ACL (Findings)` mencapai _lift_ *93,40×* (`conf = 67,50%`).
+ *Apakah Conference dengan Support Tinggi Selalu Menghasilkan Lift Tinggi? (Task 5.4)*:
  - *Tidak.* Sebaran pada @gambar-arm-analysis (kiri) membuktikan adanya hubungan terbalik antara popularitas _consequent_ dan nilai _lift_. Aturan dengan _support_ tertinggi yaitu `ICML -> NeurIPS` (`support = 1,0008%`, `conf = 58,09%`) hanya menghasilkan _lift_ *18,88×* karena penyebut $"Support"("NeurIPS") = 3,08\%$ sudah sangat besar secara marginal. Sebaliknya, aturan dengan _consequent_ ganda yang lebih spesifik seperti `AAAI, ICCV` (`support = 0,451%`) menghasilkan _lift_ mencapai *122,68×* meskipun nilai _support_ aturannya jauh lebih kecil (`0,1276%`).
+ *Perbedaan Interpretasi Support, Confidence, dan Lift (Task 5.5)*:
  - *Support* mengukur *cakupan/frekuensi global* seberapa umum kombinasi konferensi muncul di seluruh komunitas DBLP.
  - *Confidence* mengukur *kekuatan implikasi bersyarat* ($P(B mid A)$) dari suatu arah aturan, namun mudah terdistorsi apabila item _consequent_ $B$ memiliki popularitas dasar yang tinggi (mis. banyak rules berujung ke `NeurIPS` memiliki confidence tinggi semata karena NeurIPS berukuran raksasa).
  - *Lift* menormalisasi _confidence_ dengan $P(B)$ sehingga mengukur *kekuatan asosiasi sejati* (_excess co-occurrence_) melebihi kebetulan acak.
+ *Pola Publikasi Antar-Konferensi yang Teridentifikasi (Task 5.6)*:
  Peneliti Ilmu Komputer cenderung membentuk ekosistem publikasi bertingkat dan saling melengkapi: (a) peneliti _Deep Learning_ berputar pada trio inti `NeurIPS–ICML–ICLR`, (b) peneliti _Computer Vision_ mengombinasikan `CVPR–ICCV` (serta `ECCV` dan `WACV`), (c) peneliti *Multimodal & General AI* menjembatani `ACM Multimedia`, `AAAI`, dan `IJCAI` ke konferensi inti ML/Vision, dan (d) bidang teknik klasik seperti *Control* (`ACC–ECC–CDC`) membentuk kohesi sangat tinggi (`lift 92,88×`) meski volume publikasinya jauh lebih kecil.

== Perbandingan Performa Algoritma Apriori vs FP-Growth (Task 6)
Pengujian komparatif antara Apriori (`low_memory=True`) dan FP-Growth pada matriks sparse *Author-Based* yang sama untuk keempat nilai `min_support` menghasilkan metrik pada @tabel-task6-comp dan @gambar-task6-comp.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto),
    align: (center, right, right, right, center, right, right, right, right),
    [*Min Sup*], [*Item*], [*Itemsets*], [*Rules*], [*Identik?*], [*Apriori (s)*], [*FP-Growth (s)*], [*Apriori (MB)*], [*FP-Growth (MB)*],
    [0,1%], [534], [1.197 / 1.197], [730 / 730], [Ya], [21,26], [77,93], [1.893,3], [952,0],
    [0,5%], [63], [75 / 75], [6 / 6], [Ya], [1,02], [53,59], [240,3], [125,6],
    [1,0%], [24], [25 / 25], [1 / 1], [Ya], [0,35], [57,76], [100,0], [55,4],
    [2,0%], [4], [4 / 4], [0 / 0], [Ya], [0,05], [50,61], [30,8], [18,3],
  ),
  caption: [Perbandingan performa algoritma Apriori vs FP-Growth pada *Author-Based Database* ($N = 1.822.489$).],
) <tabel-task6-comp>

#figure(
  image("../outputs/figures/06_algorithm_performance_comparison.png", width: 95%),
  caption: [Perbandingan waktu eksekusi (kiri) dan _peak traced memory_ (kanan) antara Apriori dan FP-Growth.],
) <gambar-task6-comp>

Menjawab ketiga pertanyaan evaluasi pada Task 6:
+ *Bagaimana perubahan minimum support memengaruhi performa kedua algoritma?* Penurunan `min_support` dari `2%` ke `0,1%` memperbanyak item kandidat dari *4* menjadi *534*, sehingga memicu lonjakan eksponensial pada *Apriori*: waktu eksekusi meningkat *414×* (`0,05s -> 21,26s`) dan _peak memory_ melonjak *61,5×* (`30,8 MB -> 1.893,3 MB`) akibat pembangkitan kandidat level demi level. Sebaliknya, *FP-Growth* menunjukkan pertumbuhan waktu yang jauh lebih landai (`50,61s -> 77,93s`) karena biaya konstruksi awal FP-Tree atas 1,82 juta baris relatif tetap, dan konsumsi memorinya konsisten *\~48–50% lebih hemat* dibanding Apriori di seluruh ambang batas.
+ *Apakah kedua algoritma menghasilkan frequent itemsets yang sama?* *Ya, 100% identik* di semua nilai `min_support` (`itemsets_identical = True`, selisih nilai support $< 10^(-12)$), sehingga jumlah _association rules_ yang dibangkitkan juga sama persis (`730`, `6`, `1`, dan `0`).
+ *Algoritma mana yang lebih sesuai untuk dataset DBLP yang digunakan?* Terdapat _trade-off_ antara efisiensi memori dan karakteristik implementasi:
  - Dari sisi *efisiensi memori dan skalabilitas algoritmik* pada _min_support_ rendah (`<= 0,1%`)—yang memang wajib digunakan pada dataset DBLP berdistribusi _long-tail_—*FP-Growth* lebih sesuai karena menghindari ledakan pembangkitan kandidat (*candidate generation*) dan memangkas konsumsi RAM puncak hingga setengahnya (`952,0 MB` vs `1.893,3 MB`).
  - Dari sisi *kecepatan praktis di pustaka Python `mlxtend`* pada rentang `0,1%–2%`, Apriori (`low_memory=True` di atas matriks CSR sparse) beroperasi lebih cepat (`0,05–21,26s`) karena mengandalkan perkalian/penjumlahan array tervektorisasi di C/NumPy, sedangkan `mlxtend.fpgrowth` membangun node FP-Tree baris demi baris di _pure Python_ dengan _overhead_ awal \~50 detik untuk 1,82 juta transaksi. Oleh karena itu, FP-Growth paling direkomendasikan ketika RAM terbatas atau saat mengeksplorasi `min_support < 0,1%`.

== Hasil Temporal Association Analysis (Bagian E)
=== Frequent Itemsets & Association Rules Per Periode (E.1–E.3)
*Author-Year-Based Transactional Database* (`4.088.557` transaksi) dibagi menjadi empat periode waktu. Rekap jumlah transaksi, proporsi multi-item, jumlah _frequent itemsets_, dan jumlah _association rules_ (`min_confidence = 50%`) pada baseline `0,10%` dan sensitivitas `0,05%` dirangkum pada @tabel-temporal-summary dan @gambar-temporal-counts, sedangkan contoh *frequent 1-itemsets* dan *2-itemsets* teratas setiap periode tersaji pada @tabel-temporal-itemsets.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto),
    align: (center, right, right, right, right, right, right, right),
    [*Periode*], [*Transaksi*], [*Multi (%)*], [*1/2/3+ IS (0,1%)*], [*Total IS (0,1%)*], [*Rules (0,1%)*], [*Total IS (0,05%)*], [*Rules (0,05%)*],
    [2015–2017], [922.999], [29,99%], [295 / 7 / 0], [302], [1], [799], [1],
    [2018–2020], [1.081.611], [28,98%], [267 / 12 / 0], [279], [0], [763], [0],
    [2021–2023], [1.196.891], [28,79%], [266 / 38 / 2], [306], [2], [792], [15],
    [2024–2025], [887.056], [31,58%], [266 / 100 / 54], [420], [37], [1.065], [212],
  ),
  caption: [Statistik transaksi, _frequent itemsets_, dan _association rules_ per periode (`Author-Year-Based`, `conf >= 50%`).],
) <tabel-temporal-summary>

#figure(
  table(
    columns: (auto, 1.3fr, 1.5fr),
    align: (center, left, left),
    [*Periode*], [*Top 3 1-Itemsets (Support %)*], [*Top 3 2-Itemsets (Support %)*],
    [2015–2017], [`EMBC` (1,87%), `IGARSS` (1,49%), `ICC` (1,12%)], [`GLOBECOM, ICC` (0,25%), `ACC, CDC` (0,20%), `ICRA, IROS` (0,19%)],
    [2018–2020], [`IGARSS` (1,78%), `EMBC` (1,62%), `AAAI` (1,34%)], [`ICML, NeurIPS` (0,24%), `ICRA, IROS` (0,20%), `AAAI, IJCAI` (0,20%)],
    [2021–2023], [`NeurIPS` (2,59%), `CVPR` (1,86%), `AAAI` (1,76%)], [`ICML, NeurIPS` (0,45%), `ICLR, NeurIPS` (0,41%), `CVPR, ICCV` (0,39%)],
    [2024–2025], [`NeurIPS` (4,93%), `AAAI` (2,90%), `ICLR` (2,81%)], [`ICLR, NeurIPS` (1,04%), `ICML, NeurIPS` (0,98%), `CVPR, NeurIPS` (0,77%)],
  ),
  caption: [Identifikasi *frequent 1-itemsets* dan *2-itemsets* teratas pada setiap periode (Bagian E.2).],
) <tabel-temporal-itemsets>

#figure(
  image("../outputs/figures/07_temporal_counts.png", width: 92%),
  caption: [Perbandingan jumlah _frequent itemsets_ (kiri) dan _association rules_ (kanan) antarperiode pada `0,10%` dan `0,05%`.],
) <gambar-temporal-counts>

=== Perbandingan Rules Antarperiode, Pola Bertahan vs Berubah & Tren Publikasi (E.4–E.6)
Perbandingan aturan asosiasi lintas periode memperlihatkan dinamika struktural yang sangat kontras (terlihat pada @tabel-temporal-evolution dan @gambar-temporal-heatmap):

#figure(
  table(
    columns: (1.9fr, 1fr, auto, auto, auto, auto),
    align: (left, left, right, right, right, right),
    [*Association Rule*], [*Status Pola*], [*2015–17*], [*2018–20*], [*2021–23*], [*2024–25*],
    [`ECOC -> OFC`], [Declining/Hilang], [59,8×], [—], [—], [—],
    [`ACL (1), EMNLP (Findings) -> EMNLP`], [Emerging (2021–25)], [—], [—], [84,7×], [32,4×],
    [`ICCV, ICLR -> CVPR`], [Emerging (2021–25)], [—], [—], [32,1×], [20,4×],
    [`ICCV, NeurIPS -> CVPR`], [Emerging (2021–25)], [—], [—], [30,6×], [19,9×],
    [`AAAI, ICCV -> CVPR`], [Emerging (2021–25)], [—], [—], [28,9×], [19,3×],
    [`ACM Multimedia, ICCV -> CVPR`], [Emerging (2021–25)], [—], [—], [28,5×], [19,8×],
    [`ICLR, ICML -> NeurIPS`], [Emerging (2021–25)], [—], [—], [24,4×], [12,1×],
    [`CVPR, ICML -> NeurIPS`], [Emerging (2021–25)], [—], [—], [23,7×], [12,7×],
    [`AAAI, ICLR -> NeurIPS`], [Emerging (2021–25)], [—], [—], [23,3×], [12,3×],
    [`ACL (Findings), EMNLP (Findings), ICLR -> ACL (1)`], [Baru (2024–25)], [—], [—], [—], [49,7×],
  ),
  caption: [Evolusi nilai *Lift* aturan asosiasi kunci antarperiode pada analisis sensitivitas `min_support = 0,05%` (`conf >= 50%`).],
) <tabel-temporal-evolution>

#figure(
  image("../outputs/figures/08_temporal_rules_heatmap.png", width: 88%),
  caption: [Peta panas (_heatmap_) evolusi nilai _lift_ Top 15 _association rules_ melintasi empat periode (`min_sup = 0,05%`).],
) <gambar-temporal-heatmap>

*Interpretasi Evolusi Tren Publikasi (Bagian E.5 & E.6)*:
+ *Pola yang Menghilang (Declining/Historical)*: Pada periode *2015–2017*, satu-satunya aturan yang memenuhi `conf >= 50%` (baik pada `0,10%` maupun `0,05%`) adalah `ECOC -> OFC` (_lift_ `59,83×`, *conf* `51,59%`, domain komunikasi optik). Memasuki periode *2018–2020*, tidak ada aturan yang mencapai `conf >= 50%`—meski pasangan `ICML, NeurIPS` mulai menyalip `GLOBECOM, ICC` sebagai 2-itemset teratas—yang menunjukkan peneliti saat itu masih jarang menembus beberapa konferensi utama sekaligus dalam satu tahun kalender.
+ *Pola yang Bertahan & Menguat di Era Modern (2021–2025)*: Sebanyak *12 aturan* muncul konsisten pada `2021–2023` dan terus bertahan pada `2024–2025`, antara lain `ICLR, ICML -> NeurIPS` (`support` melonjak dari `0,16%` menjadi `0,43%`), `ICCV, NeurIPS -> CVPR` (`0,13% -> 0,21%`), dan `ACL (1), EMNLP (Findings) -> EMNLP` (`0,06% -> 0,14%`). Menariknya, meskipun nilai _support_ seluruh aturan tersebut meningkat hingga 2–3 kali lipat di 2024–2025, nilai _lift_-nya turun (mis. `24,4× -> 12,1×` ke NeurIPS) karena _support_ marginal `NeurIPS` naik hampir dua kali lipat (`2,59% -> 4,93%`), menandakan konferensi tujuan tersebut semakin _mainstream_.
+ *Ledakan Pola Baru (Emerging 2024–2025)*: Pada periode 2024–2025 (hanya 2 tahun, namun proporsi keranjang multi-item mencapai rekor *31,58%*), jumlah rules meledak dari `2 -> 37` (pada `0,10%`) dan `15 -> 212` (pada `0,05%`). Kemunculan belasan aturan ber-_lift_ tinggi (`>40×`) yang menggabungkan _venue_ *NLP* (`ACL (1)`, `ACL (Findings)`, `EMNLP`, `EMNLP (Findings)`, `NAACL`) dengan konferensi *ML/AI* (`ICLR`, `NeurIPS`, `ICML`, `AAAI`) merefleksikan konvergensi masif komunitas riset akibat booming *Large Language Models (LLM)* dan _Multimodal AI_ pasca-2022.

#pagebreak(weak: true)
== Keterbatasan Dataset dan Asumsi Analisis (Bagian F.8)
+ *Keterlambatan Indeksasi Parsial Tahun 2025*: Pada _snapshot_ 19 November 2026, beberapa prosiding konferensi besar tahun 2025 (termasuk `IGARSS` dan `EMBC` yang masih tercatat `0` pada 2025) belum masuk ke dalam dump XML DBLP, sehingga total publikasi 2025 sedikit lebih rendah dari 2024.
+ *Granularitas Penamaan Track/Findings*: Pemisahan prosiding resmi di DBLP—seperti `ACL (1)` vs `ACL (Findings)` dan `EMNLP` vs `EMNLP (Findings)`—dipertahankan apa adanya. Hal ini menjaga fidelitas terhadap metadata DBLP, namun turut menghasilkan aturan intra-konferensi yang memiliki _lift_ sangat tinggi pada periode 2021–2025.
+ *Ketergantungan pada Disambiguasi Penulis DBLP*: Dengan mempertahankan suffix `0001`, analisis mengasumsikan skema disambiguasi DBLP telah memisahkan penulis homonim secara memadai; anomali minor tetap mungkin terjadi untuk penulis baru yang belum terdisambiguasi.
+ *Bias Aktivitas Publikasi*: Pengukuran popularitas berbasis jumlah publikasi dan _author_ unik mencerminkan ukuran dan keterbukaan kapasitas penerimaan (_throughput_) suatu konferensi, bukan kualitas relatif maupun tingkat selektivitas (_acceptance rate_).

// =========================================================================
// BAB V — PENUTUP
// =========================================================================
= Penutup <bab-penutup>

== Kesimpulan dan Jawaban Pertanyaan Kesimpulan (Bagian H)
Seluruh eksperimen menjawab secara empiris tujuh pertanyaan kesimpulan pada spesifikasi project sebagai berikut:

+ *Konferensi dengan popularitas publikasi tertinggi*: *NeurIPS* menempati peringkat \#1 baik dari jumlah publikasi (*25.004* makalah) maupun jumlah _author_ unik (*56.073* peneliti), diikuti *ICASSP* (21.125 makalah) dan *IGARSS* (19.685 makalah) pada volume publikasi, serta *AAAI* (44.604) dan *ICASSP* (41.097) pada jumlah _author_ unik.
+ *Apakah konferensi paling populer juga memiliki asosiasi paling kuat?* *Tidak selalu.* `NeurIPS` memang mendominasi aturan dengan _support_ tertinggi (`ICML -> NeurIPS`, support `1,0008%`, confidence `58,09%`), tetapi nilai _lift_-nya tergolong moderat (`18,88×`) akibat penyebut popularitas NeurIPS yang sangat besar (`3,08%`). Asosiasi dengan _lift_ terkuat justru muncul pada kombinasi konferensi yang lebih spesifik atau antar-subkomunitas erat.
+ *Kombinasi konferensi yang paling sering muncul bersama dalam riwayat author*: Untuk 2-konferensi ialah *`{ICML, NeurIPS}`* (*18.239* _author_, support `1,0008%`), disusul `{ICLR, NeurIPS}` (16.882; `0,9263%`), `{AAAI, NeurIPS}` (15.554; `0,8534%`), `{CVPR, NeurIPS}` (14.006; `0,7685%`), dan `{CVPR, ICCV}` (13.588; `0,7456%`). Untuk 3-konferensi ialah *`{ICLR, ICML, NeurIPS}`* (*9.924* _author_, `0,5445%`), diikuti `{CVPR, ICCV, NeurIPS}` (7.802; `0,4281%`).
+ *Association rules dengan lift tertinggi dan maknanya*: *`ACM Multimedia, CVPR, NeurIPS -> AAAI, ICCV`* dengan `support = 0,1276%` (`2.325` _author_), `confidence = 55,33%`, dan *`lift = 122,68×`*. Maknanya, peneliti yang telah memublikasikan makalah di ACM Multimedia, CVPR, dan NeurIPS memiliki kecenderungan *122,68 kali lebih besar* dibandingkan rata-rata populasi DBLP untuk juga aktif memublikasikan di AAAI dan ICCV—menggambarkan kohesi luar biasa tinggi pada klaster peneliti *Multimodal AI & Computer Vision*.
+ *Perbedaan pola pada Author-Based vs Author-Year-Based Database*: *Ya, sangat signifikan.* *Author-Based* menghasilkan pola yang jauh lebih kaya (*1.197* _frequent itemsets_ dan *730* rules pada `0,1%`) serta mampu menangkap ko-okurensi lintas tahun (seperti pasangan konferensi _biennial_ `CVPR–ICCV`). Sebaliknya, *Author-Year-Based* jauh lebih _sparse_ (`70,28%` transaksi tunggal) sehingga hanya meloloskan publikasi simultan dalam tahun kalender yang sama (hanya 1–37 rules per periode pada `0,1%`), namun sangat efektif menyingkap pergeseran tren historis dari waktu ke waktu.
+ *Algoritma dengan performa terbaik*: Kedua algoritma menghasilkan output *100% identik*. *FP-Growth* unggul mutlak pada *efisiensi memori* (*952,0 MB* vs *1.893,3 MB* pada `0,1%`, hemat \~50%) dan skalabilitas ketika *minimum support* sangat kecil tanpa membangkitkan kandidat eksplisit. Sementara itu, pada eksekusi `mlxtend` di Python dengan matriks CSR sparse untuk rentang `0,1%–2%`, *Apriori (`low_memory=True`)* tercatat lebih cepat secara *wall-clock* (`21,26s` vs `77,93s`) karena vektorisasi array SciPy/NumPy dibanding pembangunan FP-Tree secara iteratif di Python.
+ *Insight utama yang berhasil diperoleh*: Lanskap penelitian Ilmu Komputer 2015–2025 mengalami pergeseran struktural besar ke arah dominasi ekosistem *AI, Machine Learning, Computer Vision, dan NLP*. Para peneliti di sub-bidang tersebut membentuk klaster publikasi lintas-konferensi yang sangat erat (`NeurIPS–ICML–ICLR`, `CVPR–ICCV`, `ACL–EMNLP`), yang akselerasinya meningkat tajam pada periode *2021–2025* dengan lonjakan jumlah aturan asosiasi tahunan hingga lebih dari *14× lipat* (`15 -> 212` rules pada `0,05%`).

== Saran
+ *Normalisasi Track Lanjutan*: Penelitian berikutnya dapat menambahkan opsi pengelompokan tingkat seri konferensi (menggabungkan _main track_, _Findings_, dan _Workshops_ ke konferensi induknya) sebagai pembanding terhadap analisis granularitas prosiding DBLP.
+ *Integrasi Metrik Dampak*: Menggabungkan data aktivitas publikasi DBLP dengan basis data sitasi terbuka (seperti OpenAlex atau Semantic Scholar) untuk membedakan popularitas berbasis *volume aktivitas* dan popularitas berbasis *dampak sitasi*.
+ *Eksplorasi Sequential Pattern Mining*: Memanfaatkan urutan tahun publikasi pada dataset *Author-Year* menggunakan algoritma sekuensial (seperti PrefixSpan) untuk melacak arah transisi karier peneliti (misalnya perpindahan peneliti dari konferensi teknik tradisional menuju konferensi AI/ML).

// =========================================================================
// LAMPIRAN
// =========================================================================
#appendix(title: [Artefak Kode, Notebook, dan Tabel Hasil Eksperimen], label: <lampiran-artefak>)[
  Seluruh skrip sumber, pengujian otomatis, *Jupyter Notebooks*, tabel CSV, dan visualisasi dapat direproduksi menggunakan perintah berikut pada *virtual environment* proyek:

  #figure(
    ```bash
    python -m src.download       # Unduh DBLP XML dump + metadata SHA-256
    python -m src.parser         # Ekstrak <inproceedings> 2015-2025 & hitung tipe XML
    python -m src.preprocessing  # Pembersihan, normalisasi & deduplikasi
    python -m src.transactions   # Konstruksi Author-Based & Author-Year-Based DB
    python -m src.mining         # Eksperimen Apriori & FP-Growth + ARM + Benchmark
    python -m src.temporal       # Analisis Asosiasi Temporal 4 periode
    PYTHONPATH=. python tests/test_pipeline.py
    ```,
    caption: [Urutan perintah reproduksi penuh pipeline data dan eksperimen mining.],
  ) <kode-reproduksi>

  Adapun struktur artefak utama yang dihasilkan meliputi:
  - *Notebooks ter-eksekusi*: `01_eda_popularity.ipynb`, `02_transactional_db.ipynb`, `03_fpm_arm_comparison.ipynb`, dan `04_temporal_analysis.ipynb`.
  - *Tabel Eksperimen (`tables/*.csv`)*: `33` berkas CSV terstruktur yang menyimpan seluruh rincian data _preprocessing_, popularitas, sampel dan distribusi transaksi, seluruh _frequent itemsets_ dan _association rules_ per *threshold*, benchmark Apriori vs FP-Growth, serta evolusi aturan temporal.
  - *Visualisasi (`outputs/figures/*.png` & `.pdf`)*: seluruh grafik beresolusi 300 DPI dan vektor PDF.
]
