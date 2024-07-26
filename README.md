![pipeline_Page1](https://github.com/user-attachments/assets/2f720de7-c55e-40fa-9d08-a9bc78f966ac)

# Pan-Alphafold
## Introduction to Pan-Alphafold
Pan-Alphafold is a comprehensive pipeline designed to enhance the functional annotation of protein sequences using both sequence-based and structure-based methods. This pipeline integrates various tools and processes to systematically process and annotate protein sequences from different sources, providing a deeper understanding of their functions.
## Table of Contents
### ·Features
Integrates multiple tools for comprehensive protein annotation.  
Combines sequence-based and structure-based methods.  
Provides enhanced protein function characterization.  
### ·Requirements  
Conda  
Tools: Prokka, Orthofinder, Openbabel, DeepFRI, Jupyter, Seqkit
### ·Installation  
Clone the repository:
```
git clone https://github.com/Tokisaki-kurumi0/Pan-Alphafold.git  
cd Pan-Alphafold
```

Create different conda environment and install dependencies:  
```
conda create --name pan-alphafold python=3.10  
conda activate pan-alphafold
conda install -c conda-forge prokka orthofinder openbabel jupyter seqkit
```
The installation of DeepFRI can refer to https://github.com/flatironinstitute/DeepFRI

### ·Usage  
   ·Input Data  
   Prepare the following input data:
```
genome_dir=/PATH/TO/genome (Genome storage path .faa)
output=/PATH/TO/output (Output path)
python_dir=/PATH/TO/python_script (Python script path)
DeepFRI_dir=/PATH/TO/deepfri (Protein structure file path .gz)  
uniprot_ref_table=/PATH/TO/python_script/3/uniprot.tsv (Uniprot file path)
```

### Pipeline Steps
1.Orthofinder (Run 1.sh)
Purpose: Perform homologous genome analysis and generate final result files (.tsv).
```
bash 1.sh
```
2.Openbabel (Run 2.sh)
Purpose: Extract Alphafold raw data and convert structure files (cif to pdb).
```
bash 2.sh
```
3.DeepFRI (Run 3.sh)
Purpose: Perform structure function annotation.
```
bash 3.sh
```
4.Jupyter (Run 4.sh)
Purpose: Process DeepFRI prediction results, match NCBI with Uniprot database, and generate unified results.
```
bash 4.sh
```
5.Seqkit (Run 5.sh)
Purpose: Convert all protein sequences to tab format and integrate DeepFRI prediction results.
```
bash 5.sh
```
6.Final Results Generation (Run 6.sh)
Purpose: Integrate all data, create final result files, and generate Fasta format sequence files.
```
bash 6.sh
```
To predict a genome structure alone, run 7 and 8.sh
7.Bin Annotation (Run 7.sh) 
Purpose: Predict ORFs using Prokka and perform NR Database annotation.
```
bash 7.sh
```
8.Alphafold Prediction (Run 8.sh)
Purpose: Predict user custom sequences.
```
bash 8.sh
```

