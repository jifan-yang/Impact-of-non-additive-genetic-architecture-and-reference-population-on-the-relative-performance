using CSV 
using DataFrames
using DelimitedFiles
using Statistics

# set the script folder 
const scriptfp = string(ARGS[4], "/scripts")

include("$scriptfp/f_allelefrequencies.jl")
include("$scriptfp/f_readgeno.jl")

# argument variables #
const repl = ARGS[1]
const breed1 = ARGS[2]
const gen1 = parse(Int16, ARGS[3])

# other variables #
const gfile1 = String(breed1*"_mrk_qtl_"*repl*".txt")
const datfile1 = String(breed1*"_data_"*repl*"_reformat.dat")

# read data file 
dat1 = CSV.read(datfile1, DataFrame, delim=' ')

# filter on generation 
dat1 = dat1[dat1[:,:G] .== gen1,:]

# selected ids 
selids1 = convert(Array, dat1[:, :Progeny])

# read genotypes 
geno1, geno_phase1, nloc1, ids_geno1 = read_genotypes(gfile1, selids1)
nloc = size(geno1)[2]
GC.gc()

# compute allele frequencies #
p1 = getaf(geno1)

# write results to file
writedlm("$repl/allelefreq_"*breed1*"_$gen1.dat", p1, ' ')

