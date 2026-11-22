"""Generate crisp single-panel publication figures for slides and fix minor label/title spacing."""

import os
import sys
sys.path.insert(0, ".")

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

from src.plotting import PALETTE, apply_publication_style, clean_axes, save_figure


def main():
    apply_publication_style(base_font_size=12, axes_linewidth=2.2)

    # 1. Task 2.1: Dedicated Top 10 Publications bar chart
    top10_pub = pd.read_csv("tables/top10_conferences_by_publications.csv")
    fig, ax = plt.subplots(figsize=(8.8, 4.8))
    d = top10_pub.iloc[::-1]
    colors = [PALETTE["blue_main"] if v == "NeurIPS" else PALETTE["blue_secondary"] for v in d["venue"]]
    bars = ax.barh(d["venue"], d["publications"], color=colors, edgecolor="black", linewidth=1.3)
    for bar in bars:
        w = bar.get_width()
        ax.text(w + 350, bar.get_y() + bar.get_height() / 2, f"{int(w):,}", va="center", fontsize=10.5, fontweight="bold")
    ax.set_title("Top 10 Konferensi Berdasarkan Jumlah Publikasi (2015–2025)")
    ax.set_xlabel("Jumlah Publikasi")
    ax.set_xlim(0, top10_pub["publications"].max() * 1.18)
    clean_axes(ax, grid_axis="x")
    save_figure(fig, "outputs/figures/02a_top10_publications")
    plt.close(fig)

    # 2. Task 2.2: Dedicated Top 10 Unique Authors bar chart
    top10_auth = pd.read_csv("tables/top10_conferences_by_unique_authors.csv")
    fig, ax = plt.subplots(figsize=(8.8, 4.8))
    d = top10_auth.iloc[::-1]
    colors = [PALETTE["blue_main"] if v == "NeurIPS" else PALETTE["violet"] for v in d["venue"]]
    bars = ax.barh(d["venue"], d["unique_authors"], color=colors, edgecolor="black", linewidth=1.3)
    for bar in bars:
        w = bar.get_width()
        ax.text(w + 750, bar.get_y() + bar.get_height() / 2, f"{int(w):,}", va="center", fontsize=10.5, fontweight="bold")
    ax.set_title("Top 10 Konferensi Berdasarkan Jumlah Author Unik (2015–2025)")
    ax.set_xlabel("Jumlah Author Unik")
    ax.set_xlim(0, top10_auth["unique_authors"].max() * 1.18)
    clean_axes(ax, grid_axis="x")
    save_figure(fig, "outputs/figures/02b_top10_unique_authors")
    plt.close(fig)

    # 3. Task 4.2 / 4.4: Dedicated Itemset Counts by Size vs Min Support
    size_df = pd.read_csv("tables/task4_itemset_counts_by_size.csv")
    fig, ax = plt.subplots(figsize=(8.6, 4.8))
    labels = size_df["min_support_pct"].tolist()
    x = np.arange(len(labels))
    w = 0.25
    ax.bar(x - w, size_df["n_1_itemsets"], w, label="1-itemsets", color=PALETTE["blue_main"], edgecolor="black", linewidth=1.2)
    ax.bar(x, size_df["n_2_itemsets"], w, label="2-itemsets", color=PALETTE["teal"], edgecolor="black", linewidth=1.2, hatch="//")
    ax.bar(x + w, size_df["n_3_itemsets"], w, label="3-itemsets", color=PALETTE["green_3"], edgecolor="black", linewidth=1.2, hatch="..")
    for i, row in size_df.iterrows():
        ax.text(i - w, row["n_1_itemsets"] + 8, str(row["n_1_itemsets"]), ha="center", va="bottom", fontsize=10, fontweight="bold")
        ax.text(i, row["n_2_itemsets"] + 8, str(row["n_2_itemsets"]), ha="center", va="bottom", fontsize=10, fontweight="bold")
        ax.text(i + w, row["n_3_itemsets"] + 8, str(row["n_3_itemsets"]), ha="center", va="bottom", fontsize=10, fontweight="bold")
    ax.set_title("Jumlah Frequent Itemsets per Ukuran vs Minimum Support")
    ax.set_xlabel("Minimum Support")
    ax.set_ylabel("Jumlah Frequent Itemsets")
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.set_ylim(0, size_df["n_1_itemsets"].max() * 1.13)
    ax.legend(loc="upper right")
    clean_axes(ax, grid_axis="y")
    save_figure(fig, "outputs/figures/04a_itemsets_by_size")
    plt.close(fig)

    # 4. Task 4.5a: Top 12 2-Itemsets
    is_01 = pd.read_csv("tables/task4_frequent_itemsets_01pct.csv")
    fig, ax = plt.subplots(figsize=(8.8, 4.9))
    top_pairs = is_01[is_01["length"] == 2].head(12).iloc[::-1]
    bars = ax.barh(top_pairs["itemset"], top_pairs["support_pct"], color=PALETTE["blue_secondary"], edgecolor="black", linewidth=1.2)
    for bar in bars:
        val = bar.get_width()
        ax.text(val + 0.015, bar.get_y() + bar.get_height() / 2, f"{val:.2f}%", va="center", fontsize=10, fontweight="bold")
    ax.set_title("Top 12 Kombinasi 2-Konferensi Paling Sering Muncul (min_sup = 0.1%)")
    ax.set_xlabel("Support (%)")
    ax.set_xlim(0, top_pairs["support_pct"].max() * 1.18)
    clean_axes(ax, grid_axis="x")
    save_figure(fig, "outputs/figures/04b_top_cooccurring_2itemsets")
    plt.close(fig)

    # 5. Task 4.5b: Top 10 3-Itemsets
    fig, ax = plt.subplots(figsize=(8.8, 4.6))
    top_trios = is_01[is_01["length"] == 3].head(10).iloc[::-1]
    bars = ax.barh(top_trios["itemset"], top_trios["support_pct"], color=PALETTE["teal"], edgecolor="black", linewidth=1.2, hatch="//")
    for bar in bars:
        val = bar.get_width()
        ax.text(val + 0.008, bar.get_y() + bar.get_height() / 2, f"{val:.2f}%", va="center", fontsize=10, fontweight="bold")
    ax.set_title("Top 10 Kombinasi 3-Konferensi Paling Sering Muncul (min_sup = 0.1%)")
    ax.set_xlabel("Support (%)")
    ax.set_xlim(0, top_trios["support_pct"].max() * 1.18)
    clean_axes(ax, grid_axis="x")
    save_figure(fig, "outputs/figures/04c_top_cooccurring_3itemsets")
    plt.close(fig)

    # 6. Task 5a: Scatter Support vs Confidence (colored by Lift)
    rules_01 = pd.read_csv("tables/task5_association_rules_01pct.csv")
    fig, ax = plt.subplots(figsize=(8.2, 5.0))
    sc = ax.scatter(
        rules_01["support_pct"],
        rules_01["confidence_pct"],
        c=rules_01["lift"],
        cmap="viridis",
        s=60,
        alpha=0.85,
        edgecolors="black",
        linewidths=0.6,
    )
    cbar = fig.colorbar(sc, ax=ax)
    cbar.set_label("Lift", fontweight="bold")
    ax.set_title("Sebaran 730 Association Rules: Support vs Confidence")
    ax.set_xlabel("Support (%)")
    ax.set_ylabel("Confidence (%)")
    clean_axes(ax, grid_axis="both")
    save_figure(fig, "outputs/figures/05a_rules_scatter")
    plt.close(fig)

    # 7. Task 5b: Top 10 Rules by Lift
    top10_rules = pd.read_csv("tables/task5_top10_rules_by_lift.csv")
    fig, ax = plt.subplots(figsize=(9.5, 4.9))
    t10 = top10_rules.iloc[::-1]
    bars = ax.barh(t10["rule"], t10["lift"], color=PALETTE["violet"], edgecolor="black", linewidth=1.2)
    for bar in bars:
        val = bar.get_width()
        ax.text(val + 1.8, bar.get_y() + bar.get_height() / 2, f"{val:.1f}x", va="center", fontsize=10, fontweight="bold")
    ax.set_title("Top 10 Association Rules dengan Lift Tertinggi (min_sup = 0.1%)")
    ax.set_xlabel("Lift")
    ax.set_xlim(0, t10["lift"].max() * 1.15)
    clean_axes(ax, grid_axis="x")
    save_figure(fig, "outputs/figures/05b_top10_rules_lift")
    plt.close(fig)

    # 8. Fix heatmap title wrap in 08_temporal_rules_heatmap so it never clips
    evo_005 = pd.read_csv("tables/temporal_rule_evolution_005pct.csv")
    top_evo = evo_005.head(15).copy()
    lift_cols = ["lift_2015-2017", "lift_2018-2020", "lift_2021-2023", "lift_2024-2025"]
    heat_df = top_evo.set_index("rule")[lift_cols]
    heat_df.columns = ["2015–2017", "2018–2020", "2021–2023", "2024–2025"]
    fig, ax = plt.subplots(figsize=(10.5, max(5.2, 0.44 * len(heat_df) + 1.5)))
    sns.heatmap(
        heat_df,
        annot=True,
        fmt=".1f",
        cmap="YlGnBu",
        linewidths=0.6,
        linecolor="white",
        cbar_kws={"label": "Lift"},
        ax=ax,
    )
    ax.set_title("Evolusi Nilai Lift Top 15 Association Rules Antarperiode\n(min_support = 0.05%, min_confidence = 50%)", pad=12)
    ax.set_xlabel("Periode")
    ax.set_ylabel("Association Rule")
    save_figure(fig, "outputs/figures/08_temporal_rules_heatmap")
    plt.close(fig)

    print("Generated all dedicated slide figures successfully.")


if __name__ == "__main__":
    main()
