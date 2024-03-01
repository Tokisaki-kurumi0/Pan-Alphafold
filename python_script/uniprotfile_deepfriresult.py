import pandas as pd
import os
import argparse
parser = argparse.ArgumentParser(description="this script is to process uniprotfile and deepfriresult")
parser.add_argument("-i","--input",help="input deepfri file")
parser.add_argument("-r","--refer",help="reference output file")
parser.add_argument("-o","--output",help="output file dir")
args =parser.parse_args()

#process unitable
uni_table = pd.read_csv(args.refer,sep="\t")[["Entry","Gene Names","Protein names"]]
uni_table["Gene Names"] =uni_table["Gene Names"].astype(str)
uni_table["locus"] = uni_table.loc[:,"Gene Names"].apply(lambda x : x.split(" ")[-1])


#process deepfritable
deepfri_result = pd.read_csv(args.input,sep=",",skiprows=1)
#sort by score
deepfri_result = deepfri_result.sort_values(by="Score",ascending=False)
#just keep highest value
deepfri_result = deepfri_result.drop_duplicates(subset="Protein")

deepfri_result["Entry"] = deepfri_result.loc[:,"Protein"].apply(lambda x: x.split("-")[1])


output = pd.merge(deepfri_result,uni_table,on="Entry")
output.to_csv(args.output,index=False)