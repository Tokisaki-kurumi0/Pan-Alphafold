genome_dir=/share/home/qiugl/xie/alphafold_test/genome
output_dir=/share/home/qiugl/xie/alphafold_test/output
python_dir=/share/home/qiugl/xie/alphafold_test/python_script
DeepFRI_dir=/share/home/qiugl/xie/alphafold_test/deepfri
uniprot_ref_table=/share/home/qiugl/xie/alphafold_test/python_script/3/uniprot.tsv

env_name="jupyter"

if conda info --envs | grep -q "$env_name"; then
    echo "enviroment '$env_name' exsist,skip install."
else
    echo "enviroment '$env_name' do not exsist，installing..."
    conda create --name $env_name -y -c conda-forge jupyter
fi

source conda/pwd/bin/activate
conda activate jupyter

cd $output_dir
mkdir -p 4_deepfri_uniprot

for file in $output_dir/3_deepfri_raw_dataprocess/*;
do
bsnm=$(basename $file)
echo $bsnm
echo $file
mkdir -p 4_deepfri_uniprot/$bsnm
python $python_dir/uniprotfile_deepfriresult.py -i $file/deepfri_result/*.csv -r $uniprot_ref_table -o 4_deepfri_uniprot/$bsnm/$bsnm.csv
done
