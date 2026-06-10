#!/usr/bin/env python3
"""
Data Ingestion Script for Global Language Distribution Map

Downloads, merges, and normalizes language data from:
1. Glottolog CLDF languages.csv (primary source)
2. Glottolog languoid CSV (family classification, country data)
3. UNESCO Atlas of Endangered Languages (endangerment details, descriptions)

Outputs: ../assets/data/languages.json
"""

import csv
import io
import json
import os
import sys
import zipfile
from pathlib import Path

import pandas as pd
import requests
from rapidfuzz import fuzz

# ─── Configuration ───────────────────────────────────────────────────────────

GLOTTOLOG_CLDF_URL = (
    "https://raw.githubusercontent.com/glottolog/glottolog-cldf/master/cldf/languages.csv"
)
GLOTTOLOG_LANGUOID_URL = (
    "https://cdstar.eva.mpg.de//bitstreams/EAEA0-608B-9919-A962-0/glottolog_languoid.csv.zip"
)

# UNESCO data embedded as fallback — we also try fetching from a known mirror
UNESCO_MIRRORS = [
    "https://raw.githubusercontent.com/nedatahe/endangered-languages/main/app/UN_UNESCO.csv",
]

OUTPUT_DIR = Path(__file__).resolve().parent.parent / "assets" / "data"
OUTPUT_FILE = OUTPUT_DIR / "languages.json"
CACHE_DIR = Path(__file__).resolve().parent / ".cache"


# ─── Helpers ─────────────────────────────────────────────────────────────────

def download_file(url: str, description: str) -> str:
    """Download a URL and return its text content."""
    print(f"  ↓ Downloading {description}...")
    print(f"    URL: {url}")
    resp = requests.get(url, timeout=120)
    resp.raise_for_status()
    print(f"    ✓ {len(resp.content)} bytes received")
    return resp.text


def download_zip(url: str, description: str) -> dict[str, bytes]:
    """Download a ZIP and return a dict of filename → bytes."""
    print(f"  ↓ Downloading {description}...")
    print(f"    URL: {url}")
    resp = requests.get(url, timeout=120)
    resp.raise_for_status()
    print(f"    ✓ {len(resp.content)} bytes received")
    files = {}
    with zipfile.ZipFile(io.BytesIO(resp.content)) as zf:
        for name in zf.namelist():
            files[name] = zf.read(name)
            print(f"    📄 Extracted: {name} ({len(files[name])} bytes)")
    return files


def safe_float(val, default=0.0) -> float:
    """Safely convert a value to float."""
    if val is None or val == "" or (isinstance(val, float) and pd.isna(val)):
        return default
    try:
        return float(val)
    except (ValueError, TypeError):
        return default


def normalize_endangerment(aes: str, unesco_level: str = "") -> str:
    """Normalize endangerment status from various sources to a standard label."""
    if unesco_level:
        mapping = {
            "vulnerable": "threatened",
            "definitely endangered": "shifting",
            "severely endangered": "moribund",
            "critically endangered": "nearly extinct",
            "extinct": "extinct",
        }
        return mapping.get(unesco_level.strip().lower(), "")

    if aes:
        aes_lower = aes.strip().lower()
        valid = {
            "not endangered", "threatened", "shifting",
            "moribund", "nearly extinct", "extinct",
        }
        if aes_lower in valid:
            return aes_lower
    return "not endangered"


# ─── Main Ingestion ─────────────────────────────────────────────────────────

def load_glottolog_cldf() -> pd.DataFrame:
    """Load Glottolog CLDF languages.csv and filter to actual languages."""
    print("\n[1/3] Loading Glottolog CLDF languages.csv ...")
    text = download_file(GLOTTOLOG_CLDF_URL, "Glottolog CLDF languages.csv")

    df = pd.read_csv(io.StringIO(text), low_memory=False)
    print(f"  Total languoids: {len(df)}")
    print(f"  Columns: {list(df.columns)}")

    # Filter to only actual languages (not families or dialects)
    if "Level" in df.columns:
        df = df[df["Level"] == "language"].copy()
    print(f"  Languages only: {len(df)}")

    return df


