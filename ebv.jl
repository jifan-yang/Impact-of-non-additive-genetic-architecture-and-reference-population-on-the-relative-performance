# compute ebv for selection within lines
using CSV
using DataFrames
using Distributions
using DelimitedFiles
using LinearAlgebra

# set the script folder #
const scriptfp = string(ARGS[10], "/scripts")

# functions #
include("$scriptfp/f_readgeno.jl")
include("$scriptfp/f_allelefrequencies.jl")
include("$scriptfp/f_noia_gfreq.jl")
include("$scriptfp/f_epistasis.jl")  
include("$scriptfp/f_gfreq.jl")
include("$scriptfp/f_geteffects.jl")

# parameters #
const breed = ARGS[1]
const outfold = ARGS[2]
const domval = ARGS[3]
const epival = ARGS[4]
const epimodel = ARGS[5]
const lastgen = parse(Int64, ARGS[6])
const lastrep = parse(Int64, ARGS[7])
const h2 = parse(Float64, ARGS[8])
const qtlfolder = string(ARGS[10], "/", ARGS[9])

# read temp data #
dat1 = CSV.read("data_reformat.dat", DataFrame, delim=' ', header=true)
maxgen = maximum(dat1[:, :G])
id = convert(Array{Int64,1}, dat1[dat1[:, :G] .== maxgen, :Progeny])

println("Computing TBVs for generation $maxgen out of $lastgen")

# REPLICATE TRACKER: write a temp file to the directory to track what replicate we are working on #
if isfile("rep.tmp")
	repl = readdlm("rep.tmp",' ', Int8)[1]
else
	repl = 1
end

# write replicate tracker
repchar = lpad(string(repl),3,string(0))

f=open("rep.tmp", "w")
	write(f, repchar)
close(f)

# read genotypes
gfile = string("r_",outfold,"/",breed,"_mrk_qtl_",repchar,".txt")
geno, geno_phase, nloc = read_genotypes(gfile, id, true, true)

nread = size(geno)[1]
println("There were $nread genotypes read")

# get effects
a = convert(Array, readdlm(qtlfolder*"/a_"*repchar*".dat",' ', Float64))
d = convert(Array, readdlm(qtlfolder*"/d_"*repchar*".dat",' ', Float64))
epi_coef = convert(Array, readdlm(qtlfolder*"/e_"*repchar*".dat",' ', Float64))

nreqqtl = size(a)[1]

# epi combinations
epi_combinations = convert(Array, readdlm(qtlfolder*"/epi_combinations_"*repchar*".dat",' ', Int64))
epi_coef = epi_coef[1:size(epi_combinations)[1]]

# if this is generation 0, then remove the old files
if maxgen == 0
	rm("my_bv.txt", force=true)
	rm("all_bv.txt", force=true)
end

# list with loci nr
locinr = 1:(size(geno)[2])

# read qtl locations 
locfile = string(qtlfolder,"/qtlloci_", repchar,".dat")

if isfile(locfile)   # if there is a locfile, read it
	println("locfile found!")
 	qtlloci = convert(Array, readdlm(locfile, Int64)[:,1])
else # if not, sample loci 
	println("locfile NOT found! Sampling new loci")

	pall = getaf(geno)
	segregating = locinr[0.01 .< pall .< (0.99)]
	
	qtlloci = sample(segregating, nreqqtl, replace=false)
	writedlm(locfile, qtlloci, ' ')
end

# filter genotype matrix 
geno = geno[:,qtlloci]
p = getaf(geno)

# set fixed allele frequencies to an extreme frequency, so that the algorithm in epi() still works for all loci #
p[ p .== 1.0 ] .= 0.99999
p[ p .== 0.0 ] .= 0.00001

# compute genotype frequencies from random mating #
gfreq = get_gfreq(geno)

# get epistatic effects #
epi_vars, epi_effects = epi(gfreq, p, epi_coef, a, epimodel, epi_combinations)

# get alphas and ds #
alphas, ds = get_effects(a,d,p,epi_combinations, epi_effects)

# compute noia matrices #
noia, noia_dom = make_noia(geno, gfreq)

# breeding values and dominance deviations #
simbv = noia * alphas
simdom = noia_dom * ds

if epimodel == "none"
	aa = zeros(Float32, nread)
	ad = zeros(Float32, nread)
	da = zeros(Float32, nread)
	dd = zeros(Float32, nread)
else
	a1 = noia[:,epi_combinations[:,1]]
	a2 = noia[:,epi_combinations[:,2]]

	d1 = noia_dom[:,epi_combinations[:,1]]
	d2 = noia_dom[:,epi_combinations[:,2]]

	aa = a1 .* a2 * epi_effects[:,5]
	ad = a1 .* d2 * epi_effects[:,8]
	da = d1 .* a2 * epi_effects[:,6]
	dd = d1 .* d2 * epi_effects[:,9]
end

simtgv = simbv .+ simdom .+ aa .+ ad .+ da .+ dd

# phenotypes 
vartgv = var(simtgv)

# get or compute residual variance
resvarfile = string("resvar_", repchar,".tmp")
if isfile(resvarfile)
	varresid = readdlm(resvarfile,' ', Float32)[1]
else
  varresid = ((1-h2)/h2) * vartgv
  writedlm(resvarfile, varresid, ' ')
end

# sample residuals
resid = rand(Normal(0,sqrt(varresid)), nread)

# compute phenotypes
pheno = simtgv .+ resid

# write results 
dat = DataFrame(ids=id, ebvs=pheno)
dat2 = DataFrame(gen=maxgen, ids=id, bv=simbv, dom=simdom, aa=aa, ad=ad, da=da, dd=dd, tgv=simtgv, pheno=pheno)

# in generation >0, paste the breeding values with previous breeding values 
if maxgen > 0
	# for qmsim #
	CSV.write("all_bv.txt", dat, header=false, append=true, delim=' ')
	cp("all_bv.txt", "my_bv.txt", force=true)
	
	# to track true values 
	CSV.write("tbvs.dat", dat2, header=false, append=true, delim=' ')
else
	# for qmsim 
	CSV.write("all_bv.txt", dat, header=true, delim=' ')
	cp("all_bv.txt", "my_bv.txt", force=true)
	
	# to track true values 
	CSV.write("tbvs.dat", dat2, header=true, delim=' ')
end

# copy all the breeding values 
cp("all_bv.txt", String("r_"*outfold*"/my_pheno_"*breed*"_"*repchar*".txt"), force=true)
cp("tbvs.dat", String("r_"*outfold*"/my_tbvs_"*breed*"_"*repchar*".txt"), force=true)

# If it is the last generation, replace the replicate number file 
if maxgen == lastgen  
	
	println("LAST GENERATION!")

	# write the qtl effects 
	writedlm("r_"*outfold*"/qtl_effects_"*repchar*".dat", [a d alphas ds], ' ')
	writedlm("r_"*outfold*"/epi_coef_"*repchar*".dat", epi_coef, ' ')
	
	# add 1 to the replicate 
	repl += 1
	repchar2 = lpad(string(repl),3,string(0))
	
	# change the replicate tracker 
	if repl > lastrep
		rm("rep.tmp", force=true)
		println("End of replicate $repchar")
	else	
		f=open("rep.tmp", "w")
			write(f, repchar2)
		close(f)
	end
end

println("Finished!")
