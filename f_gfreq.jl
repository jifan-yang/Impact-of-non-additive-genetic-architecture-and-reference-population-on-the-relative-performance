function get_gfreq(genot)
	n = size(genot)[1]
	nqtl = size(genot)[2]
	gfreq = zeros(Float64, nqtl, 3)
	
	for i in 1:nqtl
		pAA = size(genot[genot[:,i] .== 2, i])[1] / n
		pAa = size(genot[genot[:,i] .== 1, i])[1] / n
		paa = size(genot[genot[:,i] .== 0, i])[1] / n	
	
		gfreq[i,1] = pAA
		gfreq[i,2] = pAa
		gfreq[i,3] = paa
	end
	return gfreq
end