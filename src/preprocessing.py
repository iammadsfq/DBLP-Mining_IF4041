"""Preprocessing pipeline for DBLP 2015-2025 inproceedings dataset."""

import argparse
import json
import os
import re
import unicodedata
from collections import Counter

import pandas as pd

VENUE_ALIASES = {
    "nips": "NeurIPS",
}


def normalize_text(text: str) -> str:
    """Apply Unicode NFC normalization and collapse whitespace."""
    if not isinstance(text, str):
        return ""
    return re.sub(r"\s+", " ", unicodedata.normalize("NFC", text)).strip()


def normalize_author_name(name: str) -> str:
    """Normalize an author name while preserving DBLP disambiguation suffixes (e.g. '0001')."""
    return normalize_text(name)


def normalize_author_list(authors) -> list[str]:
    """Normalize all author names in a paper and deduplicate while preserving order."""
    if authors is None:
        return []
    seen = set()
    cleaned = []
    for author in authors:
        norm = normalize_author_name(author)
        if norm and norm not in seen:
            seen.add(norm)
            cleaned.append(norm)
    return cleaned


def normalize_venue_base(venue: str) -> str:
    """Normalize whitespace, workshop parentheses, '@' spacing, and known conference renames."""
    v = normalize_text(venue)
    v = re.sub(r"\s*@\s*", "@", v)
    v = re.sub(r"\((Workshops?)\)", r"\1", v, flags=re.IGNORECASE)
    v = re.sub(r"\s+", " ", v).strip()
    alias = VENUE_ALIASES.get(v.lower())
    return alias if alias else v


def build_canonical_venue_map(venues: pd.Series) -> dict[str, str]:
    """Map case-insensitive venue keys to the most frequent surface form (tie-broken lexicographically)."""
    counts = Counter(venues.dropna())
    best_by_lower: dict[str, tuple[int, str]] = {}
    for form, cnt in counts.items():
        key = form.lower()
        prev = best_by_lower.get(key)
        if prev is None or cnt > prev[0] or (cnt == prev[0] and form < prev[1]):
            best_by_lower[key] = (cnt, form)
    return {k: v[1] for k, v in best_by_lower.items()}


def normalize_title_for_dedup(title: str) -> str:
    """Create a canonical lowercase alphanumeric title key for duplicate detection."""
    t = normalize_text(title).lower()
    t = re.sub(r"[^\w\s]", "", t)
    return re.sub(r"\s+", " ", t).strip()


def preprocess_dblp(
    input_parquet: str,
    output_parquet: str,
    summary_json: str,
    year_min: int = 2015,
    year_max: int = 2025,
) -> pd.DataFrame:
    """Run the full preprocessing pipeline and save cleaned Parquet + summary JSON."""
    df = pd.read_parquet(input_parquet)
    stats: dict = {"raw_records": int(len(df))}

    # 1. Year consistency
    df["year"] = pd.to_numeric(df["year"], errors="coerce")
    valid_year_mask = df["year"].notna() & df["year"].between(year_min, year_max)
    stats["dropped_invalid_year"] = int((~valid_year_mask).sum())
    df = df[valid_year_mask].copy()
    df["year"] = df["year"].astype("int32")

    # 2. Missing values: key, title, venue, authors
    df["key"] = df["key"].fillna("").map(normalize_text)
    df["title"] = df["title"].fillna("").map(normalize_text)
    df["venue"] = df["venue"].fillna("").map(normalize_text)

    missing_key_title = (df["key"] == "") | (df["title"] == "")
    stats["dropped_missing_key_or_title"] = int(missing_key_title.sum())
    df = df[~missing_key_title].copy()

    missing_venue = df["venue"] == ""
    stats["dropped_missing_venue"] = int(missing_venue.sum())
    df = df[~missing_venue].copy()

    df["authors"] = df["authors"].map(normalize_author_list)
    empty_authors = df["authors"].map(len) == 0
    stats["dropped_empty_authors"] = int(empty_authors.sum())
    df = df[~empty_authors].copy()

    # 3. Venue normalization (base rules + canonical case folding)
    df["venue"] = df["venue"].map(normalize_venue_base)
    canonical_map = build_canonical_venue_map(df["venue"])
    df["venue"] = df["venue"].str.lower().map(canonical_map)

    # 4. Deduplication: by DBLP key, then by (normalized_title, year, venue)
    before_key_dedup = len(df)
    df = df.drop_duplicates(subset=["key"], keep="first").copy()
    stats["dropped_duplicate_key"] = int(before_key_dedup - len(df))

    df["_title_norm"] = df["title"].map(normalize_title_for_dedup)
    before_content_dedup = len(df)
    df = df.drop_duplicates(subset=["_title_norm", "year", "venue"], keep="first").copy()
    stats["dropped_duplicate_title_year_venue"] = int(before_content_dedup - len(df))
    df = df.drop(columns=["_title_norm"]).reset_index(drop=True)

    # 5. Post-preprocessing statistics
    unique_authors = int(df["authors"].explode().nunique())
    unique_venues = int(df["venue"].nunique())
    year_dist = {int(k): int(v) for k, v in df["year"].value_counts().sort_index().items()}
    top_20_venues = {str(k): int(v) for k, v in df["venue"].value_counts().head(20).items()}

    stats["cleaned_records"] = int(len(df))
    stats["total_removed"] = int(stats["raw_records"] - stats["cleaned_records"])
    stats["unique_authors"] = unique_authors
    stats["unique_venues"] = unique_venues
    stats["year_distribution"] = year_dist
    stats["top_20_venues"] = top_20_venues

    os.makedirs(os.path.dirname(os.path.abspath(output_parquet)), exist_ok=True)
    df.to_parquet(output_parquet, index=False)

    os.makedirs(os.path.dirname(os.path.abspath(summary_json)), exist_ok=True)
    with open(summary_json, "w", encoding="utf-8") as f:
        json.dump(stats, f, indent=2, ensure_ascii=False)

    print("=== Preprocessing Summary ===")
    print(f"Raw records                     : {stats['raw_records']:,}")
    print(f"Dropped (invalid year)          : {stats['dropped_invalid_year']:,}")
    print(f"Dropped (missing key/title)     : {stats['dropped_missing_key_or_title']:,}")
    print(f"Dropped (missing venue)         : {stats['dropped_missing_venue']:,}")
    print(f"Dropped (empty authors)         : {stats['dropped_empty_authors']:,}")
    print(f"Dropped (duplicate key)         : {stats['dropped_duplicate_key']:,}")
    print(f"Dropped (dup title+year+venue)  : {stats['dropped_duplicate_title_year_venue']:,}")
    print(f"Cleaned records                 : {stats['cleaned_records']:,}")
    print(f"Unique authors                  : {stats['unique_authors']:,}")
    print(f"Unique venues                   : {stats['unique_venues']:,}")
    print(f"Saved cleaned Parquet to        : {output_parquet}")
    print(f"Saved summary JSON to           : {summary_json}")
    return df


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Preprocess raw DBLP 2015-2025 Parquet dataset.")
    parser.add_argument("--input", default="data/processed/dblp_2015_2025_raw.parquet")
    parser.add_argument("--output", default="data/processed/dblp_2015_2025_clean.parquet")
    parser.add_argument("--summary", default="data/processed/preprocessing_summary.json")
    parser.add_argument("--year-min", type=int, default=2015)
    parser.add_argument("--year-max", type=int, default=2025)
    args = parser.parse_args()

    preprocess_dblp(
        input_parquet=args.input,
        output_parquet=args.output,
        summary_json=args.summary,
        year_min=args.year_min,
        year_max=args.year_max,
    )
