import gzip
import os
import pandas as pandas
from lxml import etree
from tqdm import tqdm

def parse_dblp_to_parquet(xml_gz_path: str, output_parquet_path: str, year_min: int = 2015, year_max: int = 2025):
    xml_dir = os.path.dirname(os.path.abspath(xml_gz_path))
    dtd_path = os.path.join(xml_dir, "dblp.dtd")
    if not os.path.exists(dtd_path):
        raise FileNotFoundError(f"dblp.dtd tidak ditemukan di {xml_dir}")

    records = []

    original_cwd = os.getcwd()
    os.chdir(xml_dir)

    try:
        with gzip.open(os.path.basename(xml_gz_path), "rb") as f:
            context = etree.iterparse(
                f,
                events=("end",),
                tag="inproceedings",
                load_dtd=True,
                resolve_entities=True
            )

            for _, elem in tqdm(context, desc="Parsing inproceedings"):
                year_text = elem.findtext("year")
                if year_text and year_text.isdigit():
                    year = int(year_text)
                    if year_min <= year <= year_max:
                        authors = [a.text.strip() for a in elem.findall("author") if a.text]
                        title = "".join(elem.find("title").itertext()).strip() if elem.find("title") is not None else None
                        venue = elem.findtext("booktitle")
                        venue = venue.strip() if venue else None
                        key = elem.get("key")

                        records.append({
                            "key": key,
                            "title": title,
                            "authors": authors,
                            "year": year,
                            "venue": venue
                        })
                elem.clear()
                while elem.getprevious() is not None:
                    del elem.getparent()[0]
    finally:
        os.chdir(original_cwd)

    df = pd.DataFrame(records)
    os.makedirs(os.path.dirname(os.path.abspath(output_parquet_path)), exist_ok=True)
    df.to_parquet(output_parquet_path, index=False)

if __name__ == "__main__":
    parse_dblp_to_parquet(
        xml_gz_path="data/raw/dblp.xml.gz",
        output_parquet_path="data/processed/dblp_2015_2025_raw.parquet"
    )