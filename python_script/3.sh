genome_dir=/share/home/qiugl/xie/alphafold_test/genome
output_dir=/share/home/qiugl/xie/alphafold_test/output
python_dir=/share/home/qiugl/xie/alphafold_test/python_script
DeepFRI_dir=/share/home/qiugl/xie/alphafold_test/deepfri
uniprot_ref_table=/share/home/qiugl/xie/alphafold_test/python_script/3/uniprot.tsv
echo "please input the path to DeepFri predict.py "
read deepfri_path
source conda/pwd/bin/activate
conda activate deepfri
cd
cd $deepfri_path


for file in $output_dir/3_deepfri_raw_dataprocess/*
do
bsnm=$(basename $file)

time python predict.py --pdb_dir $file/pdb -ont mf  -v -o $file/deepfri_result/$bsnm
done
conda deactivate
