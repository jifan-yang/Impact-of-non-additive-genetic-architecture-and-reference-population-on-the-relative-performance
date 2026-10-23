#### reformat data from QMSim to single space delimited ###
args = commandArgs(trailingOnly=TRUE)

narg = length(args)

for(i in 1:narg){
	fl = args[i]

	t = read.table(fl, header=T, stringsAsFactors=F)

	newfl <- strsplit(fl,'\\.')[[1]][1]
	newfl <- paste0(newfl,"_reformat.dat")

	write.table(t, newfl, col.names=T, row.names=F, quote=F)
}

######