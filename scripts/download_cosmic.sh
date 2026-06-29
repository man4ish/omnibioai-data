#!/usr/bin/env bash
# =============================================================================
# download_cosmic.sh — Download COSMIC variant database for OmniBioAI
#
# Usage:
#   bash scripts/download_cosmic.sh
#
# Requirements:
#   - COSMIC account (register at https://cancer.sanger.ac.uk/cosmic/register)
#   - Set COSMIC_EMAIL and COSMIC_PASSWORD environment variables, or
#     pass them as arguments:
#     COSMIC_EMAIL=you@example.com COSMIC_PASSWORD=yourpass bash scripts/download_cosmic.sh
#
# What gets downloaded:
#   - Genome Screen Mutants VCF (GRCh38) — somatic mutations across cancer genomes
#   - Coding Mutations VCF (GRCh38)       — coding region somatic mutations
#   - Cancer Gene Census (GRCh38)         — cancer driver gene list
#
# Output directory:
#   omnibioai-data/reference/variants/human/cosmic/
# =============================================================================

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
COSMIC_VERSION="${COSMIC_VERSION:-v104}"
GENOME="${GENOME:-GRCh38}"
COSMIC_API="https://cancer.sanger.ac.uk/api/mono/products/v1/downloads/scripted"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="$REPO_ROOT/reference/variants/human/cosmic"

# ── Credentials ───────────────────────────────────────────────────────────────
EMAIL="${COSMIC_EMAIL:-}"
PASSWORD="${COSMIC_PASSWORD:-}"

if [[ -z "$EMAIL" || -z "$PASSWORD" ]]; then
    echo "ERROR: COSMIC credentials required."
    echo ""
    echo "Set environment variables before running:"
    echo "  export COSMIC_EMAIL=mkumar4@kumc.edu"
    echo "  export COSMIC_PASSWORD=$#Hanuman007"
    echo "  bash scripts/download_cosmic.sh"
    echo ""
    echo "Register at: https://cancer.sanger.ac.uk/cosmic/register"
    exit 1
fi

# ── Generate auth token ───────────────────────────────────────────────────────
echo "Generating COSMIC authentication token..."
AUTH=$(echo -n "${EMAIL}:${PASSWORD}" | base64)

# ── Files to download ─────────────────────────────────────────────────────────
declare -A FILES=(
    ["Cosmic_GenomeScreensMutant_Vcf_${COSMIC_VERSION}_${GENOME}.tar"]="${GENOME}/cosmic/${COSMIC_VERSION}/VCF/Cosmic_GenomeScreensMutant_Vcf_${COSMIC_VERSION}_${GENOME}.tar"
    ["Cosmic_CodingMuts_Vcf_${COSMIC_VERSION}_${GENOME}.tar"]="${GENOME}/cosmic/${COSMIC_VERSION}/VCF/Cosmic_CodingMuts_Vcf_${COSMIC_VERSION}_${GENOME}.tar"
    ["Cosmic_CancerGeneCensus_Tsv_${COSMIC_VERSION}_${GENOME}.tar"]="${GENOME}/cosmic/${COSMIC_VERSION}/cancer_gene_census/Cosmic_CancerGeneCensus_Tsv_${COSMIC_VERSION}_${GENOME}.tar"
)

# ── Download ──────────────────────────────────────────────────────────────────
mkdir -p "$OUT_DIR"
echo "Output directory: $OUT_DIR"
echo ""

for FILENAME in "${!FILES[@]}"; do
    PATH_PARAM="${FILES[$FILENAME]}"
    OUT_FILE="$OUT_DIR/$FILENAME"

    if [[ -f "$OUT_FILE" && -s "$OUT_FILE" ]]; then
        echo "✓ Already exists: $FILENAME — skipping"
        continue
    fi

    echo "Fetching download URL for: $FILENAME"
    DOWNLOAD_URL=$(curl -s \
        -H "Authorization: Basic ${AUTH}" \
        "${COSMIC_API}?path=${PATH_PARAM}&bucket=downloads" | \
        python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('url',''))" 2>/dev/null)

    if [[ -z "$DOWNLOAD_URL" ]]; then
        echo "  ✗ Failed to get URL for $FILENAME — check credentials or file path"
        continue
    fi

    echo "  Downloading $FILENAME..."
    curl -# "$DOWNLOAD_URL" --output "$OUT_FILE"

    if [[ -f "$OUT_FILE" && -s "$OUT_FILE" ]]; then
        SIZE=$(du -sh "$OUT_FILE" | cut -f1)
        echo "  ✓ Downloaded: $FILENAME ($SIZE)"
    else
        echo "  ✗ Download failed: $FILENAME"
    fi
    echo ""
done

# ── Extract tarballs ──────────────────────────────────────────────────────────
echo "Extracting downloaded files..."
for TAR in "$OUT_DIR"/*.tar; do
    [[ -f "$TAR" ]] || continue
    echo "  Extracting: $(basename $TAR)"
    tar -xf "$TAR" -C "$OUT_DIR" && rm "$TAR"
    echo "  ✓ Extracted and removed tarball"
done

# ── Index VCF files ───────────────────────────────────────────────────────────
echo ""
echo "Indexing VCF files with tabix..."
for VCF in "$OUT_DIR"/*.vcf.gz; do
    [[ -f "$VCF" ]] || continue
    if [[ ! -f "${VCF}.tbi" ]]; then
        echo "  Indexing: $(basename $VCF)"
        tabix -p vcf "$VCF" && echo "  ✓ Indexed: $(basename $VCF)"
    else
        echo "  ✓ Already indexed: $(basename $VCF)"
    fi
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════"
echo "COSMIC download complete"
echo "Location: $OUT_DIR"
echo ""
ls -lh "$OUT_DIR"
echo "═══════════════════════════════════════════"