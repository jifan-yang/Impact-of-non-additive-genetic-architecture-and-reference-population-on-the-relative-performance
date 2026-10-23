using Distributions
using DataFrames
using DelimitedFiles

### set folder location of scripts ###
if Sys.iswindows()
	const scriptfp = "C:/Projects/Armidale/HPC/scripts/"
else
	const scriptfp = "/lustre/nobackup/WUR/ABGC/duenk002/armidale/scripts/"
end

### set variables ####
const repl = ARGS[1]
const nreqqtl = parse(Int64, ARGS[2])
const outfolder = ARGS[3]

####### sample effects ####
a = rand(Normal(0,1), nreqqtl)

### write results ####
writedlm(outfolder*"/a_"*repl*".dat", a,' ')
println("Finished sampling additive effects")