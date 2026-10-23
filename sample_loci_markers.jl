# sample loci to become markers #
using DelimitedFiles
using Distributions
using Statistics

# set the script folder 
const scriptfp = string(ARGS[5], "/scripts")

# argument variables
const repl = ARGS[1]
const nreqmarker = parse(Int64, ARGS[2])
const breed1 = ARGS[3]
const gen1 = parse(Int64, ARGS[4])
const basefolder = ARGS[5]
const repchar = lpad(string(repl),3,string(0))


# read allele frequencies
p = convert(Array, readdlm(string(repl,"/allelefreq_",breed1,"_",gen1,".dat"), Float64)[:,1])
locinr = 1:(size(p)[1])

# find qtl loci 
locfile = string("qtlloci_",repl,"_5000.dat")
qtlloci = convert(Array, readdlm(locfile, Int64)[:,1])

# find segregating loci in both lines
segregating = locinr[0.01 .<= p .<= 0.99]
otherloci = setdiff(segregating, qtlloci)
pother = p[otherloci]

# sample markers to ensure a uniform distribution of marker p
markerloci = zeros(Int32, 0)
nchosen = zeros(Int16,0)

bins = collect(0.01:0.01:0.99)   
nperbin = trunc(Int, (div(nreqmarker,size(bins)[1])))  # the number of snps in each bin
bins = [bins; 1.00]  # add one, so that we can close the final bin

# create a vector of nperbin for each bin #
vec_nperbin = fill(0, size(bins)[1]-1)

# assign bin numbers to loci
bin = zeros(Int16, size(otherloci)[1])

for b in 1:(size(bins)[1]-1)
    bin[ bins[b] .<= pother .< bins[b+1]+0.0001 ] .= b
end

let it = 0
    while size(markerloci)[1] < nreqmarker # loop over required markers
        it += 1
        # stop when the number of required markers is exceeded, and we have checked all bins at least twice 
        if it > (nreqmarker + 2*size(vec_nperbin)[1])
            println("Not enough markers could be sampled")
            break
        end

        # find bin with lowest number
        lwst = argmin(vec_nperbin)

        # find the loci in the sampled bin
        t = otherloci[ bin .== lwst[1] ]

        # remove the loci that are already sampled
        t = setdiff(t, markerloci)
        
        if size(t)[1] == 0  # if there are no markers left
            vec_nperbin[lwst] += nreqmarker+1  # set the n of bin to maximum value +1
            continue
        end
        
        # sample markers 
        chosen = sample(t, 1, replace=false)
        chosenind = indexin(chosen, otherloci)

        # update number per bin
        for s in chosenind
            vec_nperbin[ bin[s], 1] += 1
        end
        
        # append chosen markers
        append!(markerloci, chosen)
    end 
end

# unique loci that were chosen
markerloci = unique(markerloci)
println(size(markerloci)[1], " markers are left with a uniform distribution of p.")

# write results
writedlm(string("markerloci_", breed1, "_", repl, ".dat"), markerloci,' ')
writedlm(string("markerfreq_", breed1, "_",gen1, "_", repl, ".dat"), p[markerloci],' ')
println("Finished sampling marker loci")
