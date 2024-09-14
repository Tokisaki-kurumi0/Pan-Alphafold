#!/bin/bash

# Activate conda environment
source ~/conda/bin/activate
conda activate alphafold

# Set variables with direct assignment (modify these paths as needed)
PROKKA_OUTPUT_DIR="/path/to/prokka_output"
EXTRACTED_FASTA_DIR="/path/to/extracted_sequences"
SPLIT_FASTA_DIR="/path/to/split_sequences"
SEQUENCE_IDS="/path/to/sequence.txt"
ALPHAFOLD_OUTPUT_DIR="/path/to/alphafold_output"
ALPHAFOLD_SCRIPT_DIR="/path/to/alphafold-2.3.1"
ALPHAFOLD_DATA_DIR="/path/to/alphafold_data"
ALPHAFOLD_RUN_SCRIPT="$ALPHAFOLD_SCRIPT_DIR/run_alphafold.sh"  # AlphaFold run script path
NUM_THREADS=8
DATE=$(date +%Y-%m-%d)

# Create output directories if they don't exist
mkdir -p "$EXTRACTED_FASTA_DIR"
mkdir -p "$SPLIT_FASTA_DIR"
mkdir -p "$ALPHAFOLD_OUTPUT_DIR"

# Create Python script for extracting sequences
python_script=$(cat <<EOF
import sys
from Bio import SeqIO

def extract_sequences(fasta_file, ids_file, output_file):
    # Read sequence IDs
    with open(ids_file) as f:
        ids = set(line.strip() for line in f)

    # Parse the fasta file and extract sequences
    sequences = SeqIO.parse(fasta_file, "fasta")
    selected_sequences = (seq for seq in sequences if seq.id in ids)

    # Write selected sequences to output
    SeqIO.write(selected_sequences, output_file, "fasta")

if __name__ == "__main__":
    fasta_file = sys.argv[1]
    ids_file = sys.argv[2]
    output_file = sys.argv[3]
    extract_sequences(fasta_file, ids_file, output_file)
EOF
)

echo "$python_script" > extract_sequences.py

# Extract sequences
for prokka_dir in "$PROKKA_OUTPUT_DIR"/*; do
    bin_basename=$(basename "$prokka_dir")
    fasta_file="$prokka_dir/${bin_basename}.faa"
    output_fasta="$EXTRACTED_FASTA_DIR/${bin_basename}.fasta"
    python extract_sequences.py "$fasta_file" "$SEQUENCE_IDS" "$output_fasta"
done

echo "Sequence extraction complete. Preparing to split multi-sequence FASTA files."

# Create Python script for splitting multi-sequence FASTA files
split_fasta_script=$(cat <<EOF
import sys
from Bio import SeqIO

def split_fasta(input_fasta, output_dir):
    records = list(SeqIO.parse(input_fasta, "fasta"))
    for i, record in enumerate(records):
        SeqIO.write(record, f"{output_dir}/{record.id}.fasta", "fasta")

if __name__ == "__main__":
    input_fasta = sys.argv[1]
    output_dir = sys.argv[2]
    split_fasta(input_fasta, output_dir)
EOF
)

echo "$split_fasta_script" > split_fasta.py

# Split multi-sequence FASTA files
for extracted_fasta in "$EXTRACTED_FASTA_DIR"/*.fasta; do
    python split_fasta.py "$extracted_fasta" "$SPLIT_FASTA_DIR"
done

echo "Splitting of multi-sequence files complete. Preparing for structure prediction."

# Run AlphaFold predictions
for fasta_file in "$SPLIT_FASTA_DIR"/*.fasta; do
    temp_name=$(basename "$fasta_file" .fasta)
    bash "$ALPHAFOLD_RUN_SCRIPT" -d "$ALPHAFOLD_DATA_DIR" -o "$ALPHAFOLD_OUTPUT_DIR/${temp_name}" -f "$fasta_file" -t "$DATE" -g false
done

echo "Structure prediction complete."
