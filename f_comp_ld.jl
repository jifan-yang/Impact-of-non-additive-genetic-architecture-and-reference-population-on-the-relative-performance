function compLD(genotypes1, lmap, chrom, af1, maxdist)

	##### create bins of distances ###
	distbin = collect(0.000000000001:0.005:maxdist)

	### arrays for ld measures ###
	ldmean1 = zeros(Float32, (size(distbin)[1]-1), size(chrom)[1])

	### loop over every chromosome ##
	for s in 1:size(chrom)[1]
		c = chrom[s]
		chrsel = lmap[:,:chr] .== c
		lm = lmap[chrsel,:]
		nl = size(lm)[1]
		
		println("Computing pairwise LD for chromosome $c")
		
		genoc1 = genotypes1[:,chrsel]

		afc1 = af1[chrsel]

		# create distance matrix for that chromosome, and compute LD measurements
		distmat = zeros(Float32, nl, nl)
		ld1 = zeros(Float32, nl, nl)

		for i in 2:nl
			for j in 1:(i-1)
				# compute distance
				distmat[i,j] = lm[i,:pos] - lm[j,:pos]
				
				# compute LD line 1
				if (afc1[i] == 0.0 && afc1[j] .== 0.0) || (afc1[i] == 1.0 && afc1[j] == 1.0)
					#ld1[i,j] = 1.0
          ld1[i,j] = NaN32 
				elseif (afc1[i] == 0.0 && afc1[j] .== 1.0) || (afc1[i] == 1.0 && afc1[j] .== 0.0)
					#ld1[i,j] = -1.0
          ld1[i,j] = NaN32
				elseif (afc1[i] == 1.0 || afc1[i] == 0.0 || afc1[j] == 1.0 || afc1[j] == 0.0)
					ld1[i,j] = NaN32
				else				
					ld1[i,j] = cor(genoc1[:,i], genoc1[:,j])
				end
			end
		end
		
		### loop over the bins of distances and compute mean LD 
		for i in 2:size(distbin)[1]
			selmat = (distmat .>= distbin[i-1]) .& (distmat .< distbin[i])
			ldmean1[i-1,s] = mean(filter(!isnan, ld1[selmat]).^2)
		end
	end

	out = [distbin[2:end] ldmean1]
	
	return out
  
end
