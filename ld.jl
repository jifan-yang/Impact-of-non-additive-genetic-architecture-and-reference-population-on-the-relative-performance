# Read simulated data from QMSim of 2 breeds
# compute the allele frequencies 
# Compute the correlation of LD phase using phased genotypes 

using CSV 
using Distributions
using DataFrames
using DelimitedFiles

# set the script folder 
const scriptfp = string(ARGS[5], "/scripts")

# include functions
include("$scriptfp/f_readgeno.jl")
include("$scriptfp/f_allelefrequencies.jl")
include("$scriptfp/f_comp_ld.jl")

# arguments
const repl = ARGS[1]
const breed1 = ARGS[2]
const gen1 = parse(Int16, ARGS[3])
const maxdist = parse(Int16, ARGS[4])
### max distance

const chrom = [1; 3; 5]

const datfile1 = String(breed1*"_data_"*repl*"_reformat.dat")
const gfile1 = String(breed1*"_mrk_qtl_"*repl*".txt")
const mapfile = String("lm_mrk_qtl_"*repl*".txt")

if !isdir(repl)
	mkdir(repl)
end

# read linkage map 
function readfile(fl)
	nline = countlines(fl)
	df = DataFrame(id = String[], chr = Int8[], pos = Float32[])
	
	f=open(fl)
	readline(f)
	for i in 1:(countlines(mapfile)-1)
		t = split(readline(f))
		a = t[[1]][1]
		b = parse(Int8, t[[2]][1])
		c = parse(Float32, t[[3]][1])
			
		push!(df, [a  b c])
	end
	close(f)
	return df
end

lmap = readfile(mapfile)

# read data file 
dat1 = CSV.read(datfile1, DataFrame, delim=' ')

# filter on generation 
dat1 = dat1[dat1[:,:G] .== gen1,:]

# selected ids 
selids1 = convert(Array, dat1[:, :Progeny])

# read genotypes 
geno1, geno_phase1, nloc1, ids1 = read_genotypes(gfile1, selids1, true, true)
GC.gc()

# calculate allele frequencies 
locinr = 1:nloc1
p1 = getaf(geno1)

# compute LD #
ldstats = compLD(geno1, lmap, chrom, p1, maxdist)

# write results 
ldstatsdf = DataFrame(ldstats, :auto)

CSV.write(string(repl, "/ld_", breed1, "_", gen1, "_", repl, ".dat"), ldstatsdf, header=false, delim=' ')

println("Done!")