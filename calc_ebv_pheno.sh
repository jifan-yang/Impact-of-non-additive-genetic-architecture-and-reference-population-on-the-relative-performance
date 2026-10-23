#!/bin/bash

Rscript ../scripts/format_data.R data.tmp 
julia ../scripts/ebv.jl Currentpop none_none_none_1000 none none none 50 10 0.3 effects_additive_1000 /lustre/nobackup/WUR/ABGC/duenk002/jifan_test
