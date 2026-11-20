#import "@preview/touying:0.6.1": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  primary: rgb("#0F4D92"),
  footer: [IF4041 Penambangan Data — DBLP Conference Popularity & Association Pattern Mining (2015–2025)],
)

#set text(font: ("Helvetica Neue", "Arial"), size: 17pt, lang: "id")
#show table: set text(size: 13pt)
#set table(
  stroke: (x, y) => (
    top: if y == 0 { 1.2pt + rgb("#0F4D92") } else if y == 1 { 0.8pt + rgb("#0F4D92") } else { 0.3pt + luma(210) },
    bottom: 0.5pt + luma(190),
    left: none,
    right: none,
  ),
  fill: (x, y) => if y == 0 { rgb("#EAF1F8") } else if calc.odd(y) { white } else { rgb("#F8FAFC") },
  inset: (x: 8pt, y: 5pt),
)

// ===================== SLIDE 1: TITLE =====================
#title-slide[
  #v(0.8cm)
  #text(size: 14pt, weight: "bold", fill: rgb("#0F4D92"), tracking: 1.5pt)[PROJECT DATA MINING — IF4041]
  #v(0.4cm)
  #text(size: 28pt, weight: "bold", fill: rgb("#102A43"))[
    Conference Popularity & Association Pattern Mining Using DBLP Dataset
  ]
  #v(0.4cm)
  #text(size: 16pt, fill: luma(80))[
    Frequent Pattern Mining (Apriori & FP-Growth), Association Rule Mining, dan Analisis Temporal (2015–2025)
  ]
  #v(1.2cm)
  #line(length: 55%, stroke: 1.5pt + rgb("#0F4D92"))
  #v(0.6cm)
  #text(size: 14pt)[
    *Kelompok*: _[Nama Anggota 1, Anggota 2, Anggota 3]_ \
    *Dataset*: DBLP XML Dump (2.000.757 publikasi konferensi & workshop, 2015–2025)
  ]
]

// ===================== SLIDE 2: OVERVIEW & METODOLOGI =====================
== Metodologi & Pipeline End-to-End

#grid(
  columns: (1.1fr, 1fr),
  column-gutter: 20pt,
  [
    *Tahapan Pipeline Reproducible (`src/`)*:
    1. *Ekstraksi XML* (`src/parser.py`): Streaming `lxml.iterparse` pada *13,13 juta* entri DBLP → *2.004.202* `<inproceedings>` (2015–2025).
    2. *Preprocessing* (`src/preprocessing.py`): Validasi tahun, hapus missing values (`-2.445`), normalisasi author (Unicode NFC + pertahankan `0001`), normalisasi venue (`NIPS` → `NeurIPS`, canonical casing), deduplikasi (`-1.000`).
    3. *Transactional DB* (`src/transactions.py`):
       - *Author-Based*: 1.822.489 transaksi (42,58% multi-item)
       - *Author-Year-Based*: 4.088.557 transaksi (29,72% multi-item)
    4. *FPM & ARM* (`src/mining.py`): Apriori vs FP-Growth pada matriks *sparse* (*exact lossless pruning*), `min_sup` $in {0.1%, 0.5%, 1%, 2%}$, `min_conf = 50%`.
    5. *Temporal Analysis* (`src/temporal.py`): Evolusi rules pada 4 periode (`2015–2017` s.d. `2024–2025`).
  ],
  [
    #align(center)[
      #image("../outputs/figures/01_xml_publication_types.png", width: 100%)
      #v(0.2cm)
      #text(size: 12pt, fill: luma(90))[
        Dataset Bersih: *2.000.757* paper | *1.822.489* author unik | *8.780* venue unik
      ]
    ]
  ],
)

// ===================== SLIDE 3: POPULARITY (TASK 2) =====================
== Task 2 — Conference Popularity Analysis

#grid(
  columns: (1.15fr, 1fr),
  column-gutter: 16pt,
  [
    #image("../outputs/figures/02_top10_pub_vs_unique_authors.png", width: 100%)
  ],
  [
    *Temuan Kunci*:
    - *#1 Publikasi & Author Unik*: *NeurIPS* (25.004 paper; 56.073 author unik).
    - *Pergeseran Ranking*: *AAAI* (#4 publikasi → #2 author unik) & *EMBC* (#6 → #4) memiliki tim penulis lebih besar.
    - *CDC* (#10 publikasi → #35 author unik; 1,23 author/paper) menandakan komunitas kecil yang sangat loyal.
  ],
)

// ===================== SLIDE 4: TREN 2015-2025 =====================
== Task 2 — Tren Publikasi Konferensi (2015–2025)

#align(center)[
  #image("../outputs/figures/02_top10_conferences_trend.png", width: 78%)
]
#v(0.1cm)
#text(size: 14pt)[
  *Insight*: Konferensi AI/ML & Vision (*NeurIPS*, *AAAI*, *CVPR*, *ICML*) melonjak eksponensial sejak 2018, melampaui konferensi teknik klasik (*ICASSP*, *IGARSS*, *CDC*).
]

// ===================== SLIDE 5: TRANSACTIONAL DB (TASK 3) =====================
== Task 3 — Author-Based vs Author-Year-Based

#grid(
  columns: (1.2fr, 1fr),
  column-gutter: 16pt,
  [
    #image("../outputs/figures/03_tx_length_distribution.png", width: 100%)
  ],
  [
    #table(
      columns: (1.2fr, auto, auto),
      align: (left, right, right),
      [*Metrik*], [*Author*], [*Author-Year*],
      [Transaksi], [1,82M], [4,09M],
      [Item Unik], [8.780], [8.780],
      [Multi-Item], [42,58%], [29,72%],
      [Mean Items], [2,86], [1,63],
      [Max Items], [396], [88],
    )
    #v(0.2cm)
    #text(size: 13.5pt)[
      - *Author-Based*: menangkap pola lintas-tahun (termasuk biennial *ICCV–ECCV*), tanpa dimensi waktu.
      - *Author-Year*: lebih *sparse* (70,3% single-item), namun memungkinkan pelacakan tren temporal.
    ]
  ],
)

