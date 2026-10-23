using DelimitedFiles
using Random

# set variables #
const repl = ARGS[1]
const nqtl = parse(Int64, ARGS[2])
const nqtlpergroup = parse(Int64, ARGS[3])
const intperloc = parse(Int64, ARGS[4])
const outfolder = ARGS[5]

# split qtls into groups
global loclist = collect(1:nqtl)

if nqtl % nqtlpergroup != 0
  error("nqtl must be divisible by nqtlpergroup")
end

global ngroups = div(nqtl, nqtlpergroup)  # number of groups

# create a random assignment of loci into ngroups with exactly nqtlpergroup loci each
perm = shuffle(loclist)
global groups = [perm[(i-1)*nqtlpergroup+1 : i*nqtlpergroup] for i in 1:ngroups]

# optional: group index for each locus (1..ngroups)
global group_of = zeros(Int, nqtl)
for (g, ids) in enumerate(groups)
  for id in ids
    group_of[id] = g
  end
end

# sample interactions within each group and combine into a full nqtl x nqtl matrix
# We treat intperloc as the number of incoming interactions per locus (as in original code
# where intmatrix[smp, i] .= 1 sets edges into i). All interactions are restricted to the same group.

if nqtlpergroup <= intperloc
  error("nqtlpergroup must be greater than intperloc (cannot sample that many distinct partners within group)")
end

global intmatrix = zeros(Int8, nqtl, nqtl)

function sample_group!(intmatrix::Array{Int8,2}, group::Vector{Int}, intperloc::Int; max_tries::Int=1000)
  m = length(group)
  # local indices 1..m map to global indices group[1..m]
  attempt = 0
  while attempt < max_tries
    attempt += 1
    local_nint = zeros(Int, m)   # number of incoming interactions assigned to each local locus
    local_mat = zeros(Int8, m, m)
    order = shuffle(1:m)
    failed = false

    for idx in order
      # if everyone already has enough incoming interactions, we're done
      if all(local_nint .>= intperloc)
        break
      end

      # possible donors are those with < intperloc
      donors = shuffle(findall(x-> x < intperloc, local_nint))
      donors = filter(x -> x != idx, donors)  # exclude self

      if local_nint[idx] < intperloc
        nnew = intperloc - local_nint[idx]
        if nnew > length(donors)
          # not enough donors available in this attempt, restart
          failed = true
          break
        end
        chosen = donors[1:nnew]
        for d in chosen
          local_mat[d, idx] = 1
          local_nint[d] += 1
        end
        local_nint[idx] = intperloc
      end
    end

    if !failed && all(local_nint .== intperloc)
      # map local_mat into the global intmatrix
      for i_local in 1:m, j_local in 1:m
        if local_mat[i_local, j_local] == 1
          i_global = group[i_local]
          j_global = group[j_local]
          intmatrix[i_global, j_global] = 1
        end
      end
      return true
    end
    # otherwise retry
  end
  return false
end

# run sampling for every group
for g in groups
  ok = sample_group!(intmatrix, g, intperloc)
  if !ok
    error("Failed to sample interactions for group $(g) after repeated attempts")
  end
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

# identify the interactions
indx1 = loclist[indx1]
indx2 = loclist[indx2]

# verify that every interaction stays within its group
cross_edges = Tuple{Int,Int}[]
for i in 1:nqtl, j in 1:nqtl
    if intmatrix[i, j] == 1 && group_of[i] != group_of[j]
        push!(cross_edges, (i, j))
    end
end

if isempty(cross_edges)
    println("All groups have only within-group interactions.")
else
    println("Cross-group interactions detected:")
    for (i, j) in cross_edges
        println("  donor $(i) (group $(group_of[i])) → recipient $(j) (group $(group_of[j]))")
    end

    cross_by_group = Dict{Int, Vector{Tuple{Int,Int}}}()
    for (i, j) in cross_edges
        for gid in (group_of[i], group_of[j])
            push!(get!(cross_by_group, gid, Tuple{Int,Int}[]), (i, j))
        end
    end

    for gid in sort(collect(keys(cross_by_group)))
        println("Group $(gid) affected by cross-group edges: $(cross_by_group[gid])")
    end
end

# final check: sample one group at random and inspect its interactions
picked_group_idx = rand(1:ngroups)
picked_group = groups[picked_group_idx]
println("Selected group $(picked_group_idx) with QTLs: $(picked_group)")

group_matrix = intmatrix[picked_group, picked_group]

rowsums_group = vec(sum(group_matrix, dims=2))  # outgoing interactions
colsums_group = vec(sum(group_matrix, dims=1))  # incoming interactions

println("Group interaction matrix (rows/cols ordered by QTL list above):")
for (row_idx, qtl_row) in enumerate(picked_group)
    row_values = join(group_matrix[row_idx, :], " ")
    println("QTL $(qtl_row): $(row_values)")
end

println("Interaction counts per QTL (outgoing, incoming):")
for (idx, qtl_id) in enumerate(picked_group)
    println("QTL $(qtl_id): outgoing=$(rowsums_group[idx]), incoming=$(colsums_group[idx])")
end

# write results
writedlm(outfolder*"/epi_combinations_"*repl*".dat", [indx1 indx2],' ')

# write the group membership matrix (groups x QTL-per-group)
group_matrix_out = permutedims(reshape(vcat(groups...), nqtlpergroup, ngroups))
writedlm(outfolder*"/epi_groups_"*repl*".dat", group_matrix_out, ' ')
