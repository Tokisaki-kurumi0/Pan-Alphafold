#Input path
echo "please input the genome storage path"
read genome_dir
echo "please input the out put path"
read output_dir
echo "please input python file path"
read python_dir
echo "please input the protein structure file"
read DeepFRI_dir
echo "please input the Uniprot file path "
read uniprot_ref_table
echo "please input the path to DeepFri predict.py "
read deepfri_path


env_name="orthofinder"

if conda info --envs | grep -q "$env_name"; then
    echo "enviroment '$env_name' exsist,skip install."
else
    echo "enviroment '$env_name' do not exsist，installing..."
    conda create --name $env_name -y -c bioconda orthofinder
fi
cd
source conda/pwd/bin/activate
conda activate orthofinder

orthofinder -t 32 -a 32 -f $genome_dir -op -S blast

mv -f $genome_dir/OrthoFinder $output_dir/1_OrthoFinder

othor_end=$(( $(ls "$genome_dir" | wc -l) - 1 ))

cd $output_dir
mv -f 1_OrthoFinder/Results* 1_OrthoFinder/Results

for out in $(seq 0 "$othor_end")

do

for int in $(seq 0 "$othor_end")
                                                                        
do
echo$int
echo$out
blastp -num_threads 32 -db 1_OrthoFinder/Results/WorkingDirectory/BlastDBSpecies${out} -query 1_OrthoFinder/Results/WorkingDirectory/Species${int}.fa -outfmt "6  qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovs" -evalue 1e-5 -seg yes -soft_masking true -use_sw_tback > 1_OrthoFinder/Results/WorkingDirectory/unBlast${int}_${out}.txt
awk '$3>70 && $13 > 75 {print}' 1_OrthoFinder/Results/WorkingDirectory/unBlast${int}_${out}.txt > 1_OrthoFinder/Results/WorkingDirectory/Blast${int}_${out}.txt

done
done

orthofinder -t 32 -a 32 -b 1_OrthoFinder/Results/WorkingDirectory -op -S blast -M msa -A mafft -T fasttree -I 1.1

mkdir 2_Orthorgroup

mv 1_OrthoFinder/Results/WorkingDirectory/OrthoFinder/Results*/Orthogroups/Orthogroups.tsv 2_Orthorgroup/assignedGenes.tsv
mv 1_OrthoFinder/Results/WorkingDirectory/OrthoFinder/Results*/Orthogroups/Orthogroups_UnassignedGenes.tsv 2_Orthorgroup
cat $output_dir/2_Orthorgroup/assignedGenes.tsv.tsv $output_dir/2_Orthorgroup/Orthogroups_UnassignedGenes.tsv > $output_dir/2_Orthorgroup/Orthogroups.tsv
#modify
conda activate base
#this env should contain pandas and numpy,refer to xxj_step_1.py
python $python_dir/process_orthogroup.py -i 2_Orthorgroup/Orthogroups.tsv

mv orthout.csv 2_Orthorgroup
###refer to xxj_step_2.sh
for i in $genome_dir/*.faa;
do
bsnm=$(basename $i)
echo $bsnm
grep '>' $i | tr ' ' '\n'| grep '>lcl' > 2_Orthorgroup/new1.txt
grep '>' $i | tr ' ' '\n'| grep 'locus_tag' > 2_Orthorgroup/new2.txt
paste 2_Orthorgroup/new1.txt 2_Orthorgroup/new2.txt | sed 's/\]//g' | sed 's/\[locus_tag=//g' | sed 's/>//g' >2_Orthorgroup/$bsnm.txt
done

cat 2_Orthorgroup/*.faa.txt > 2_Orthorgroup/all.txt

python $python_dir/merge_orthogroup.py -a 2_Orthorgroup/orthout.csv -b 2_Orthorgroup/all.txt -o $output_dir
 mv final_result.csv 2_Orthorgroup

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

#4 step
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

#5 step
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

#6 step
cd
mkdir $output_dir/6_final_result
python $python_dir/last.py -i $output_dir/2_Orthorgroup/final_result.csv -d $output_dir/5_fx2tab_allprotein/deepfri_allprotein.csv -f $output_dir/5_fx2tab_allprotein/fx2tab_allprotein.csv -o $output_dir/6_final_result

source conda/pwd/bin/activate
conda activate seqkit
seqkit tab2fx $output_dir/6_final_result/faa_fileout.csv > $output_dir/6_final_result/faafile_finalout.fasta

