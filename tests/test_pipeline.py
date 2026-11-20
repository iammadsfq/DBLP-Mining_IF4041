"""Automated sanity & correctness tests for transactions and mining modules."""

import math
import pandas as pd
from mlxtend.frequent_patterns import apriori, fpgrowth

from src.transactions import build_author_transactions, build_author_year_transactions
from src.mining import (
    encode_transactions_pruned,
    generate_rules_safe,
    verify_identical_itemsets,
)


def test_transactions_and_mining_exactness():
    df_clean = pd.DataFrame([
        {"key": "k1", "title": "t1", "authors": ["Alice", "Bob"], "year": 2020, "venue": "NeurIPS"},
        {"key": "k2", "title": "t2", "authors": ["Alice"], "year": 2020, "venue": "ICML"},
        {"key": "k3", "title": "t3", "authors": ["Alice"], "year": 2021, "venue": "ICLR"},
        {"key": "k4", "title": "t4", "authors": ["Bob"], "year": 2020, "venue": "ICML"},
        {"key": "k5", "title": "t5", "authors": ["Bob"], "year": 2021, "venue": "CVPR"},
        {"key": "k6", "title": "t6", "authors": ["Carol"], "year": 2020, "venue": "NeurIPS"},
        {"key": "k7", "title": "t7", "authors": ["Carol"], "year": 2020, "venue": "ICML"},
        {"key": "k8", "title": "t8", "authors": ["Dave"], "year": 2021, "venue": "RareConf"},
    ])

    tx_a = build_author_transactions(df_clean)
    assert len(tx_a) == 4  # Alice, Bob, Carol, Dave
    alice_row = tx_a[tx_a["author"] == "Alice"].iloc[0]
    assert alice_row["venues"] == ["ICLR", "ICML", "NeurIPS"]

    tx_ay = build_author_year_transactions(df_clean)
    assert len(tx_ay) == 6  # (Alice,2020), (Alice,2021), (Bob,2020), (Bob,2021), (Carol,2020), (Dave,2021)

    # Exact lossless pruning test at min_support=0.5 (RareConf appears in 1/4 = 0.25 -> pruned, N=4 preserved)
    sparse_df, n_tx, n_kept = encode_transactions_pruned(tx_a["venues"].tolist(), min_support=0.5)
    assert n_tx == 4
    assert "RareConf" not in sparse_df.columns
    assert n_kept == 2  # ICML (3/4), NeurIPS (3/4)

    ap_is = apriori(sparse_df, min_support=0.5, use_colnames=True, low_memory=True)
    fp_is = fpgrowth(sparse_df, min_support=0.5, use_colnames=True)
    assert verify_identical_itemsets(ap_is, fp_is)

    # Check exact support of {ICML, NeurIPS} = 3 / 4 = 0.75
    pair_row = fp_is[fp_is["itemsets"] == frozenset({"ICML", "NeurIPS"})].iloc[0]
    assert math.isclose(pair_row["support"], 0.75, abs_tol=1e-12)

    rules = generate_rules_safe(fp_is, min_confidence=0.5)
    assert len(rules) == 2
    for row in rules.itertuples(index=False):
        assert math.isclose(row.confidence, 1.0, abs_tol=1e-12)
        assert math.isclose(row.lift, 1.0 / 0.75, abs_tol=1e-9)

    print("All pipeline unit tests PASSED!")


if __name__ == "__main__":
    test_transactions_and_mining_exactness()
