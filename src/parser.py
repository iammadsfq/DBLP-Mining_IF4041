import argparse
import gzip
import json
import os
from collections import Counter
import pandas as pd
from lxml import etree
from tqdm import tqdm

PUBLICATION_TAGS = (
    "article",
    "inproceedings",
    "proceedings",
    "book",
    "incollection",
    "phdthesis",
    "mastersthesis",
    "www",
    "data",
)


def parse_dblp_to_parquet(
    xml_gz_path: str,
    output_parquet_path: str,
    year_min: int = 2015,
    year_max: int = 2025,
    pub_types_json_path: str = "data/processed/xml_publication_types.json",
):
    """Parse DBLP XML dump, count all publication types, and extract inproceedings within [year_min, year_max]."""
    xml_dir = os.path.dirname(os.path.abspath(xml_gz_path))
    dtd_path = os.path.join(xml_dir, "dblp.dtd")
    if not os.path.exists(dtd_path):
        raise FileNotFoundError(f"dblp.dtd tidak ditemukan di {xml_dir}")

    records = []
    pub_type_counts: Counter = Counter()

    original_cwd = os.getcwd()
    os.chdir(xml_dir)

    try:
        with gzip.open(os.path.basename(xml_gz_path), "rb") as f:
            context = etree.iterparse(
                f,
                events=("end",),
                tag=PUBLICATION_TAGS,
                load_dtd=True,
                resolve_entities=True,
                huge_tree=True,
            )

            for _, elem in tqdm(context, desc="Parsing DBLP XML"):
                tag = elem.tag
                pub_type_counts[tag] += 1
                if tag == "inproceedings":
                    year_text = elem.findtext("year")
                    if year_text and year_text.isdigit():
                        year = int(year_text)
                        if year_min <= year <= year_max:
                            authors = [a.text.strip() for a in elem.findall("author") if a.text]
                            title_el = elem.find("title")
                            title = "".join(title_el.itertext()).strip() if title_el is not None else None
                            venue = elem.findtext("booktitle")
                            venue = venue.strip() if venue else None
                            key = elem.get("key")

                            records.append({
                                "key": key,
                                "title": title,
                                "authors": authors,
                                "year": year,
                                "venue": venue,
                            })
                elem.clear()
                parent = elem.getparent()
                if parent is not None:
                    while elem.getprevious() is not None:
                        del parent[0]
    finally:
        os.chdir(original_cwd)

    df = pd.DataFrame(records)
    os.makedirs(os.path.dirname(os.path.abspath(output_parquet_path)), exist_ok=True)
    df.to_parquet(output_parquet_path, index=False)

    pub_types_summary = {
        "total_records": int(sum(pub_type_counts.values())),
        "by_type": {k: int(v) for k, v in pub_type_counts.most_common()},
        "extracted_inproceedings_range": [year_min, year_max],
        "extracted_inproceedings_count": int(len(df)),
    }
    os.makedirs(os.path.dirname(os.path.abspath(pub_types_json_path)), exist_ok=True)
    with open(pub_types_json_path, "w", encoding="utf-8") as f:
        json.dump(pub_types_summary, f, indent=2)

    print(f"Total DBLP records scanned: {pub_types_summary['total_records']:,}")
    print(f"Total <inproceedings> scanned: {pub_type_counts['inproceedings']:,}")
    print(f"Extracted records ({year_min}-{year_max}): {len(df):,}")
    print(f"Saved Parquet to: {output_parquet_path}")
    print(f"Saved publication type counts to: {pub_types_json_path}")
    return df


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Parse DBLP XML inproceedings to Parquet.")
    parser.add_argument("--input", default="data/raw/dblp.xml.gz", help="Path to dblp.xml.gz")
    parser.add_argument("--output", default="data/processed/dblp_2015_2025_raw.parquet", help="Output Parquet path")
    parser.add_argument("--pub-types-json", default="data/processed/xml_publication_types.json", help="Output JSON for XML publication type counts")
    parser.add_argument("--year-min", type=int, default=2015, help="Minimum publication year")
    parser.add_argument("--year-max", type=int, default=2025, help="Maximum publication year")
    args = parser.parse_args()

    parse_dblp_to_parquet(
        xml_gz_path=args.input,
        output_parquet_path=args.output,
        year_min=args.year_min,
        year_max=args.year_max,
        pub_types_json_path=args.pub_types_json,
    )