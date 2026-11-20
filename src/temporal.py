"""Section E: Temporal Association Analysis on Author-Year-Based Transactional Database."""

import argparse
import os
import pandas as pd
from mlxtend.frequent_patterns import fpgrowth

from src.mining import (
    MIN_CONFIDENCE,
    encode_transactions_pruned,
    format_itemsets_table,
    format_rules_table,
    generate_rules_safe,
)

PERIODS = [
    ("2015-2017", 2015, 2017),
    ("2018-2020", 2018, 2020),
    ("2021-2023", 2021, 2023),
    ("2024-2025", 2024, 2025),
]


def run_temporal_for_threshold(
    tx_ay: pd.DataFrame,
    min_support: float,
    min_confidence: float = MIN_CONFIDENCE,
) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """Run FP-Growth + Association Rules across the 4 temporal periods for a given min_support."""
    summary_rows = []
    itemset_frames = []
    rule_frames = []

    for label, y_start, y_end in PERIODS:
        sub = tx_ay[(tx_ay["year"] >= y_start) & (tx_ay["year"] <= y_end)]
        n_tx = len(sub)
        multi_pct = round(float((sub["n_items"] >= 2).mean() * 100), 2) if n_tx > 0 else 0.0
        venues_list = sub["venues"].tolist()

        sparse_df, _, n_kept = encode_transactions_pruned(venues_list, min_support)
        if n_kept == 0:
            fp_is = pd.DataFrame(columns=["support", "itemsets"])
        else:
            fp_is = fpgrowth(sparse_df, min_support=min_support, use_colnames=True)

        rules_raw = generate_rules_safe(fp_is, min_confidence=min_confidence)
        is_tbl = format_itemsets_table(fp_is, n_tx, min_support)
        rules_tbl = format_rules_table(rules_raw, n_tx, min_support)

        is_tbl.insert(0, "period", label)
        rules_tbl.insert(0, "period", label)

        itemset_frames.append(is_tbl)
        rule_frames.append(rules_tbl)

        len_counts = is_tbl["length"].value_counts().to_dict() if not is_tbl.empty else {}
        summary_rows.append({
            "period": label,
            "year_start": y_start,
            "year_end": y_end,
            "min_support": min_support,
            "min_support_pct": f"{min_support * 100:.2f}%",
            "num_transactions": n_tx,
            "multi_item_tx_pct": multi_pct,
            "n_1_itemsets": int(len_counts.get(1, 0)),
            "n_2_itemsets": int(len_counts.get(2, 0)),
            "n_3plus_itemsets": int(sum(v for k, v in len_counts.items() if k >= 3)),
            "total_itemsets": int(len(is_tbl)),
            "total_rules_conf50": int(len(rules_tbl)),
        })

    summary_df = pd.DataFrame(summary_rows)
    all_itemsets = pd.concat(itemset_frames, ignore_index=True)
    all_rules = pd.concat(rule_frames, ignore_index=True)
    return summary_df, all_itemsets, all_rules


