genome_dir=/share/home/qiugl/xie/alphafold_test/genome
output_dir=/share/home/qiugl/xie/alphafold_test/output
python_dir=/share/home/qiugl/xie/alphafold_test/python_script
DeepFRI_dir=/share/home/qiugl/xie/alphafold_test/deepfri
uniprot_ref_table=/share/home/qiugl/xie/alphafold_test/python_script/3/uniprot.tsv

env_name="seqkit"

if conda info --envs | grep -q "$env_name"; then
    echo "enviroment '$env_name' exsist,skip install."
else
    echo "enviroment '$env_name' do not exsist，installing..."
    conda create --name $env_name -y -c bioconda seqkit
fi
cd
source conda/pwd/bin/activate
conda activate seqkit
cd $output_dir
mkdir $output_dir/5_fx2tab_allprotein
for file in $genome_dir/*;
do
seqkit fx2tab $file >>$output_dir/5_fx2tab_allprotein/fx2tab_allprotein.csv
done

for file in $output_dir/4_deepfri_uniprot/*/*.csv;
do
cat $file >> $output_dir/5_fx2tab_allprotein/deepfri_allprotein.csv
done
conda deactivate
