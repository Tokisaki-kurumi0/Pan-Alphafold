#!/usr/bin/env python
# coding: utf-8

# In[63]:


import pandas as pd 
import numpy as np
import argparse
import os
parser= argparse.ArgumentParser(description="process orthogroup.tsv",formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("-a","--afile" ,help="orthout.txt")
parser.add_argument("-b","--bfile" ,help="all.txt")
parser.add_argument("-o","--outputdir" ,help="the dir contain file you want to change name")

args = parser.parse_args()

path1 = args.afile
path2 = args.bfile
orth=pd.read_csv(path1,sep='\t',header=None,low_memory=False,index_col=0)
faa=pd.read_csv(path2,sep='\t',header=None,low_memory=False)


# In[60]:


faa_code = faa.set_index([0])[1].to_dict()# extract two columns two dictionary


# In[70]:


orth_rp=orth.stack().map(faa_code).unstack().replace(np.nan,'') # this function can replace all data with a dictionary


# In[72]:

output = os.path.join(args.outputdir,"final_result.csv")
orth_rp.to_csv(output,header=False, sep='\t')

print("finish")
# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




