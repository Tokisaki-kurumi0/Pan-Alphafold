genome_dir=/share/home/qiugl/xie/alphafold_test/genome
output_dir=/share/home/qiugl/xie/alphafold_test/output
python_dir=/share/home/qiugl/xie/alphafold_test/python_script
DeepFRI_dir=/share/home/qiugl/xie/alphafold_test/deepfri
uniprot_ref_table=/share/home/qiugl/xie/alphafold_test/python_script/3/uniprot.tsv

cd
mkdir $output_dir/6_final_result
python $python_dir/last.py -i $output_dir/2_Orthorgroup/final_result.csv -d $output_dir/5_fx2tab_allprotein/deepfri_allprotein.csv -f $output_dir/5_fx2tab_allprotein/fx2tab_allprotein.csv -o $output_dir/6_final_result

source conda/pwd/bin/activate
conda activate seqkit
seqkit tab2fx $output_dir/6_final_result/faa_fileout.csv > $output_dir/6_final_result/faafile_finalout.fasta
