#### function to calculate allele frequencies ###############
function getaf(genmatrix, snpdim=2)
  af = zeros(Float64, size(genmatrix)[snpdim])
  for c in 1:size(genmatrix)[snpdim]
    if snpdim == 2
      af[c] = mean(genmatrix[:,c])/2
    else
      af[c] = mean(genmatrix[c,:])/2
    end
  end
  return af
end

### compute genotype frequencies ###
function gf(af1,af2)
	nqtl = size(af1)[1]
	gfreq = zeros(Float64, nqtl, 3)
	
	for i in 1:nqtl
		pAA = af1[i] * af2[i]
		pAa = (af1[i] * (1-af2[i])) + ((1-af1[i]) * af2[i])
		paa = (1-af1[i]) * (1-af2[i])
	
		gfreq[i,1] = pAA
		gfreq[i,2] = pAa
		gfreq[i,3] = paa
	end
	return gfreq
end

# compute genotype frequencies for 3way CB #
# uses allele frequency in the sire line (af1) and genotype frequencies in the two-way dams #

function gf_3way(af1, gfreq23)
	nqtl = size(af1)[1]
	gfreq = zeros(Float64, nqtl, 3)
	
	for i in 1:nqtl

		p1 = [af1[i] (1-af1[i,1])]'
		gf = gfreq23[i,:]'
		pr = p1 * gf

		gfreq[i,1] = pr[1,1] + 0.5 * pr[1,2]
		gfreq[i,2] = pr[2,1] + pr[1,3] + 0.5 * pr[1,2] + 0.5 * pr[2,2] 
		gfreq[i,3] = pr[2,3] + 0.5 * pr[2,2]

	end
	return gfreq
end

# compute allele frequencies from genotype frequencies #
# useful for 3-way crossbreds #

function p_fromgf(gfreq)
	nqtl = size(gfreq)[1]
	p = zeros(Float64, nqtl, 1)

	for i in 1:nqtl
		p[i] = gfreq[i,1] + 0.5 * gfreq[i,2]
	end
	return p
end