def load_glottolog_languoid() -> pd.DataFrame:
    """Load glottolog_languoid.csv for family names and country data."""
    print("\n[2/3] Loading Glottolog languoid data ...")
    files = download_zip(GLOTTOLOG_LANGUOID_URL, "glottolog_languoid.csv.zip")

    csv_name = [n for n in files if n.endswith(".csv")][0]
    text = files[csv_name].decode("utf-8-sig")
    df = pd.read_csv(io.StringIO(text), low_memory=False)
    print(f"  Total languoids: {len(df)}")
    print(f"  Columns: {list(df.columns)}")

    return df


def load_unesco_data() -> pd.DataFrame:
    """Load UNESCO endangered languages data from mirrors."""
    print("\n[3/3] Loading UNESCO endangered languages data ...")

    for url in UNESCO_MIRRORS:
        try:
            text = download_file(url, "UNESCO endangered languages")
            df = pd.read_csv(io.StringIO(text), low_memory=False)
            print(f"  UNESCO entries: {len(df)}")
            print(f"  Columns: {list(df.columns)}")
            return df
        except Exception as e:
            print(f"  ⚠ Mirror failed: {e}")
            continue

    print("  ⚠ No UNESCO data available — proceeding without it")
    return pd.DataFrame()


def build_family_lookup(languoid_df: pd.DataFrame) -> dict:
    """Build a lookup from glottocode → family name."""
    # The languoid CSV has columns: id, family_id, parent_id, name, level, etc.
    # We need to map family_id → family name
    id_col = None
    name_col = None
    family_id_col = None
    country_col = None

    for col in languoid_df.columns:
        col_lower = col.lower().strip()
        if col_lower == "id":
            id_col = col
        elif col_lower == "name":
            name_col = col
        elif col_lower == "family_id":
            family_id_col = col
        elif col_lower in ("country_ids", "countries"):
            country_col = col

    if not all([id_col, name_col]):
        print("  ⚠ Could not identify required columns in languoid CSV")
        return {}, {}

    # Build id → name lookup
    id_to_name = dict(zip(languoid_df[id_col], languoid_df[name_col]))

    # Build glottocode → (family_name, country_ids) lookup
    lookup = {}
    for _, row in languoid_df.iterrows():
        gc = row.get(id_col, "")
        family_id = row.get(family_id_col, "") if family_id_col else ""
        country_ids = row.get(country_col, "") if country_col else ""

        family_name = ""
        if family_id and not pd.isna(family_id):
            family_name = id_to_name.get(family_id, str(family_id))

        lookup[gc] = {
            "family_name": family_name if family_name and not pd.isna(family_name) else "",
            "country_ids": str(country_ids) if country_ids and not pd.isna(country_ids) else "",
        }

    return lookup


