#!/usr/bin/env bash
# Creates required runtime directories on a fresh clone
set -e

dirs=(
  datasets
  downloads
  uploads
  results
  reports
  logs
  cache
  igv_snapshots
  single_cell
  omni_object_storage
  omni_objects
  objects
  PubMed
  reference
  tool-images
  omnibioai-tool-images
  local_registry
)

for d in "${dirs[@]}"; do
  mkdir -p "$d"
  touch "$d/.gitkeep"
done

echo "✓ Runtime directories created."