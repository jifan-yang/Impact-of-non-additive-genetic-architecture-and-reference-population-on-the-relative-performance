import numpy as np

data_A = np.loadtxt("gv_11.txt")
data_B = np.loadtxt("gv_12.txt")
data_C = np.loadtxt("gv_13.txt")
data_D = np.loadtxt("gv_14.txt")
data_E = np.loadtxt("gv_15.txt")
data_E1 = np.loadtxt("gv_young.txt")


data_F = np.loadtxt("residual_11.txt")
data_G = np.loadtxt("residual_12.txt")
data_H = np.loadtxt("residual_13.txt")
data_I = np.loadtxt("residual_14.txt")
data_J = np.loadtxt("residual_15.txt")
data_J1 = np.loadtxt("residual_young.txt")

data_K = np.loadtxt("pheno_11.txt")
data_L = np.loadtxt("pheno_12.txt")
data_M = np.loadtxt("pheno_13.txt")
data_N = np.loadtxt("pheno_14.txt")
data_O = np.loadtxt("pheno_15.txt")
data_O1 = np.loadtxt("pheno_young.txt")


######## Add gv_ref.txt when necessary

var_A = np.var(data_A, ddof=1) 
var_B = np.var(data_B, ddof=1)
var_C = np.var(data_C, ddof=1)
var_D = np.var(data_D, ddof=1) 
var_E = np.var(data_E, ddof=1)
var_F = np.var(data_F, ddof=1)
var_G = np.var(data_G, ddof=1) 
var_H = np.var(data_H, ddof=1)
var_I = np.var(data_I, ddof=1)
var_J = np.var(data_J, ddof=1) 
var_K = np.var(data_K, ddof=1)
var_L = np.var(data_L, ddof=1)
var_M = np.var(data_M, ddof=1) 
var_N = np.var(data_N, ddof=1)
var_O = np.var(data_O, ddof=1)

var_E1 = np.var(data_E1, ddof=1) 
var_J1 = np.var(data_J1, ddof=1)
var_O1 = np.var(data_O1, ddof=1)



h2_11 = var_A / var_K
h2_12= var_B / var_L
h2_13 = var_C / var_M
h2_14= var_D / var_N
h2_15 = var_E / var_O
h2_16 = var_E1 / var_O1


print(f"Genetic Variance of Gen 11: {var_A}")
print(f"Genetic Variance of Gen 12: {var_B}")
print(f"Genetic Variance of Gen 13: {var_C}")
print(f"Genetic Variance of Gen 14: {var_D}")
print(f"Genetic Variance of Gen 15: {var_E}")
print(f"Genetic Variance of Gen 16: {var_E1}")

print(f"Residual Variance of Gen 11: {var_F}")
print(f"Residual Variance of Gen 12: {var_G}")
print(f"Residual Variance of Gen 13: {var_H}")
print(f"Residual Variance of Gen 14: {var_I}")
print(f"Residual Variance of Gen 15: {var_J}")
print(f"Residual Variance of Gen 16: {var_J1}")

print(f"Phenotypic Variance of Gen 11: {var_K}")
print(f"Phenotypic Variance of Gen 12: {var_L}")
print(f"Phenotypic Variance of Gen 13: {var_M}")
print(f"Phenotypic Variance of Gen 14: {var_N}")
print(f"Phenotypic Variance of Gen 15: {var_O}")
print(f"Phenotypic Variance of Gen 16: {var_O1}")

print(f"h2_11: {h2_11}")
print(f"h2_12: {h2_12}")
print(f"h2_13: {h2_13}")
print(f"h2_14: {h2_14}")
print(f"h2_15: {h2_15}")
print(f"h2_16: {h2_16}")
