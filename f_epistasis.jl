# function to get statistical avarage, dominance, and epistatic effects from functional effects  #
# gfreq is a nqtl*3 matrix of genotype frequencies per locus #
# af is a nqtl*1 vector of allele frequencies per locus #
# epicoef ncombs * 1 vector of epistatic coefficients #
# epicomb is a ncombs * 2 matrix with locus numbers for every interaction #

function epi(gfreq, af, epicoef, a, epimodel, epicomb)

	nqtl = size(af)[1]
	ncombs = size(epicomb)[1]
	
	epi_effects = zeros(Float64, ncombs, 9)
	epi_vars = zeros(Float64, ncombs, 9)

	if epimodel == "complementary"
		epimat = [1 1 0; 1 1 0; 0 0 0]
	elseif  epimodel == "aa"
		epimat = [2 1 0; 1 1 1; 0 1 2]
	elseif epimodel == "dd"
		epimat = [0 1 0; 1 0 1; 0 1 0]
	elseif epimodel == "interaction"
		epimat = [2 1 0]' * [2 1 0]
	else
		epimat = [0 0 0; 0 0 0; 0 0 0]
	end
	
	# scale and center the epimat
	if epimodel !== "none"
		epimat = (epimat .- mean(epimat)) ./ std(epimat)
	end
	
	for c in 1:ncombs
		
		# get locus numbers
		i = epicomb[c,1]
		j = epicomb[c,2]
		
		# allele frequencies
		af_A = af[i]
		af_B = af[j]
	
		# create y, the effect of epistatic coefficients on the phenotype
		y2 = epimat .* (epicoef[c] * sqrt(abs(a[i])) * sqrt(abs(a[j])))
		y = vec(y2')
		
		# Get genototype frequencies to create D and W
		pAA = gfreq[i,1]
		pAa = gfreq[i,2]
		paa = gfreq[i,3]

		pBB = gfreq[j,1]
		pBb = gfreq[j,2]
		pbb = gfreq[j,3]

		# D matrix with genotype probabilities
		DA = [pAA 0 0; 0 pAa 0 ; 0 0 paa]
		DB = [pBB 0 0; 0 pBb 0 ; 0 0 pbb]
		D = kron(DB, DA)

		if det(D) == 0   # never happens, because the allele frequencies of fixed loci are set to extreme values
			epi_vars[c,:] = [af_A af_B 0 0 0 0 0 0 0]
			continue
		end
  
		# create W, following NOIA parameterization
		WA = zeros(Float64,3,3)
		WB = zeros(Float64,3,3)

		WA[:,1] .= 1

		sc_a = pAA+paa-((pAA-paa)^2)
		sc_b = pBB+pbb-((pBB-pbb)^2)
			
		WA[1,2] = -(-pAa - (2*paa))
		WA[2,2] = -(1-pAa - (2*paa))
		WA[3,2] = -(2-pAa - (2*paa))

		if sc_a == 0.0   # locus is fixed !
			WA[:,3] .= 0.0
		else
			WA[1,3] = -2*pAa*paa/sc_a
			WA[2,3] = 4*pAA*paa/sc_a
			WA[3,3] = -2*pAA*pAa/sc_a
		end

		WB[:,1] .= 1

		WB[1,2] = -(-pBb - (2*pbb))
		WB[2,2] = -(1-pBb - (2*pbb))
		WB[3,2] = -(2-pBb - (2*pbb))

		if sc_b == 0.0  # locus is fixed !
			WB[:,3] .= 0.0
		else
			WB[1,3] = -2*pBb*pbb/sc_b
			WB[2,3] = 4*pBB*pbb/sc_b
			WB[3,3] = -2*pBB*pBb/sc_b
		end

		W = kron(WB, WA)
  
		# some of the epistatic effects translate to additive effects and dominance deviations  #
		# the effects in b are ordered as: mu, alpha1, d1, alpha2, aa, da, d2, ad, dd
		#                                   1       2   3       4   5   6   7   8   9
		
		b = inv(W' * D * W) * W' * D * y
		B = Diagonal(b)
		V = B' * W' * D * W * B

		VA = V[2,2]+V[4,4]
		VD = V[3,3]+V[7,7]
		VAA = V[5,5]
		VAD = V[6,6]+V[8,8]
		VDD = V[9,9]

		epi_vars[c,:] = [af_A af_B VA VD VAA VAD VDD VA+VD+VAA+VAD+VDD epicoef[c] ]
		# b = [round(x, digits=5) for x in b]
		epi_effects[c,:] = b'
	end
	return epi_vars, epi_effects
end
