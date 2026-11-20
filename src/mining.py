"""Task 4, 5, 6: Frequent Pattern Mining (Apriori & FP-Growth), Association Rules & Performance Comparison."""

import argparse
import gc
import math
import os
import time
import tracemalloc
from collections import Counter

import numpy as np
import pandas as pd
from scipy.sparse import csr_matrix
from mlxtend.frequent_patterns import apriori, fpgrowth, association_rules

MIN_SUPPORTS = [0.001, 0.005, 0.01, 0.02]
MIN_CONFIDENCE = 0.50


def format_itemset(iset) -> str:
    """Format a frozenset of venues as a deterministic sorted comma-separated string."""
    return ", ".join(sorted(iset))


def encode_transactions_pruned(venues_iterable, min_support: float) -> tuple[pd.DataFrame, int, int]:
    """Build an exact sparse boolean DataFrame retaining all N rows and only items with count >= ceil(min_support * N).

    Because of downward closure (Apriori property), pruning columns below min_support while keeping
    the full row count N produces 100% mathematically identical frequent itemsets and support values.
    """
    transactions = list(venues_iterable)
    n_tx = len(transactions)
    min_count = math.ceil(min_support * n_tx)

    item_counts: Counter = Counter()
    for tx in transactions:
        item_counts.update(tx)

    kept_items = sorted(item for item, cnt in item_counts.items() if cnt >= min_count)
    item_to_col = {item: idx for idx, item in enumerate(kept_items)}

    if not kept_items:
        empty_df = pd.DataFrame(index=range(n_tx))
        return empty_df, n_tx, 0

    indptr = [0]
    indices = []
    for tx in transactions:
        cols = [item_to_col[item] for item in tx if item in item_to_col]
        if cols:
            cols.sort()
            indices.extend(cols)
        indptr.append(len(indices))

    data = np.ones(len(indices), dtype=bool)
    mat = csr_matrix(
        (data, np.asarray(indices, dtype=np.int32), np.asarray(indptr, dtype=np.int32)),
        shape=(n_tx, len(kept_items)),
        dtype=bool,
    )
    sparse_df = pd.DataFrame.sparse.from_spmatrix(mat, columns=kept_items)
    return sparse_df, n_tx, len(kept_items)


def _run_with_metrics(fn, *args, **kwargs):
    """Run a mining function while measuring wall-clock time (s) and peak traced Python memory (MB)."""
    gc.collect()
    tracemalloc.start()
    t0 = time.perf_counter()
    result = fn(*args, **kwargs)
    elapsed = time.perf_counter() - t0
    _, peak_bytes = tracemalloc.get_traced_memory()
    tracemalloc.stop()
    return result, elapsed, peak_bytes / (1024 * 1024)


def verify_identical_itemsets(df_a: pd.DataFrame, df_b: pd.DataFrame, tol: float = 1e-12) -> bool:
    """Verify two frequent itemset DataFrames contain identical itemsets and supports within tol."""
    if len(df_a) != len(df_b):
        return False
    if len(df_a) == 0:
        return True
    map_a = {frozenset(row.itemsets): float(row.support) for row in df_a.itertuples(index=False)}
    map_b = {frozenset(row.itemsets): float(row.support) for row in df_b.itertuples(index=False)}
    if map_a.keys() != map_b.keys():
        return False
    return all(abs(map_a[k] - map_b[k]) <= tol for k in map_a)


def generate_rules_safe(itemsets_df: pd.DataFrame, min_confidence: float = MIN_CONFIDENCE) -> pd.DataFrame:
    """Generate association rules safely, returning an empty DataFrame if no multi-itemsets exist."""
    if itemsets_df.empty:
        return pd.DataFrame(columns=["antecedents", "consequents", "antecedent support", "consequent support", "support", "confidence", "lift"])
    max_len = int(itemsets_df["itemsets"].map(len).max())
    if max_len < 2:
        return pd.DataFrame(columns=["antecedents", "consequents", "antecedent support", "consequent support", "support", "confidence", "lift"])
    rules = association_rules(itemsets_df, metric="confidence", min_threshold=min_confidence)
    if rules.empty:
        return rules
    rules = rules.sort_values(["lift", "confidence", "support"], ascending=False).reset_index(drop=True)
    return rules


