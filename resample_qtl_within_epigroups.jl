# resample qtl from a larger set
using CSV 
using DataFrames
using DelimitedFiles
using Distributions
using Random

# argument variables
const repl = ARGS[1]
const qtlfold = ARGS[2]
egroupfile = ARGS[3] 
const nqtl = parse(Int64, ARGS[4])
const intperloc = parse(Int8, ARGS[5])
const outfold = ARGS[6]

# file names
afile = String(qtlfold*"/a_"*repl*".dat")
dfile = String(qtlfold*"/d_"*repl*".dat")
efile = String(qtlfold*"/e_"*repl*".dat")
ecombfile = String(qtlfold*"/epi_combinations_"*repl*".dat")

# if provided path for epi_groups is missing, try default location and notify user
if !isfile(egroupfile)
    fallback = String(qtlfold*"/epi_groups_"*repl*".dat")
    if isfile(fallback)
        egroupfile = fallback
        println("egroupfile '", egroupfile, "' not found — using fallback: ", fallback)
    else
        println("egroupfile '", egroupfile, "' not found and fallback '", fallback, "' also missing.")
        error("No epi_groups file available.")
    end
end

# read effects
a = convert(Array, readdlm(afile, ' ')[:,1])
d = convert(Array, readdlm(dfile, ' ')[:,1])
e = convert(Array, readdlm(efile, ' ')[:,1])
ecomb = readdlm(ecombfile, ' ', Int64)
egroups = readdlm(egroupfile, ' ', Int64)

# # check if qtl indeed only interact with other qtl from the same group
# # -- diagnostic: check that ecomb pairs are within the same egroups row --
# # build map qtl -> list of group indices (handle duplicates just in case)
# qtl_groups = Dict{Int, Vector{Int}}()
# for i in 1:size(egroups,1)
#     for q in egroups[i, :]
#         push!(get!(()->Int[], qtl_groups, q), i)
#     end
# end

# violations = Int[]          # ecomb row indices where qtl are from different groups
# missing_in_groups = Int[]   # ecomb row indices where qtl not found in egroups

# for (r, row) in enumerate(eachrow(ecomb))
#     q1, q2 = row[1], row[2]
#     g1 = get(qtl_groups, q1, Int[])
#     g2 = get(qtl_groups, q2, Int[])
#     if isempty(g1) || isempty(g2)
#         push!(missing_in_groups, r)
#     elseif isempty(intersect(g1, g2))
#         push!(violations, r)
#     end
# end

# println("Checked ecomb rows: ", size(ecomb,1))
# println("Rows with qtl missing from egroups: ", length(missing_in_groups))
# println("Rows with inter-group interactions (violations): ", length(violations))

# if !isempty(violations)
#     println("Example violations (up to 20):")
#     for r in violations[1:min(end,20)]
#         q1,q2 = ecomb[r,1], ecomb[r,2]
#         println(r, ": ", q1, " (groups ", qtl_groups[q1], ")  <->  ", q2, " (groups ", qtl_groups[q2], ")")
#     end
# end

# list of locinr 
ntotal = size(a)[1]
locinr = 1:ntotal

# sample epistatic groups
n_groups = div(nqtl, size(egroups)[2])
sampled_group = sample(1:size(egroups)[1], n_groups, replace = false)
egroups_new = egroups[sampled_group,:]

# extract the qtl in that group
newqtl = vec(egroups[sampled_group,:])

# sample new a and d effects 
anew = a[newqtl]
dnew = d[newqtl]

# get new ecomb matrices
snew = Set(newqtl)
mask = in.(ecomb[:,1], Ref(snew)) .| in.(ecomb[:,2], Ref(snew))
ecomb_new = ecomb[mask, :]

check_qtl = unique(sort(vec(ecomb_new)))
# unique(sort(newqtl))

# get new ecomb effects
e_new = e[mask]

# write result
writedlm(outfold*"/a_"*repl*".dat", anew, ' ')
writedlm(outfold*"/d_"*repl*".dat", dnew, ' ')
writedlm(outfold*"/selected_"*repl*".dat", newqtl, ' ')
writedlm(outfold*"/epi_combinations_"*repl*".dat", ecomb_new,' ')
writedlm(outfold*"/e_"*repl*".dat", e_new,' ')
writedlm(outfold*"/epi_groups_"*repl*".dat", egroups_new, ' ')