// ===================== SLIDE 6: FREQUENT PATTERN MINING (TASK 4) =====================
== Task 4 — Frequent Pattern Mining (`0.1%` s.d. `2%`)

#align(center)[
  #image("../outputs/figures/04_fpm_itemsets_analysis.png", width: 88%)
]
#text(size: 13.5pt)[
  *Kombinasi Teratas (`0.1%`)*: 2-itemset #1 `{ICML, NeurIPS}` (1,00% / 18.239 author), `{ICLR, NeurIPS}` (0,93%), `{CVPR, ICCV}` (0,75%), `{ICRA, IROS}` (0,65%) | 3-itemset #1 `{ICLR, ICML, NeurIPS}` (0,54% / 9.924 author).
]

// ===================== SLIDE 7: ASSOCIATION RULES (TASK 5) =====================
== Task 5 — Association Rule Mining (`min_conf = 50%`)

#grid(
  columns: (1.15fr, 1fr),
  column-gutter: 14pt,
  [
    #image("../outputs/figures/05_association_rules_analysis.png", width: 100%)
  ],
  [
    *Highlight Rules (`min_sup = 0.1%`, 730 rules)*:
    - *Lift Tertinggi*: `ACM Multimedia, CVPR, NeurIPS -> AAAI, ICCV` (*Lift 122,68×*, Conf 55,33%, Sup 0,13%).
    - *Support Tertinggi*: `ICML -> NeurIPS` (Sup 1,00%, Conf 58,09%, *Lift 18,88×*).
    - *Confidence Sangat Tinggi*: `ICLR, ICML -> NeurIPS` (*Conf 80,78%*, Lift 26,26×).
    - *Kesimpulan*: Support tinggi *tidak* menjamin lift tinggi karena penyebut $P(B)$ yang besar.
  ],
)

// ===================== SLIDE 8: ALGORITHM COMPARISON (TASK 6) =====================
== Task 6 — Perbandingan Apriori vs FP-Growth

#grid(
  columns: (1.15fr, 1fr),
  column-gutter: 14pt,
  [
    #image("../outputs/figures/06_algorithm_performance_comparison.png", width: 100%)
  ],
  [
    #table(
      columns: (auto, auto, auto, auto),
      align: (center, right, right, right),
      [*Sup*], [*Itemsets*], [*Ap/FP (s)*], [*Ap/FP (MB)*],
      [0,1%], [1.197], [21,3 / 77,9], [1.893 / 952],
      [0,5%], [75], [1,0 / 53,6], [240 / 126],
      [1,0%], [25], [0,4 / 57,8], [100 / 55],
      [2,0%], [4], [0,1 / 50,6], [31 / 18],
    )
    #v(0.15cm)
    #text(size: 13pt)[
      - Output *100% identik* di semua threshold.
      - *FP-Growth*: ~50% lebih hemat RAM & tahan ledakan kandidat.
      - *Apriori sparse (`mlxtend`)*: lebih cepat di 0,1%–2% berkat vektorisasi SciPy/NumPy.
    ]
  ],
)

// ===================== SLIDE 9: TEMPORAL ANALYSIS (BAGIAN E) =====================
== Bagian E — Temporal Association Analysis (2015–2025)

#grid(
  columns: (1fr, 1.05fr),
  column-gutter: 14pt,
  [
    #image("../outputs/figures/07_temporal_counts.png", width: 100%)
    #v(0.1cm)
    #text(size: 13pt)[
      - *2015–2017*: Hanya `ECOC -> OFC` (optik, lift 59,8×).
      - *2021–2025*: Lonjakan drastis rules (`2 -> 37` di 0,1%; `15 -> 212` di 0,05%) akibat boom LLM, Multimodal AI, & Vision.
    ]
  ],
  [
    #image("../outputs/figures/08_temporal_rules_heatmap.png", width: 100%)
  ],
)

// ===================== SLIDE 10: KEY FINDINGS & KESIMPULAN =====================
== Kesimpulan & Key Findings (Bagian H)

1. *Konferensi Paling Populer*: *NeurIPS* (#1 publikasi: 25.004; #1 author unik: 56.073), diikuti ICASSP/IGARSS (volume) & AAAI/EMBC (partisipasi author).
2. *Support vs Lift*: Konferensi paling populer (`NeurIPS`) mendominasi *support* (`ICML -> NeurIPS`: 1,00%), tetapi *lift* tertinggi dicapai klaster lintas-konferensi spesifik (`ACM Multimedia, CVPR, NeurIPS -> AAAI, ICCV`: *122,68×*).
3. *Klaster Riset Terkuat*: Machine Learning (`{ICLR, ICML, NeurIPS}`), Computer Vision (`{CVPR, ICCV}`), Robotics (`{ICRA, IROS}`), dan NLP (`ACL`/`EMNLP` + `Findings`).
4. *Author-Based vs Author-Year-Based*: *Author-Based* optimal untuk peta komunitas jangka panjang (730 rules); *Author-Year-Based* mengungkap pergeseran historis dari dominasi optik (2015–2017) menuju ledakan multi-konferensi AI/NLP (2024–2025).
5. *Algoritma*: Apriori & FP-Growth menghasilkan output *100% identik*; *FP-Growth* unggul mutlak pada efisiensi memori (~2× lebih hemat) untuk skala dataset besar DBLP.