def format_itemsets_table(itemsets_df: pd.DataFrame, n_tx: int, min_support: float) -> pd.DataFrame:
    """Convert mlxtend frequent itemsets DataFrame into a clean exportable table."""
    if itemsets_df.empty:
        return pd.DataFrame(columns=["min_support", "itemset", "length", "support", "support_pct", "tx_count"])
    out = itemsets_df.copy()
    out["min_support"] = min_support
    out["itemset"] = out["itemsets"].map(format_itemset)
    out["length"] = out["itemsets"].map(len).astype(int)
    out["support_pct"] = (out["support"] * 100).round(4)
    out["tx_count"] = (out["support"] * n_tx).round().astype(int)
    out = out[["min_support", "itemset", "length", "support", "support_pct", "tx_count"]]
    return out.sort_values(["support", "length", "itemset"], ascending=[False, True, True]).reset_index(drop=True)


def format_rules_table(rules_df: pd.DataFrame, n_tx: int, min_support: float) -> pd.DataFrame:
    """Convert mlxtend association rules DataFrame into a clean exportable table."""
    cols = [
        "min_support", "antecedents", "consequents", "rule",
        "antecedent_len", "consequent_len",
        "antecedent_support", "consequent_support",
        "support", "support_pct", "tx_count", "confidence", "confidence_pct", "lift",
    ]
    if rules_df.empty:
        return pd.DataFrame(columns=cols)
    out = pd.DataFrame()
    out["min_support"] = [min_support] * len(rules_df)
    out["antecedents"] = rules_df["antecedents"].map(format_itemset)
    out["consequents"] = rules_df["consequents"].map(format_itemset)
    out["rule"] = out["antecedents"] + " -> " + out["consequents"]
    out["antecedent_len"] = rules_df["antecedents"].map(len).astype(int)
    out["consequent_len"] = rules_df["consequents"].map(len).astype(int)
    out["antecedent_support"] = rules_df["antecedent support"].round(6)
    out["consequent_support"] = rules_df["consequent support"].round(6)
    out["support"] = rules_df["support"].round(6)
    out["support_pct"] = (rules_df["support"] * 100).round(4)
    out["tx_count"] = (rules_df["support"] * n_tx).round().astype(int)
    out["confidence"] = rules_df["confidence"].round(6)
    out["confidence_pct"] = (rules_df["confidence"] * 100).round(2)
    out["lift"] = rules_df["lift"].round(4)
    return out.sort_values(["lift", "confidence", "support"], ascending=False).reset_index(drop=True)


def support_tag(min_sup: float) -> str:
    """Map float support (e.g. 0.001) to filename-safe tag (e.g. '01pct')."""
    pct = min_sup * 100
    if pct == int(pct):
        return f"{int(pct)}pct"
    return f"{str(pct).replace('.', '')}pct"


