# MAKE NOIA PARAMTERIZATION 
# recode the genotypes according to NOIA 
# using precomputed genotype frequencies 
# this version is much faster than the regular f_noia that computes frequencies

function make_noia(geno, gfreq)
	
	println("Creating NOIA matrices..")
	
	noia = convert(Array{Float32,2}, geno)
	noia_dom = copy(noia)
	
	n = size(noia)[1]

	for i in 1:size(noia)[2]
		pAA = gfreq[i,1]
		pAa = gfreq[i,2]
		paa = gfreq[i,3]

		sc = pAA+paa-((pAA-paa)^2)
		
		if sc == 0.0 # the locus is fixed!!! #
			noia_dom[:,i] .= 0.0
		else
			noia_dom[geno[:,i] .== 2,i] .= -(2*pAa*paa)/sc
			noia_dom[geno[:,i] .== 1,i] .= 4*pAA*paa/sc
			noia_dom[geno[:,i] .== 0,i] .= -(2*pAA*pAa)/sc
		end

		noia[geno[:,i] .== 2, i] .= -(-pAa - (2*paa))
		noia[geno[:,i] .== 1, i] .= -(1-pAa - (2*paa))
		noia[geno[:,i] .== 0, i] .= -(2-pAa - (2*paa))
	end
	
	println("Done creating NOIA matrices!")
	
	return noia, noia_dom
end