# omnibioai-data

Runtime data directory for the OmniBioAI platform. This repository contains the directory structure, sample files, and registry configuration needed to bootstrap a local OmniBioAI instance.

Large runtime files (datasets, uploads, results, cached data, tool images) are excluded from version control via `.gitignore`. The directory structure is preserved via `.gitkeep` files.

**v0.4.0-beta** — full reference genome registry (14 organisms), alignment indexes, variant databases, and AI knowledge base (35M+ PubMed abstracts, 108 FAISS indexes).

## Data Scale

| Category | Size |
|----------|------|
| Reference genomes & indexes | ~416 GB |
| PubMed abstracts & FAISS indexes | ~195 GB |
| **Total** | **~611 GB** |

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
├── reference/              # Reference genomes & annotations (not tracked)
│   ├── organisms/          # 14 organism genomes
│   ├── indexes/            # STAR, BWA, Bowtie2, Salmon, CellRanger
│   ├── variants/           # ClinVar, dbSNP, gnomAD, COSMIC
│   ├── databases/          # GO, InterPro, Pfam, UniProt
│   └── annotation/         # Ensembl, GENCODE, RefSeq, UCSC
├── PubMed/                 # AI knowledge base (not tracked)
│   ├── Abstracts/          # 35M+ PubMed abstracts (141 domains)
│   └── Index/              # FAISS vector indexes (108 domains, 8 GB)
├── scripts/                # Download and utility scripts
├── tool-images/            # Tool container images (not tracked)
├── omnibioai-tool-images/  # OmniBioAI tool images (not tracked)
├── local_registry/         # Local model/tool registry (not tracked)
├── object_registry.json    # Object registry index
├── workflow_registry.json  # Workflow registry index
└── sample files            # Sample data files for testing
```

## Reference Genomes

14 organism genomes are stored under `reference/organisms/`, each at the canonical assembly version used by the platform.

| Organism | Assembly |
|----------|----------|
| Human | GRCh37, GRCh38, T2T-CHM13 |
| Mouse | GRCm38, GRCm39 |
| Rat | GRCr8 |
| Zebrafish | GRCz11 |
| Drosophila | BDGP6 |
| Yeast | R64 |
| Chimpanzee | Pan_tro_3.0 |
| Macaque | Mmul_10 |
| *C. elegans* | WBcel235 |
| Arabidopsis | TAIR10 |
| Pig | Sscrofa11.1 |
| Chicken | GRCg7b |

## Alignment Indexes

Pre-built indexes are stored under `reference/indexes/`.

| Index | Organisms |
|-------|-----------|
| STAR | All 14 organisms |
| BWA | All 14 organisms |
| Bowtie2 | All 14 organisms |
| Salmon | All 14 organisms |
| CellRanger (2024-A) | Human only |

> **Note:** The zebrafish (GRCz11) STAR index requires ~141GB RAM
> to build and cannot be generated on the DGX Spark (128GB).
> Zebrafish RNA-seq users should use Salmon (available) or
> Bowtie2 (available) for alignment. The STAR index will be
> added post-launch when built on a higher-memory instance.

## Variant Databases

Variant files are stored under `reference/variants/`.

| Database | Build | Size |
|----------|-------|------|
| ClinVar | GRCh38 | 184 MB |
| dbSNP (latest) | GRCh38 | 28 GB |
| gnomAD v4.0 chr1 | GRCh38 | 65 GB |
| COSMIC v104 | GRCh37 | 1.1 GB |
| COSMIC v104 | GRCh38 | 1.1 GB |
| GATK bundle (Mills + 1000G) | GRCh38 | — |

> **Note:** COSMIC download requires a registered account at [cancer.sanger.ac.uk](https://cancer.sanger.ac.uk). See `scripts/download_cosmic.sh` for the authenticated download workflow.

## Functional Databases

Protein and functional annotation databases are stored under `reference/databases/`.

- **GO** — Gene Ontology
- **InterPro** — protein family and domain signatures
- **Pfam** — protein family database
- **UniProt** — reviewed and unreviewed protein sequences

Genome annotations (Ensembl, GENCODE, RefSeq, UCSC) are stored under `reference/annotation/`.

## AI Knowledge Base

The `PubMed/` subtree provides a local biomedical AI knowledge base for RAG-powered queries within OmniBioAI.

| Component | Details |
|-----------|---------|
| Abstracts | 35M+ PubMed abstracts across 141 biomedical domains |
| FAISS indexes | 108 domain-specific vector indexes, 8.15 GB total |
| Embedding model | `mxbai-embed-large` |

Indexes are built per domain and queried at inference time by the OmniBioAI retrieval pipeline.

## Scripts

Download and utility scripts are stored under `scripts/`.

| Script | Purpose |
|--------|---------|
| `scripts/download_cosmic.sh` | Authenticated COSMIC v104 download (GRCh37 + GRCh38) |
| `scripts/download_references.py` | Reference genome downloader for all 14 organisms |
| `scripts/download_pubmed.sh` | PubMed abstracts bulk downloader |

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
         objects tool-images omnibioai-tool-images local_registry \
         reference/organisms reference/indexes reference/variants \
         reference/databases reference/annotation \
         PubMed/Abstracts PubMed/Index \
         scripts
```

### Reference Genomes

Download reference genomes for all supported organisms:

```bash
python scripts/download_references.py --all --outdir reference/organisms
```

To download a single organism:

```bash
python scripts/download_references.py --organism human --assembly GRCh38 \
    --outdir reference/organisms
```

### Building Indexes

After downloading genomes, build alignment indexes:

```bash
# STAR index (example — human GRCh38)
STAR --runMode genomeGenerate \
     --genomeDir reference/indexes/star/human_GRCh38 \
     --genomeFastaFiles reference/organisms/human/GRCh38/genome.fa \
     --sjdbGTFfile reference/annotation/human/GRCh38/genes.gtf \
     --runThreadN 16

# Salmon index
salmon index \
    -t reference/organisms/human/GRCh38/transcriptome.fa \
    -i reference/indexes/salmon/human_GRCh38
```

### COSMIC Variant Database

COSMIC requires a registered account. Set your credentials before running the download script:

```bash
export COSMIC_EMAIL="your@email.com"
export COSMIC_PASSWORD="your-password"
bash scripts/download_cosmic.sh
```

## Related Repositories

- [`omnibioai`](../omnibioai) — main Django workbench application
- [`omnibioai-tes`](../omnibioai-tes) — task execution service
- [`omnibioai-tool-images`](../omnibioai-tool-images) — tool container image definitions
- [`omnibioai-db-init`](../omnibioai-db-init) — database initialization scripts