def run_all_experiments(
    tx_path: str = "data/processed/tx_author_based.parquet",
    tables_dir: str = "tables",
    min_supports: list[float] | None = None,
    min_confidence: float = MIN_CONFIDENCE,
) -> dict:
    """Execute Task 4, Task 5, and Task 6 across all min_support thresholds."""
    if min_supports is None:
        min_supports = MIN_SUPPORTS
    os.makedirs(tables_dir, exist_ok=True)

    print(f"Loading Author-Based transactions from {tx_path}...")
    tx_df = pd.read_parquet(tx_path)
    venues_list = tx_df["venues"].tolist()
    n_tx = len(venues_list)
    print(f"Loaded {n_tx:,} transactions.")

    comparison_rows = []
    size_rows = []
    top10_itemsets_all = []
    all_rules_by_sup = {}

    for ms in min_supports:
        tag = support_tag(ms)
        print(f"\n--- Running min_support = {ms * 100:.1f}% ({ms}) ---")
        sparse_df, _, n_kept = encode_transactions_pruned(venues_list, ms)
        print(f"Sparse matrix shape: ({n_tx:,}, {n_kept:,}) [lossless pruned for min_sup={ms}]")

        if n_kept == 0:
            ap_is = pd.DataFrame(columns=["support", "itemsets"])
            fp_is = pd.DataFrame(columns=["support", "itemsets"])
            ap_time = fp_time = ap_mem = fp_mem = 0.0
        else:
            ap_is, ap_time, ap_mem = _run_with_metrics(
                apriori, sparse_df, min_support=ms, use_colnames=True, low_memory=True
            )
            fp_is, fp_time, fp_mem = _run_with_metrics(
                fpgrowth, sparse_df, min_support=ms, use_colnames=True
            )

        identical = verify_identical_itemsets(ap_is, fp_is)
        if not identical:
            raise AssertionError(f"Mismatch between Apriori and FP-Growth at min_support={ms}!")

        ap_rules = generate_rules_safe(ap_is, min_confidence=min_confidence)
        fp_rules = generate_rules_safe(fp_is, min_confidence=min_confidence)

        itemsets_tbl = format_itemsets_table(fp_is, n_tx, ms)
        rules_tbl = format_rules_table(fp_rules, n_tx, ms)
        all_rules_by_sup[ms] = rules_tbl

        itemsets_tbl.to_csv(os.path.join(tables_dir, f"task4_frequent_itemsets_{tag}.csv"), index=False)
        rules_tbl.to_csv(os.path.join(tables_dir, f"task5_association_rules_{tag}.csv"), index=False)

        top10_itemsets_all.append(itemsets_tbl.head(10))

        len_counts = itemsets_tbl["length"].value_counts().to_dict() if not itemsets_tbl.empty else {}
        size_rows.append({
            "min_support": ms,
            "min_support_pct": f"{ms * 100:.1f}%",
            "n_1_itemsets": int(len_counts.get(1, 0)),
            "n_2_itemsets": int(len_counts.get(2, 0)),
            "n_3_itemsets": int(len_counts.get(3, 0)),
            "n_4plus_itemsets": int(sum(v for k, v in len_counts.items() if k >= 4)),
            "total_itemsets": int(len(itemsets_tbl)),
            "total_rules_conf50": int(len(rules_tbl)),
        })

        comparison_rows.append({
            "min_support": ms,
            "min_support_pct": f"{ms * 100:.1f}%",
            "candidate_items_ge_minsup": n_kept,
            "apriori_itemsets": int(len(ap_is)),
            "fpgrowth_itemsets": int(len(fp_is)),
            "itemsets_identical": identical,
            "apriori_rules": int(len(ap_rules)),
            "fpgrowth_rules": int(len(fp_rules)),
            "apriori_time_s": round(ap_time, 4),
            "fpgrowth_time_s": round(fp_time, 4),
            "speedup_fpgrowth_vs_apriori": round(ap_time / fp_time, 2) if fp_time > 0 else np.nan,
            "apriori_peak_mb": round(ap_mem, 2),
            "fpgrowth_peak_mb": round(fp_mem, 2),
        })

        print(
            f"Itemsets={len(fp_is):,} (1:{len_counts.get(1,0)}, 2:{len_counts.get(2,0)}, 3:{len_counts.get(3,0)}) | "
            f"Rules(conf>=50%)={len(rules_tbl):,} | "
            f"Apriori={ap_time:.2f}s ({ap_mem:.1f}MB) | FP-Growth={fp_time:.2f}s ({fp_mem:.1f}MB) | Identical={identical}"
        )

    size_df = pd.DataFrame(size_rows)
    size_df.to_csv(os.path.join(tables_dir, "task4_itemset_counts_by_size.csv"), index=False)

    top10_all_df = pd.concat(top10_itemsets_all, ignore_index=True)
    top10_all_df.to_csv(os.path.join(tables_dir, "task4_top10_itemsets_per_minsup.csv"), index=False)

    comp_df = pd.DataFrame(comparison_rows)
    comp_df.to_csv(os.path.join(tables_dir, "task6_algorithm_comparison.csv"), index=False)

    # Top 10 rules by lift from the richest threshold (0.1%)
    primary_rules = all_rules_by_sup[min(min_supports)]
    top10_rules = primary_rules.head(10)
    top10_rules.to_csv(os.path.join(tables_dir, "task5_top10_rules_by_lift.csv"), index=False)

    print("\n=== Task 6 Algorithm Comparison Summary ===")
    print(comp_df.to_string(index=False))
    return {
        "size_df": size_df,
        "comparison_df": comp_df,
        "top10_rules": top10_rules,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run Task 4, 5, 6: Apriori, FP-Growth, and Association Rules.")
    parser.add_argument("--input", default="data/processed/tx_author_based.parquet")
    parser.add_argument("--tables-dir", default="tables")
    parser.add_argument("--min-confidence", type=float, default=MIN_CONFIDENCE)
    args = parser.parse_args()

    run_all_experiments(
        tx_path=args.input,
        tables_dir=args.tables_dir,
        min_confidence=args.min_confidence,
    )
