using Distributions
using DataFrames
using DelimitedFiles
using Random
using LinearAlgebra

### set variables ####
const repl = ARGS[1]
const epival = ARGS[2]
const intperloc = parse(Int64, ARGS[3])
const outfolder = ARGS[4]

####### set effects #####
if epival == "none"
	const epimean = 0.0
	const episd = 0.0
elseif epival == "low"
	const epimean = 0.0
	const episd = sqrt( (0.2^2 + 0.3^2)/intperloc )
elseif epival == "medium"
	const epimean = 0.0
	const episd = sqrt( (0.2^2 + 0.7^2)/intperloc )
else
	const epimean = 0.0
	const episd = sqrt( (0.2^2 + 1.5^2)/intperloc )
end

####### read additive effects ####
a = convert(Array, readdlm(outfolder*"/a_"*repl*".dat"))
const nreqqtl = size(a)[1]

### sample epistasic coefficients ######
ncombs = Int(nreqqtl*intperloc/2)

if episd != 0.0
	epi_coef = rand(Normal(epimean, episd), ncombs)
else
	epi_coef = zeros(Float64, ncombs)
end

### write results ###
nam = string(repl)
writedlm(outfolder*"/e_"*nam*".dat", epi_coef,' ')

println("Finished sampling epistatic effects")