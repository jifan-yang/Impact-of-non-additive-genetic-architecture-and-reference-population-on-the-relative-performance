#### sample loci to become qtl and markers ####
using CSV 
using DataFrames
using DelimitedFiles
using Distributions
using Statistics

# set the script folder 
const scriptfp = string(ARGS[9], "/scripts")

### include functions ### 
include("$scriptfp/f_readgeno.jl")
include("$scriptfp/f_allelefrequencies.jl")

###### argument variables ####
const repl = ARGS[1]
const nreqqtl = parse(Int64, ARGS[2])
const breed = ARGS[3]
const gen = parse(Int64, ARGS[4])

######
#### other variables ####
const datfile1 = String(breed*"_data_"*repl*"_reformat.dat")
const gfile1 = String(breed*"_mrk_qtl_"*repl*".txt")

### read data file ###
dat1 = CSV.read(datfile1, delim=' ')

### selected ids ####
selids1 = unique(convert(Array, dat1[dat1[:G] .== gen, :Progeny]))

### read genotypes 
geno1, geno_phase1, nloc1 = read_genotypes(gfile1, selids1, true, true)

GC.gc()

### calculate allele frequencies ####
locinr = 1:nloc1
p1 = getaf(geno1)  ### pb line 1

### sample qtl loci ###
qtlloci = sample(locinr, nreqqtl)

### write results ####
writedlm("qtlloci_"*repl*".dat", qtlloci,' ')
println("Finished sampling loci")
