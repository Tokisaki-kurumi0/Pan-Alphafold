import pandas as pd
import os
import argparse
parser = argparse.ArgumentParser(description="this script is to process uniprotfile and deepfriresult")
parser.add_argument("-i","--input1",help="input orthorfinder final result table")
parser.add_argument("-d","--deepfri",help="deepfritable contain all data")
parser.add_argument("-f","--fxtab",help="fx2tab_allprotein table")
parser.add_argument("-o","--output",help="output file dir")
args =parser.parse_args()
orthtable = args.input1
faa_protein = args.fxtab
deepfree_table = args.deepfri
outdir = args.output

# process othor finder table
wide_ortho = pd.read_csv(orthtable,sep="\s+",header=None)
long_ortho = pd.melt(wide_ortho,id_vars=[0]).sort_values(by=0).dropna(subset="value")
long_ortho.columns = ["orthorgroup","waste","locus_tag"]
long_ortho = long_ortho.loc[:,["orthorgroup","locus_tag"]]

#process protein table
faa_table = pd.read_csv(faa_protein,sep="\t",header=None,names=["id","sequence","re"])
faa_table = faa_table.loc[:,["id","sequence"]]
faa_table["locus_tag"] = faa_table.loc[:,"id"].apply(lambda x: x.split("[locus_tag=")[1].split("]")[0])
faa_table["faa_protein"] = faa_table.loc[:,"id"].apply(lambda x: x.split("[protein=")[1].split("]")[0] if "[protein=" in x else None)


# merge othorfinder and process table
merge_table = pd.merge(long_ortho,faa_table,on="locus_tag",how="left")
deepfri_table = pd.read_csv(deepfree_table,sep=",")
deepfri_table = deepfri_table[["locus","GO_term/EC_number name"]]
deepfri_table.columns = ["locus_tag","deepfri_protein"]

merge_table = pd.merge(merge_table,deepfri_table,on="locus_tag",how="left")

choose_table = merge_table.copy()
choose_table = choose_table.loc[:,["orthorgroup","locus_tag","sequence","faa_protein","deepfri_protein"]]
choose_table["protein_decision"] = choose_table.apply(lambda row : row["faa_protein"] if row["faa_protein"] != "hypothetical protein" else row["deepfri_protein"],axis=1)


#fill protein lack
fillna_tab = pd.DataFrame(columns=choose_table.columns)
fillna_tab.columns = ["orthorgroup","locus_tag","sequence","faa_protein","deepfri_protein","protein_decision"]

row_index = choose_table["orthorgroup"].unique()
for i,c in enumerate(row_index):
    tempt_table = choose_table[choose_table["orthorgroup"] == row_index[i]].copy()
    mode_result = tempt_table["protein_decision"].mode()
    most_frequent_value = mode_result.iloc[0] if not mode_result.empty else None
    most_frequent_value = mode_result.iloc[0] if not mode_result.empty else None
    if most_frequent_value is not None:
        tempt_table.loc[:, "protein_decision"] = tempt_table["protein_decision"].fillna(most_frequent_value)
        #tempt_table.loc[:, "protein_decision"] = tempt_table.loc[:, "protein_decision"].fillna(most_frequent_value)
    else:
        pass

    fillna_tab = pd.concat([fillna_tab, tempt_table], ignore_index=True)



# store choose table, without fill na
choose_table["sequence"]=choose_table["sequence"].str.replace("-", "")
choose_table.to_csv(os.path.join(outdir,"without_fill.csv"),index=False)

#store fillnatable
fillna_tab["sequence"]=fillna_tab["sequence"].str.replace("-", "")
fillna_tab.to_csv(os.path.join(outdir,"na_fill.csv"),index=False)

#faa file table
faa_fileout = fillna_tab.loc[:,["locus_tag","protein_decision","sequence"]]
faa_fileout["protein_decision"] = faa_fileout["protein_decision"].fillna("unknow")
faa_fileout["label"] = faa_fileout.apply(lambda row: "~~~".join([row["locus_tag"], row["protein_decision"]]), axis=1)
faa_fileout = faa_fileout.loc[:,["label","sequence"]]

faa_fileout.to_csv(os.path.join(outdir,"faa_fileout.csv"),index=False,header=None,sep="\t")
