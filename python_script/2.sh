genome_dir=/share/home/qiugl/xie/alphafold_test/genome
output_dir=/share/home/qiugl/xie/alphafold_test/output
python_dir=/share/home/qiugl/xie/alphafold_test/python_script
DeepFRI_dir=/share/home/qiugl/xie/alphafold_test/deepfri
uniprot_ref_table=/share/home/qiugl/xie/alphafold_test/python_script/3/uniprot.tsv

env_name="openbabel"

if conda info --envs | grep -q "$env_name"; then
    echo "enviroment '$env_name' exsist,skip install."
else
    echo "enviroment '$env_name' do not exsist，installing..."
    conda create --name $env_name -y -c conda-forge openbabel
fi
cd
source conda/pwd/bin/activate
conda activate openbabel
cd $output_dir
mkdir -p $output_dir/3_deepfri_raw_dataprocess
for file in $DeepFRI_dir/*.tar;
do
bsnm=$(basename $file .tar)
mkdir -p $output_dir/3_deepfri_raw_dataprocess/$bsnm
tar -xvf $file -C $output_dir/3_deepfri_raw_dataprocess/$bsnm
mkdir -p $output_dir/3_deepfri_raw_dataprocess/$bsnm/cif_file
mkdir -p $output_dir/3_deepfri_raw_dataprocess/$bsnm/json
mkdir -p $output_dir/3_deepfri_raw_dataprocess/$bsnm/pdb
mkdir -p $output_dir/3_deepfri_raw_dataprocess/$bsnm/deepfri_result
mv $output_dir/3_deepfri_raw_dataprocess/$bsnm/*cif.gz $output_dir/3_deepfri_raw_dataprocess/$bsnm/cif_file
mv $output_dir/3_deepfri_raw_dataprocess/$bsnm/*json.gz $output_dir/3_deepfri_raw_dataprocess/$bsnm/json

for file in $output_dir/3_deepfri_raw_dataprocess/$bsnm/cif_file/*.gz;
do
  gunzip "$file"
done

for file in $output_dir/3_deepfri_raw_dataprocess/$bsnm/cif_file/*;
do
    tmp_name=$(basename "$file" .cif)
  obabel ${file} -O $output_dir/3_deepfri_raw_dataprocess/$bsnm/pdb/${tmp_name}.pdb
done

done
