# function to read first column 
function read_names(gfile,nlines::Integer,skiprow=true)
  f=open(gfile)
  if skiprow==true
    readline(f)
  end
  ids = zeros(Int64, nlines)
  line2write = 1
  for i=1:nlines
    ids[line2write] = parse(Int64, readline(f)[1:7])
    line2write = line2write+1
    if i%1000==0
      println("Reading id ",i); #GC.gc()
    end
  end
  close(f)
  return ids
end

# function to read genotype gfile from QMSim output 
function read_genotypes(gfile::AbstractString,selids,skiprow=true,idcol=true)
  f=open(gfile)
  println("Reading genotype data from ", gfile)

  nlines=countlines(gfile)

  if skiprow==true
    readline(f)
    nlines=nlines-1
  end

  println("Total number of ids is ", nlines)

  # get the number of columns
  firstl = split(readline(f)[8:end])[1]
  nloc = length(firstl)

  println("Number of loci is  ", nloc)
  
  # read names from gfile 
  if idcol==true
    ids = read_names(gfile, nlines)
  end
  #

  # count number of ids that should be read 
  if selids != 0
    readornot = [in(x, selids) for x in ids]
    ids = ids[ readornot ]
  else
    readornot = trues(nlines)
  end
  nids = size(ids)[1]
  
  # Read in actual genotype data 
  f=open(gfile) # re-wind to beginning of the gfile
  mat = zeros(Int8,nids,nloc)  # create a matrix

  if skiprow==true
    hdl=readline(f)
  end

  println("Reading the genotypes...")

  line2write = 1
  for i=1:nlines
  
    if line2write > nids
      println("All genotypes were read!")
      break
    end
  
    if readornot[i] == false
      readline(f)
    else
      mat[line2write,:] = [ parse(Int8,s) for s=split(readline(f)[8:end])[1] ]
      line2write = line2write + 1
      if i%1000==0
        println("Reading genotype line ",i); #GC.gc()
      end
    end
  end
  
  close(f)

  # make sure the order of selids and genotype matrix is the same
  if selids != 0
    ids_geno = ids[ [in(x, selids) for x in ids] ]
	  ord = indexin(selids, ids_geno)
	  mat = mat[ord,:]
    ids_geno = ids_geno[ord,:]
  else
    ids_geno = ids
  end
	
  println("Creating genotype matrices..")
  
  # create maternal and paternal haplotypes
  geno_p=copy(mat)
  geno_m=copy(mat)

  geno_p[geno_p .== 0] .= 1
  geno_p[geno_p .== 2] .= 2
  geno_p[geno_p .== 3] .= 1
  geno_p[geno_p .== 4] .= 2

  geno_m[geno_m .== 0] .= 1
  geno_m[geno_m .== 2] .= 2
  geno_m[geno_m .== 3] .= 2
  geno_m[geno_m .== 4] .= 1

  # create new full 0,1,2 matrix
  geno = (geno_p.-1).+(geno_m.-1)
  geno_phase = [geno_m; geno_p]
  
  println("Done reading genotypes!")

  return geno, geno_phase, nloc, ids_geno
  
end