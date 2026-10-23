# resample qtl from a larger set
using CSV 
using DataFrames
using DelimitedFiles
using Distributions
using Random

# argument variables
const repl = ARGS[1]
const qtlfold = ARGS[2]
const nqtl = parse(Int64, ARGS[3])
const epi = ARGS[4]
const intperloc = parse(Int8, ARGS[5])
const outfold = ARGS[6]

# read the data
afile = String(qtlfold*"/a_"*repl*".dat")
dfile = String(qtlfold*"/d_"*repl*".dat")
efile = String(qtlfold*"/e_"*repl*".dat")
ecombfile = String(qtlfold*"/epi_combinations_"*repl*".dat")

a = convert(Array, readdlm(afile, ' ')[:,1])
d = convert(Array, readdlm(dfile, ' ')[:,1])
e = convert(Array, readdlm(efile, ' ')[:,1])
ecomb = readdlm(ecombfile, ' ', Int64)

# sample 
ntotal = size(a)[1]
locinr = 1:ntotal

newqtl = sample(locinr, nqtl)

# new files
anew = a[newqtl]
dnew = d[newqtl]

ecomb_select1 = findall(x -> in(x, newqtl), ecomb[:,1])
ecomb_select2 = findall(x -> in(x, newqtl), ecomb[:,2])

ecomb_select = [ecomb_select1; ecomb_select2]
ecomb_select = unique(ecomb_select)

enew = e[ecomb_select]
ecombnew = ecomb[ecomb_select,:]

# write result
writedlm(outfold*"/a_"*repl*".dat", anew, ' ')
writedlm(outfold*"/d_"*repl*".dat", dnew, ' ')
writedlm(outfold*"/selected_"*repl*".dat", newqtl, ' ')

# set a breaker, when all qtl have 5 interactions, stop the loop
breaker = 0

while breaker == 0

  global intmatrix = zeros(Int8, nqtl, nqtl)
  global loclist = collect(1:1:nqtl)
  nint = zeros(Int64, nqtl)   # track number of interactions per qtl

  for i in loclist
  
    if size(nint[nint .< intperloc])[1] == 0  # break when all is 5
      println("Done")
      global breaker = 1
      break
    end
  
    ll = shuffle(loclist[nint .< intperloc])   # randomize the list of qtl
    ll = ll[ll .!= i]
    
    if nint[i] < intperloc    # if the qtl has less than 5 interactions, sample some new ones
      nnew = intperloc - nint[i]
      
      if nnew > 0    # there may be too few loci left
        if nnew > size(ll)[1]
          println("Too few loci left at locus $i")
          @goto label1
        end
        
        smp = ll[1:nnew]
        intmatrix[smp,i] .= 1
        nint[smp] .+= 1
        
      end
    end
    
    nint[i] = intperloc
    
  end
  @label label1
end

# check the sums #
rowsums = convert(Array, sum(intmatrix,dims=1))
colsums = convert(Array, sum(intmatrix,dims=2))

allsums = rowsums .+ colsums'
println(size(allsums[allsums .== intperloc]))

# find the combinations #
indx = findall(x-> x==1, intmatrix)
indx1 = [ x[1] for x in indx]
indx2 = [ x[2] for x in indx]

# randomize the numbers #
locrand = shuffle(loclist)
indx1 = locrand[indx1]
indx2 = locrand[indx2]

# write results
writedlm(outfold*"/epi_combinations_"*repl*".dat", [indx1 indx2],' ')

## sample epistatic effects #############
####### set effects #####
if epi == "none"
	const epimean = 0.0
	const episd = 0.0
elseif epi == "low"
	const epimean = 0.0
	const episd = sqrt( (0.2^2 + 0.3^2)/intperloc )
elseif epi == "medium"
	const epimean = 0.0
	const episd = sqrt( (0.2^2 + 0.7^2)/intperloc )
else
	const epimean = 0.0
	const episd = sqrt( (0.2^2 + 1.5^2)/intperloc )
end

####### read additive effects ####
a = convert(Array, readdlm(outfold*"/a_"*repl*".dat"))

### sample epistasic coefficients ######
ncombs = Int(nqtl*intperloc/2)

if episd != 0.0
	epi_coef = rand(Normal(epimean, episd), ncombs)
else
	epi_coef = zeros(Float64, ncombs)
end

### write results ###
writedlm(outfold*"/e_"*repl*".dat", epi_coef,' ')

