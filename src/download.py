"""Download DBLP XML dump and DTD into data/raw/ with provenance metadata."""

import argparse
import concurrent.futures
import hashlib
import json
import os
import time
import urllib.request
from datetime import datetime, timezone

MIRRORS = [
    "https://dblp.uni-trier.de/xml",
    "https://dblp.org/xml",
]
FILES = ("dblp.dtd", "dblp.xml.gz")
CHUNK_WORKERS = 8


def _sha256(path: str, chunk_size: int = 1024 * 1024) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(chunk_size):
            h.update(chunk)
    return h.hexdigest()


def _download_range(url: str, start: int, end: int, part_path: str, timeout: int = 120, retries: int = 50) -> int:
    """Download a byte range [start, end] to a temporary part file with retries."""
    expected = end - start + 1
    for attempt in range(1, retries + 1):
        try:
            existing = os.path.getsize(part_path) if os.path.exists(part_path) else 0
            if existing == expected:
                return existing
            req_start = start + existing
            req = urllib.request.Request(
                url,
                headers={
                    "User-Agent": "DBLP-Mining-IF4041/1.0",
                    "Range": f"bytes={req_start}-{end}",
                },
            )
            mode = "ab" if existing > 0 else "wb"
            with urllib.request.urlopen(req, timeout=timeout) as resp, open(part_path, mode) as out:
                while buf := resp.read(256 * 1024):
                    out.write(buf)
            got = os.path.getsize(part_path)
            if got == expected:
                return got
            raise IOError(f"Incomplete range {start}-{end}: got {got}/{expected}")
        except Exception as exc:
            if attempt == retries:
                raise
            time.sleep(min(3 * attempt, 30))
    return 0


def download_file(filename: str, dest_dir: str, timeout: int = 120, workers: int = CHUNK_WORKERS) -> dict:
    """Download a single DBLP file trying official mirrors in order, using parallel ranged requests when supported."""
    dest_path = os.path.join(dest_dir, filename)
    last_err = None

    for base_url in MIRRORS:
        url = f"{base_url}/{filename}"
        print(f"Downloading {url} -> {dest_path}")
        try:
            head_resp_headers = None
            for head_attempt in range(1, 15):
                try:
                    head_req = urllib.request.Request(url, method="HEAD", headers={"User-Agent": "DBLP-Mining-IF4041/1.0"})
                    with urllib.request.urlopen(head_req, timeout=timeout) as head_resp:
                        head_resp_headers = head_resp.headers
                    break
                except Exception as exc:
                    if head_attempt == 14:
                        raise
                    print(f"HEAD retry {head_attempt}/14 for {url}: {exc}")
                    time.sleep(min(3 * head_attempt, 20))

            last_modified = head_resp_headers.get("Last-Modified")
            total_size_hdr = head_resp_headers.get("Content-Length")
            accept_ranges = (head_resp_headers.get("Accept-Ranges") or "").lower()

            total_size = int(total_size_hdr) if total_size_hdr else None

            if total_size and total_size > 10 * 1024 * 1024 and "bytes" in accept_ranges and workers > 1:
                t0 = time.perf_counter()
                part_size = (total_size + workers - 1) // workers
                ranges = []
                part_paths = []
                for idx in range(workers):
                    s = idx * part_size
                    if s >= total_size:
                        break
                    e = min(s + part_size - 1, total_size - 1)
                    p = f"{dest_path}.part{idx}"
                    ranges.append((s, e, p))
                    part_paths.append(p)

                print(f"Using {len(ranges)} parallel connections for {total_size / (1024*1024):.1f} MiB...")
                with concurrent.futures.ThreadPoolExecutor(max_workers=len(ranges)) as ex:
                    futs = [ex.submit(_download_range, url, s, e, p, timeout) for s, e, p in ranges]
                    for fut in concurrent.futures.as_completed(futs):
                        fut.result()

                with open(dest_path, "wb") as out:
                    for p in part_paths:
                        with open(p, "rb") as inp:
                            while buf := inp.read(4 * 1024 * 1024):
                                out.write(buf)
                        os.remove(p)

                elapsed = time.perf_counter() - t0
                mbps = (total_size / (1024 * 1024)) / max(elapsed, 0.1)
                print(f"Completed {filename} in {elapsed:.1f}s ({mbps:.2f} MiB/s)")
            else:
                req = urllib.request.Request(url, headers={"User-Agent": "DBLP-Mining-IF4041/1.0"})
                with urllib.request.urlopen(req, timeout=timeout) as resp:
                    last_modified = resp.headers.get("Last-Modified")
                    total_size_hdr = resp.headers.get("Content-Length")
                    total_size = int(total_size_hdr) if total_size_hdr else None
                    with open(dest_path, "wb") as out:
                        while chunk := resp.read(1024 * 1024):
                            out.write(chunk)

            actual_size = os.path.getsize(dest_path)
            if total_size and actual_size != total_size:
                raise IOError(f"Size mismatch for {filename}: expected {total_size}, got {actual_size}")

            return {
                "filename": filename,
                "url": url,
                "last_modified": last_modified,
                "content_length": total_size or actual_size,
                "size_bytes": actual_size,
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
