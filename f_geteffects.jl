# compute alphas and all other effects following NOIA
function get_effects(a,d,p,epi_comb,epi_effects)
	println("Computing orthogonal alphas and ds")
	nqtl = size(a)[1]
	alphas = zeros(Float64, nqtl)
	ds = zeros(Float64, nqtl)
	
	for i in 1:nqtl
		a1 = a[i] + (1 - (2*p[i])) *d[i]
		
		flt1 = epi_comb[:,1] .== i
		ea1 = epi_effects[flt1,2]
		ed1 = epi_effects[flt1,3]
		
		flt2 = epi_comb[:,2] .== i
		ea2 = epi_effects[flt2,4]
		ed2 = epi_effects[flt2,7]
		
		alphas[i] = a1 + sum(ea1) + sum(ea2)
		ds[i] = d[i] + sum(ed1) + sum(ed2)
		
	end
	return alphas, ds
end