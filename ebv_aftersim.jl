# compute ebv after simulations have completed
using CSV
using DataFrames
using Distributions
using DelimitedFiles
using LinearAlgebra

# set the script folder #
const scriptfp = string(ARGS[8], "/scripts")

# functions #
include("$scriptfp/f_readgeno.jl")
include("$scriptfp/f_allelefrequencies.jl")
include("$scriptfp/f_noia_gfreq.jl")
include("$scriptfp/f_epistasis.jl")  
include("$scriptfp/f_gfreq.jl")
include("$scriptfp/f_geteffects.jl")

# parameters #
const breed = ARGS[1]
const outfold = string(ARGS[8], "/", ARGS[2])
const epimodel = ARGS[3]
const gen = parse(Int64, ARGS[4])
const repl = ARGS[5]
const h2 = parse(Float64, ARGS[6])
const qtlfolder = string(ARGS[8], "/", ARGS[7])
const repchar = lpad(string(repl),3,string(0))

# read temp data #
dat1 = CSV.read(string(outfold, "/", breed, "_data_", repl, "_reformat.dat"), DataFrame, delim=' ', header=true)
id = convert(Array{Int64,1}, dat1[dat1[:, :G] .== gen, :Progeny])

println("Computing TBVs for generation $gen of line $breed")

# read genotypes
gfile = string(outfold, "/",breed,"_mrk_qtl_", repl,".txt")
geno, geno_phase, nloc, ids_geno = read_genotypes(gfile, id, true, true)

nread = size(geno)[1]
println("There were $nread genotypes read")

# get effects
a = convert(Array, readdlm(qtlfolder*"/a_"*repchar*".dat",' ', Float64))
d = convert(Array, readdlm(qtlfolder*"/d_"*repchar*".dat",' ', Float64))
epi_coef = convert(Array, readdlm(qtlfolder*"/e_"*repchar*".dat",' ', Float64))

nreqqtl = size(a)[1]

# epi combinations
epi_combinations = convert(Array, readdlm(qtlfolder*"/epi_combinations_"*repchar*".dat",' ', Int64))
# epi_coef = epi_coef[1:size(epi_combinations)[1]] # this should not be necessary

# list with loci nr
locinr = 1:(size(geno)[2])

# read qtl locations 
locfile = string("qtlloci_", repchar, "_", nreqqtl, ".dat")
selfile = string(qtlfolder, "/selected_", repchar, ".dat")

if isfile(selfile) # if there is a file with selected loci based on epi groups, read it

	println("selected locfile found! Making a subset of the full set of QTL.")
	allqtl = convert(Array, readdlm("../qtlloci_"*repchar*"_5000.dat", Int64)[:,1])    # this is hardcoded!
	selqtl = convert(Array, readdlm(selfile, Int64)[:,1])
	qtlloci = allqtl[selqtl]
	writedlm(locfile, qtlloci, ' ')
  
	# Create mapping from QTL numbers to their positions in selqtl
	qtl_to_pos = Dict(qtl => i for (i, qtl) in enumerate(selqtl))

	# Transform epi_combinations to use position indices (with correct syntax)
	epi_combinations = hcat([qtl_to_pos[row[1]] for row in eachrow(epi_combinations)],
							[qtl_to_pos[row[2]] for row in eachrow(epi_combinations)])

elseif isfile(locfile)   # if there is a locfile, read it

	println("locfile found!")
 	qtlloci = convert(Array, readdlm(locfile, Int64)[:,1])

else # if not, completely sample new loci
	println("locfile NOT found! Sampling new loci")

	pall = getaf(geno)
	segregating = locinr[0.01 .< pall .< (0.99)]
	
	qtlloci = sample(segregating, nreqqtl, replace=false)
	writedlm(string("../"*locfile), qtlloci, ' ')
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
alphas, ds = get_effects(a, d, p, epi_combinations, epi_effects)

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
varbv= var(simbv)
vardom = var(simdom)
varaa = var(aa)
vartgv = var(simtgv)

# get or compute residual variance
resvarfile = string("resvar_", repchar,".tmp")
if isfile(resvarfile)
	varresid = readdlm(resvarfile,' ', Float32)[1]
else
  varresid = (((1-h2)/h2) * varbv) - vardom - varaa
  writedlm(resvarfile, varresid, ' ')
end

# sample residuals
resid = rand(Normal(0,sqrt(varresid)), nread)
varresid = var(resid)  # this is the true (realized) variance of sampled residuals

# compute phenotypes
pheno = simtgv .+ resid
varphe = var(pheno)

# write results 
ids_geno = convert(Array{Int64,1}, ids_geno[:,1])
dat2 = DataFrame(gen=gen, ids=ids_geno, bv=simbv, dom=simdom, aa=aa, ad=ad, da=da, dd=dd, tgv=simtgv, pheno=pheno)
CSV.write(string("my_tbvs_",breed,"_",repl,"_", gen, ".txt"), dat2, header=true, append=false, delim=' ')

# proportions
h2_true = varbv/varphe
d2_true = vardom/varphe
aa2_true = varaa/varphe

# save variance components
varfile = string("var_all_", repchar, ".txt")
row = [gen, varbv, vardom, varaa, vartgv, varresid, varphe, h2_true, d2_true, aa2_true]

if !isfile(varfile)
	open(varfile, "w") do io
	println(io, "gen varbv vardom varaa vartgv varresid varphe h2 d2 aa2")
	println(io, join(row, ' '))
end
else
	open(varfile, "a") do io
	println(io, join(row, ' '))
	end
end

println("Finished!")
