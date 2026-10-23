import numpy as np

data_A = np.loadtxt("gv_ref.txt")
data_B = np.loadtxt("residual_ref.txt")
data_C = np.loadtxt("pheno.txt")
data_D = np.loadtxt("gv_young.txt")
data_E = np.loadtxt("residual_young.txt")
data_F = np.loadtxt("pheno_young.txt")

######## Add gv_ref.txt when necessary

var_A = np.var(data_A, ddof=1) 
var_B = np.var(data_B, ddof=1)
var_C = np.var(data_C, ddof=1)
var_D = np.var(data_D, ddof=1) 
var_E = np.var(data_E, ddof=1)
var_F = np.var(data_F, ddof=1)


h2_ref = var_A / var_C
h2_young = var_D / var_F

print(f"Genetic Variance of Ref: {var_A}")
print(f"Residual Variance of Ref: {var_B}")
print(f"Phenotypic Variance of Ref: {var_C}")
print(f"Genetic Variance of Young: {var_D}")
print(f"Residual Variance of Young: {var_E}")
print(f"Phenotypic Variance of Young: {var_F}")

print(f"h2_ref:	{h2_ref}")
print(f"h2_young: {h2_young}")