using Distributions
using DataFrames
using DelimitedFiles

### set variables ####
const repl = ARGS[1]
const domval = ARGS[2]
const outfolder = ARGS[3]

####### set effects #####
if domval == "none"
	const dommean = 0.0
	const domsd = 0.0
elseif domval == "low"
	const dommean = 0.2
	const domsd = 0.3
elseif domval == "medium"
	const dommean = 0.2
	const domsd = 0.7
else
	const dommean = 0.2
	const domsd = 1.5
end

####### read additive effects ####
a = convert(Array, readdlm(outfolder*"/a_"*repl*".dat"))
const nreqqtl = size(a)[1]

# dominance
if domsd .!= 0.0
	domcoeff = rand(Normal(dommean,domsd), nreqqtl)
else
	domcoeff = zeros(Float64, nreqqtl)
end

d = [abs(x) for x in a] .* domcoeff

### write results ###
nam = String(repl)
writedlm(outfolder*"/d_"*nam*".dat", d,' ')
println("Finished sampling dominance effects")