def match_unesco(
    cldf_df: pd.DataFrame,
    unesco_df: pd.DataFrame,
    threshold: int = 80,
) -> dict:
    """
    Fuzzy-match UNESCO entries to Glottolog languages by name.
    Returns a dict of glottocode → UNESCO record.
    """
    if unesco_df.empty:
        return {}

    print("\n  🔗 Matching UNESCO entries to Glottolog languages ...")

    # Identify UNESCO columns
    name_col = None
    endanger_col = None
    desc_col = None
    speakers_col = None
    countries_col = None

    for col in unesco_df.columns:
        col_lower = col.lower().strip()
        if "name" in col_lower and "english" in col_lower:
            name_col = col
        elif "name" in col_lower and name_col is None:
            name_col = col
        elif "endangerment" in col_lower or "degree" in col_lower:
            endanger_col = col
        elif "description" in col_lower:
            desc_col = col
        elif "speaker" in col_lower:
            speakers_col = col
        elif ("countries" in col_lower or "country" in col_lower) and "code" not in col_lower:
            countries_col = col

    if not name_col:
        print("  ⚠ Could not find name column in UNESCO data")
        return {}

    # Build a name-based lookup from CLDF
    cldf_name_col = "Name" if "Name" in cldf_df.columns else cldf_df.columns[1]
    cldf_id_col = "ID" if "ID" in cldf_df.columns else cldf_df.columns[0]

    cldf_names = {}
    for _, row in cldf_df.iterrows():
        name = str(row[cldf_name_col]).strip().lower()
        cldf_names[name] = row[cldf_id_col]

    matches = {}
    matched_count = 0

    for _, urow in unesco_df.iterrows():
        uname = str(urow.get(name_col, "")).strip()
        if not uname or uname == "nan":
            continue

        uname_lower = uname.lower()

        # Try exact match first
        if uname_lower in cldf_names:
            gc = cldf_names[uname_lower]
            matches[gc] = {
                "unesco_endangerment": str(urow.get(endanger_col, "")) if endanger_col else "",
                "description": str(urow.get(desc_col, "")) if desc_col else "",
                "speakers": str(urow.get(speakers_col, "")) if speakers_col else "",
                "countries": str(urow.get(countries_col, "")) if countries_col else "",
            }
            matched_count += 1
            continue

        # Fuzzy match
        best_score = 0
        best_gc = None
        for cname, gc in cldf_names.items():
            score = fuzz.ratio(uname_lower, cname)
            if score > best_score:
                best_score = score
                best_gc = gc

        if best_score >= threshold and best_gc:
            matches[best_gc] = {
                "unesco_endangerment": str(urow.get(endanger_col, "")) if endanger_col else "",
                "description": str(urow.get(desc_col, "")) if desc_col else "",
                "speakers": str(urow.get(speakers_col, "")) if speakers_col else "",
                "countries": str(urow.get(countries_col, "")) if countries_col else "",
            }
            matched_count += 1

    print(f"  ✓ Matched {matched_count}/{len(unesco_df)} UNESCO entries")
    return matches


