# omnibioai-data

Runtime data directory for the OmniBioAI platform. This repository contains the directory structure, sample files, and registry configuration needed to bootstrap a local OmniBioAI instance.

Large runtime files (datasets, uploads, results, cached data, tool images) are excluded from version control via `.gitignore`. The directory structure is preserved via `.gitkeep` files.

## Directory Structure

```
omnibioai-data/
├── datasets/               # User datasets (not tracked)
├── downloads/              # Downloaded files (not tracked)
├── uploads/                # User uploads (not tracked)
├── results/                # Analysis results (not tracked)
├── reports/                # Generated reports (not tracked)
├── logs/                   # Application logs (not tracked)
├── cache/                  # Cached data (not tracked)
├── igv_snapshots/          # IGV genome browser snapshots (not tracked)
├── single_cell/            # Single-cell analysis data (not tracked)
├── omni_object_storage/    # OmniBioAI object storage (not tracked)
├── omni_objects/           # OmniBioAI objects (not tracked)
├── objects/                # Runtime objects (not tracked)
├── PubMed/                 # PubMed cache (not tracked)
├── reference/              # Reference genomes/annotations (not tracked)
├── tool-images/            # Tool container images (not tracked)
├── omnibioai-tool-images/  # OmniBioAI tool images (not tracked)
├── local_registry/         # Local model/tool registry (not tracked)
├── object_registry.json    # Object registry index
├── workflow_registry.json  # Workflow registry index
└── sample files            # Sample data files for testing
```

## Sample Files

Small sample files are included for testing and development:

| File | Description |
|------|-------------|
| `sample1.csv` | Sample expression matrix |
| `sample2.csv` | Sample expression matrix |
| `sample1_normalize.csv` | Normalized expression matrix |
| `sample2_normalize.csv` | Normalized expression matrix |
| `sample_annotations.gff3` | Sample genome annotations (GFF3) |
| `sample_annotations.tsv` | Sample annotations (TSV) |
| `sample_regions.bed` | Sample genomic regions (BED) |
| `sample_sequences.fasta` | Sample sequences (FASTA) |

## Setup

This directory is referenced in the OmniBioAI docker-compose stack via the `DATA_DIR` environment variable:

```env
DATA_DIR=/home/manish/Desktop/machine/omnibioai-data
```

On first run, create the required runtime directories:

```bash
mkdir -p datasets downloads uploads results reports logs cache \
         igv_snapshots single_cell omni_object_storage omni_objects \
         objects PubMed reference tool-images omnibioai-tool-images \
         local_registry
```

## Related Repositories

- [`omnibioai`](../omnibioai) — main Django workbench application
- [`omnibioai-tes`](../omnibioai-tes) — task execution service
- [`omnibioai-tool-images`](../omnibioai-tool-images) — tool container image definitions
- [`omnibioai-db-init`](../omnibioai-db-init) — database initialization scripts