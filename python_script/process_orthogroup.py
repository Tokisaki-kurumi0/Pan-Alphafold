#!/usr/bin/env python
# coding: utf-8

# In[2]:
import pandas as pd
import numpy as np
import argparse

parser= argparse.ArgumentParser(description="process orthogroup.tsv",formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("-i","--input" ,help="the dir contain file you want to change name")
args = parser.parse_args()
#xxj_first_step
     #import pandas and np

    #print("please input the file name, if you don not change, the name is 'Orthogroups.tsv'")
path = args.input# set input file
test=pd.read_csv(path,sep='\t',header=0,low_memory=False) #read file, header=0 mean keep colomn name
    #test2=test.astype(str)  force transform
test[:].fillna(",",inplace=True) #replace nan to ,_ this is for sequence split
test=test.astype(str)#force transform
test['columaA']=test[test.columns[1:]].apply(lambda x: ', ' .join(x.dropna().astype(str)),
        axis=1)#
df_b_sp=test[['Orthogroup','columaA']]
df_b_sp=test[['Orthogroup','columaA']]#extract two line from below dataframe
df_a_sp=df_b_sp['columaA'].astype(str).str.split(', ',expand=True)#splite column with
df_rp=df_a_sp.astype(str).replace([',','None'],'')
df_rp.insert(0,'Orthogroup',test['Orthogroup'])
df_rp.to_csv("orthout.csv",index=None,header=False, sep='\t')

