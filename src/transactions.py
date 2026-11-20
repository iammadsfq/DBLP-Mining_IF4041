"""Task 3: Transactional Database Construction (Author-Based & Author-Year-Based)."""

import argparse
import os
import numpy as np
import pandas as pd


def build_author_transactions(df_clean: pd.DataFrame) -> pd.DataFrame:
    """Build Author-Based transactional database: 1 row = 1 author, items = unique sorted venues."""
    exploded = df_clean[["authors", "venue"]].explode("authors").rename(columns={"authors": "author"})
    exploded = exploded.drop_duplicates(subset=["author", "venue"])
    tx = (
        exploded.groupby("author", sort=False)["venue"]
        .agg(lambda s: sorted(s.tolist()))
        .reset_index()
        .rename(columns={"venue": "venues"})
    )
    tx["n_items"] = tx["venues"].map(len).astype("int32")
    return tx


def build_author_year_transactions(df_clean: pd.DataFrame) -> pd.DataFrame:
    """Build Author-Year-Based transactional database: 1 row = (author, year), items = unique sorted venues."""
    exploded = df_clean[["authors", "year", "venue"]].explode("authors").rename(columns={"authors": "author"})
    exploded = exploded.drop_duplicates(subset=["author", "year", "venue"])
    tx = (
        exploded.groupby(["author", "year"], sort=False)["venue"]
        .agg(lambda s: sorted(s.tolist()))
        .reset_index()
        .rename(columns={"venue": "venues"})
    )
    tx["year"] = tx["year"].astype("int32")
    tx["n_items"] = tx["venues"].map(len).astype("int32")
    return tx


def summarize_transactions(tx_df: pd.DataFrame, name: str) -> dict:
    """Compute summary statistics for a transactional database."""
    n_tx = len(tx_df)
    unique_items = int(tx_df["venues"].explode().nunique())
    n_items = tx_df["n_items"]
    multi_item_count = int((n_items >= 2).sum())
    return {
        "representation": name,
        "num_transactions": int(n_tx),
        "num_unique_items": unique_items,
        "total_item_occurrences": int(n_items.sum()),
        "single_item_tx": int((n_items == 1).sum()),
        "single_item_pct": round(float((n_items == 1).mean() * 100), 2),
        "multi_item_tx": multi_item_count,
        "multi_item_pct": round(float((n_items >= 2).mean() * 100), 2),
        "mean_items_per_tx": round(float(n_items.mean()), 4),
        "std_items_per_tx": round(float(n_items.std()), 4),
        "min_items": int(n_items.min()),
        "median_items": float(n_items.median()),
        "p90_items": float(np.percentile(n_items, 90)),
        "p95_items": float(np.percentile(n_items, 95)),
        "p99_items": float(np.percentile(n_items, 99)),
        "max_items": int(n_items.max()),
    }


def build_length_distribution(tx_df: pd.DataFrame, name: str, cap: int = 10) -> pd.DataFrame:
    """Compute distribution of transaction lengths (1, 2, ..., cap, >cap)."""
    n_items = tx_df["n_items"]
    buckets = n_items.where(n_items <= cap, cap + 1)
    counts = buckets.value_counts().sort_index()
    total = len(tx_df)
    rows = []
    for k in range(1, cap + 2):
        cnt = int(counts.get(k, 0))
        label = str(k) if k <= cap else f">{cap}"
        rows.append({
            "representation": name,
            "item_count_bucket": label,
            "bucket_order": k,
            "transactions": cnt,
            "percentage": round(cnt / total * 100, 4),
        })
    return pd.DataFrame(rows)


def sample_transactions(tx_df: pd.DataFrame, n_samples: int = 15, seed: int = 42) -> pd.DataFrame:
    """Return a reproducible sample of multi-item transactions (plus 2 single-item) for inspection."""
    multi = tx_df[tx_df["n_items"] >= 2]
    single = tx_df[tx_df["n_items"] == 1]
    s_multi = multi.sample(n=min(n_samples - 2, len(multi)), random_state=seed)
    s_single = single.sample(n=min(2, len(single)), random_state=seed)
    out = pd.concat([s_multi, s_single], ignore_index=True).sort_values("n_items", ascending=False).reset_index(drop=True)
    out["venues_str"] = out["venues"].map(lambda v: ", ".join(v))
    cols = [c for c in out.columns if c != "venues"]
    return out[cols]


def main() -> None:
    parser = argparse.ArgumentParser(description="Build Author-Based and Author-Year-Based transactional databases.")
    parser.add_argument("--input", default="data/processed/dblp_2015_2025_clean.parquet")
    parser.add_argument("--author-out", default="data/processed/tx_author_based.parquet")
    parser.add_argument("--author-year-out", default="data/processed/tx_author_year_based.parquet")
    parser.add_argument("--tables-dir", default="tables")
    args = parser.parse_args()

    os.makedirs(os.path.dirname(os.path.abspath(args.author_out)), exist_ok=True)
    os.makedirs(args.tables_dir, exist_ok=True)

    print(f"Loading cleaned dataset from {args.input}...")
    df_clean = pd.read_parquet(args.input)

    print("Building Author-Based Transactional Database...")
    tx_author = build_author_transactions(df_clean)
    tx_author.to_parquet(args.author_out, index=False)
    print(f"Saved {len(tx_author):,} Author-Based transactions to {args.author_out}")

    print("Building Author-Year-Based Transactional Database...")
    tx_author_year = build_author_year_transactions(df_clean)
    tx_author_year.to_parquet(args.author_year_out, index=False)
    print(f"Saved {len(tx_author_year):,} Author-Year-Based transactions to {args.author_year_out}")

    summary_df = pd.DataFrame([
        summarize_transactions(tx_author, "Author-Based"),
        summarize_transactions(tx_author_year, "Author-Year-Based"),
    ])
    summary_path = os.path.join(args.tables_dir, "task3_transaction_summary.csv")
    summary_df.to_csv(summary_path, index=False)

    dist_df = pd.concat([
        build_length_distribution(tx_author, "Author-Based"),
        build_length_distribution(tx_author_year, "Author-Year-Based"),
    ], ignore_index=True)
    dist_path = os.path.join(args.tables_dir, "task3_item_count_distribution.csv")
    dist_df.to_csv(dist_path, index=False)

    sample_author = sample_transactions(tx_author, n_samples=15)
    sample_author.to_csv(os.path.join(args.tables_dir, "task3_sample_author_tx.csv"), index=False)

    sample_ay = sample_transactions(tx_author_year, n_samples=15)
    sample_ay.to_csv(os.path.join(args.tables_dir, "task3_sample_author_year_tx.csv"), index=False)

    print("\n=== Task 3 Transaction Summary ===")
    print(summary_df.to_string(index=False))


if __name__ == "__main__":
    main()