def build_language_records(
    cldf_df: pd.DataFrame,
    family_lookup: dict,
    unesco_matches: dict,
) -> list[dict]:
    """Build the final Language model records."""
    print("\n  📦 Building normalized language records ...")

    # Identify CLDF columns
    id_col = "ID" if "ID" in cldf_df.columns else cldf_df.columns[0]
    name_col = "Name" if "Name" in cldf_df.columns else cldf_df.columns[1]
    lat_col = "Latitude" if "Latitude" in cldf_df.columns else None
    lon_col = "Longitude" if "Longitude" in cldf_df.columns else None
    aes_col = "AES" if "AES" in cldf_df.columns else None
    macro_col = "Macroarea" if "Macroarea" in cldf_df.columns else None
    class_col = "Classification" if "Classification" in cldf_df.columns else None

    records = []
    for _, row in cldf_df.iterrows():
        gc = str(row[id_col]).strip()
        name = str(row[name_col]).strip()

        if not gc or gc == "nan" or not name or name == "nan":
            continue

        lat = safe_float(row.get(lat_col)) if lat_col else 0.0
        lon = safe_float(row.get(lon_col)) if lon_col else 0.0
        aes = str(row.get(aes_col, "")).strip() if aes_col else ""
        macroarea = str(row.get(macro_col, "")).strip() if macro_col else ""

        # Get family info from languoid lookup
        fam_info = family_lookup.get(gc, {})
        family_name = fam_info.get("family_name", "")
        country_ids = fam_info.get("country_ids", "")

        # If no family from languoid, try to extract from Classification
        if not family_name and class_col:
            classification = str(row.get(class_col, "")).strip()
            if classification and classification != "nan":
                # Classification is slash-separated glottocodes
                parts = classification.split("/")
                if parts:
                    top_gc = parts[0]
                    top_info = family_lookup.get(top_gc, {})
                    family_name = top_info.get("family_name", "")
                    if not family_name:
                        # Use the glottocode itself as family identifier
                        family_name = top_gc

        # Use macroarea as fallback for country/region
        country_region = country_ids if country_ids and country_ids != "nan" else macroarea
        if not country_region or country_region == "nan":
            country_region = ""

        # Determine endangerment status
        unesco_info = unesco_matches.get(gc, {})
        unesco_endanger = unesco_info.get("unesco_endangerment", "")

        if unesco_endanger and unesco_endanger != "nan":
            endangered_status = normalize_endangerment("", unesco_level=unesco_endanger)
        else:
            endangered_status = normalize_endangerment(aes)

        # Build description
        description = ""
        unesco_desc = unesco_info.get("description", "")
        if unesco_desc and unesco_desc != "nan":
            description = unesco_desc
        else:
            # Generate a basic description
            parts = []
            if family_name:
                parts.append(f"{name} is a member of the {family_name} language family.")
            if country_region:
                parts.append(f"Spoken in: {country_region}.")
            if macroarea and macroarea != "nan":
                parts.append(f"Macroarea: {macroarea}.")
            speakers = unesco_info.get("speakers", "")
            if speakers and speakers != "nan":
                parts.append(f"Speakers: {speakers}.")
            if endangered_status and endangered_status != "not endangered":
                parts.append(f"Endangerment status: {endangered_status}.")
            description = " ".join(parts) if parts else f"A language classified in Glottolog."

        record = {
            "id": gc,
            "name": name,
            "languageFamily": family_name if family_name and family_name != "nan" else "Unclassified",
            "countryRegion": country_region if country_region else "Unknown",
            "latitude": lat,
            "longitude": lon,
            "endangeredStatus": endangered_status,
            "description": description,
        }
        records.append(record)

    # Sort by name
    records.sort(key=lambda r: r["name"].lower())
    return records


def main():
    print("=" * 60)
    print("  Global Language Distribution Map — Data Ingestion")
    print("=" * 60)

    # Step 1: Load data sources
    cldf_df = load_glottolog_cldf()
    languoid_df = load_glottolog_languoid()
    unesco_df = load_unesco_data()

    # Step 2: Build lookups
    print("\n  🔍 Building family lookup ...")
    family_lookup = build_family_lookup(languoid_df)
    print(f"  ✓ {len(family_lookup)} entries in family lookup")

    # Step 3: Match UNESCO data
    unesco_matches = match_unesco(cldf_df, unesco_df)

    # Step 4: Build records
    records = build_language_records(cldf_df, family_lookup, unesco_matches)

    # Step 5: Write output
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(records, f, ensure_ascii=False, indent=2)

    file_size = OUTPUT_FILE.stat().st_size
    print(f"\n{'=' * 60}")
    print(f"  ✅ Done! Generated {len(records)} language records")
    print(f"  📁 Output: {OUTPUT_FILE}")
    print(f"  📊 File size: {file_size / 1024:.1f} KB")
    print(f"{'=' * 60}")

    # Print statistics
    status_counts = {}
    for r in records:
        s = r["endangeredStatus"]
        status_counts[s] = status_counts.get(s, 0) + 1
    print("\n  Endangerment breakdown:")
    for status, count in sorted(status_counts.items(), key=lambda x: -x[1]):
        print(f"    {status:20s}: {count:5d}")

    family_count = len(set(r["languageFamily"] for r in records))
    with_coords = sum(1 for r in records if r["latitude"] != 0 or r["longitude"] != 0)
    print(f"\n  Unique families: {family_count}")
    print(f"  With coordinates: {with_coords}/{len(records)}")


if __name__ == "__main__":
    main()
