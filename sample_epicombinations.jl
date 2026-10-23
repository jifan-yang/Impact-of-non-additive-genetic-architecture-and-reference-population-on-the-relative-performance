using DataFrames
using DelimitedFiles
using Random
using LinearAlgebra

# set variables #
const repl = ARGS[1]
const nqtl = parse(Int64, ARGS[2])
const intperloc = parse(Int64, ARGS[3])
const outfolder = ARGS[4]

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
writedlm(outfolder*"/epi_combinations_"*repl*".dat", [indx1 indx2],' ')
