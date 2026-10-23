import numpy as np



data_A = np.loadtxt("bv_ref.txt")


data_B = np.loadtxt("pheno.txt")

######## Add gv_ref.txt when necessary

var_A = np.var(data_A, ddof=1) 
var_B = np.var(data_B, ddof=1) 

# ?? var(A) / var(B)
h2 = var_A / var_B

# ????
print(f"Variance of A: {var_A}")
print(f"Variance of B: {var_B}")
print(f"h2	{h2}")