genome_dir=/share/home/qiugl/xie/alphafold_test/genome
output_dir=/share/home/qiugl/xie/alphafold_test/output
python_dir=/share/home/qiugl/xie/alphafold_test/python_script
DeepFRI_dir=/share/home/qiugl/xie/alphafold_test/deepfri
uniprot_ref_table=/share/home/qiugl/xie/alphafold_test/python_script/3/uniprot.tsv


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
mv 1_OrthoFinder/Results/WorkingDirectory/OrthoFinder/Results*/Orthogroups/Orthogroups.tsv 2_Orthorgroup
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
