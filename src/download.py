"""Download DBLP XML dump and DTD into data/raw/ with provenance metadata."""

import argparse
import hashlib
import json
import os
import urllib.request
from datetime import datetime, timezone

MIRRORS = [
    "https://dblp.org/xml",
    "https://dblp.uni-trier.de/xml",
]
FILES = ("dblp.dtd", "dblp.xml.gz")


def _sha256(path: str, chunk_size: int = 1024 * 1024) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(chunk_size):
            h.update(chunk)
    return h.hexdigest()


def download_file(filename: str, dest_dir: str, timeout: int = 30) -> dict:
    """Download a single DBLP file trying official mirrors in order."""
    dest_path = os.path.join(dest_dir, filename)
    last_err = None

    for base_url in MIRRORS:
        url = f"{base_url}/{filename}"
        print(f"Downloading {url} -> {dest_path}")
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "DBLP-Mining-IF4041/1.0"})
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                last_modified = resp.headers.get("Last-Modified")
                total_size = resp.headers.get("Content-Length")
                with open(dest_path, "wb") as out:
                    while chunk := resp.read(1024 * 1024):
                        out.write(chunk)
            return {
                "filename": filename,
                "url": url,
                "last_modified": last_modified,
                "content_length": int(total_size) if total_size else os.path.getsize(dest_path),
                "size_bytes": os.path.getsize(dest_path),
                "sha256": _sha256(dest_path),
            }
        except Exception as exc:
            print(f"Failed from {url}: {exc}")
            last_err = exc

    raise RuntimeError(f"Could not download {filename} from any mirror") from last_err


def main() -> None:
    parser = argparse.ArgumentParser(description="Download DBLP XML dataset.")
    parser.add_argument("--raw-dir", default="data/raw", help="Output directory for raw DBLP files.")
    parser.add_argument("--force", action="store_true", help="Re-download even if files already exist.")
    args = parser.parse_args()

    os.makedirs(args.raw_dir, exist_ok=True)
    metadata = {
        "downloaded_at_utc": datetime.now(timezone.utc).isoformat(),
        "files": {},
    }

    for fname in FILES:
        dest = os.path.join(args.raw_dir, fname)
        if os.path.exists(dest) and not args.force:
            print(f"Skipping {dest} (already exists, use --force to re-download)")
            metadata["files"][fname] = {
                "filename": fname,
                "size_bytes": os.path.getsize(dest),
                "sha256": _sha256(dest),
            }
        else:
            metadata["files"][fname] = download_file(fname, args.raw_dir)

    meta_path = os.path.join(args.raw_dir, "metadata.json")
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)
    print(f"Saved metadata to {meta_path}")


if __name__ == "__main__":
    main()