def build_rule_evolution(all_rules: pd.DataFrame) -> pd.DataFrame:
    """Track rule presence, support, confidence, and lift across the 4 temporal periods."""
    period_labels = [p[0] for p in PERIODS]
    if all_rules.empty:
        return pd.DataFrame(columns=["rule", "periods_present", "pattern_status"])

    piv_lift = all_rules.pivot_table(index="rule", columns="period", values="lift", aggfunc="first").reindex(columns=period_labels)
    piv_sup = all_rules.pivot_table(index="rule", columns="period", values="support_pct", aggfunc="first").reindex(columns=period_labels)
    piv_conf = all_rules.pivot_table(index="rule", columns="period", values="confidence_pct", aggfunc="first").reindex(columns=period_labels)

    rows = []
    for rule in piv_lift.index:
        present = [p for p in period_labels if pd.notna(piv_lift.loc[rule, p])]
        n_present = len(present)
        if n_present == 4:
            status = "Persisten (Semua Periode)"
        elif n_present == 3:
            status = "Stabil (3 Periode)"
        elif all(p in ("2021-2023", "2024-2025") for p in present):
            status = "Emerging (2021-2025)"
        elif all(p in ("2015-2017", "2018-2020") for p in present):
            status = "Declining/Hilang (2015-2020)"
        else:
            status = "Fluktuatif / Transisi"

        row = {
            "rule": rule,
            "periods_present": n_present,
            "periods_list": ", ".join(present),
            "pattern_status": status,
        }
        for p in period_labels:
            row[f"lift_{p}"] = round(float(piv_lift.loc[rule, p]), 2) if pd.notna(piv_lift.loc[rule, p]) else None
            row[f"sup_pct_{p}"] = round(float(piv_sup.loc[rule, p]), 4) if pd.notna(piv_sup.loc[rule, p]) else None
            row[f"conf_pct_{p}"] = round(float(piv_conf.loc[rule, p]), 2) if pd.notna(piv_conf.loc[rule, p]) else None
        row["mean_lift"] = round(float(piv_lift.loc[rule].dropna().mean()), 2)
        rows.append(row)

    evo_df = pd.DataFrame(rows).sort_values(["periods_present", "mean_lift"], ascending=[False, False]).reset_index(drop=True)
    return evo_df


def main() -> None:
    parser = argparse.ArgumentParser(description="Run Section E Temporal Association Analysis.")
    parser.add_argument("--input", default="data/processed/tx_author_year_based.parquet")
    parser.add_argument("--tables-dir", default="tables")
    parser.add_argument("--primary-min-support", type=float, default=0.001)
    parser.add_argument("--sensitivity-min-support", type=float, default=0.0005)
    parser.add_argument("--min-confidence", type=float, default=MIN_CONFIDENCE)
    args = parser.parse_args()

    os.makedirs(args.tables_dir, exist_ok=True)
    print(f"Loading Author-Year-Based transactions from {args.input}...")
    tx_ay = pd.read_parquet(args.input)
    print(f"Loaded {len(tx_ay):,} Author-Year transactions.")

    # Primary threshold (0.1%)
    print(f"\n=== Temporal Analysis (Primary min_support = {args.primary_min_support*100:.2f}%) ===")
    sum_01, is_01, rules_01 = run_temporal_for_threshold(tx_ay, args.primary_min_support, args.min_confidence)
    sum_01.to_csv(os.path.join(args.tables_dir, "temporal_period_summary_01pct.csv"), index=False)
    is_01.to_csv(os.path.join(args.tables_dir, "temporal_itemsets_01pct.csv"), index=False)
    rules_01.to_csv(os.path.join(args.tables_dir, "temporal_rules_01pct.csv"), index=False)
    evo_01 = build_rule_evolution(rules_01)
    evo_01.to_csv(os.path.join(args.tables_dir, "temporal_rule_evolution_01pct.csv"), index=False)
    print(sum_01.to_string(index=False))

    # Sensitivity threshold (0.05%) for sparse Author-Year transactions
    print(f"\n=== Temporal Analysis (Sensitivity min_support = {args.sensitivity_min_support*100:.2f}%) ===")
    sum_005, is_005, rules_005 = run_temporal_for_threshold(tx_ay, args.sensitivity_min_support, args.min_confidence)
    sum_005.to_csv(os.path.join(args.tables_dir, "temporal_period_summary_005pct.csv"), index=False)
    is_005.to_csv(os.path.join(args.tables_dir, "temporal_itemsets_005pct.csv"), index=False)
    rules_005.to_csv(os.path.join(args.tables_dir, "temporal_rules_005pct.csv"), index=False)
    evo_005 = build_rule_evolution(rules_005)
    evo_005.to_csv(os.path.join(args.tables_dir, "temporal_rule_evolution_005pct.csv"), index=False)
    print(sum_005.to_string(index=False))

    # Also write combined summary table
    pd.concat([sum_01, sum_005], ignore_index=True).to_csv(
        os.path.join(args.tables_dir, "temporal_period_summary.csv"), index=False
    )


if __name__ == "__main__":
    main()
