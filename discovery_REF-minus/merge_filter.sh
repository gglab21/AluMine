#! /bin/bash

########## Define human reference genome path for creating gtester indices #####
sample_path=""
samples=""
human_chr_path=""   # "/storage9/db/human_37/data/chr" # Each chr in separate file, cannot use multifasta files
gtester_path=""    #"/storage9/db/kmer_indexes"
gtester_prefix="${gtester_path}/human_38"
gtester_index="${gtester_prefix}_25.index"
gtester_names="${gtester_prefix}.names"
# Precompiled index and name files can be downloaded from http://bioinfo.ut.ee/AluMine/
############# Done with path settings #################################################################################
# Help message
usage() {
    echo "Usage: $0 -h <human chr ref> -k <kmer list output path> -p <sample path> -s <sample id>"
    exit 1
}
# Parse command-line arguments
while getopts "h:k:p:s:" opt; do
  case $opt in
    h) human_chr_path="$OPTARG" ;;
    k) gtester_path="$OPTARG" ;;
    p) sample_path="$OPTARG" ;;
    s) samples="$OPTARG" ;;
    *) usage ;;
  esac
done
############ Merging REF-minuses from all samples into one database ############
#echo "Merging REF-minus elements from all samples..."
# cd /storage7/analyysid/alu_insetrion_minus_181008/tester/
# for i in V*db
# do
#   echo "$i "
#   cat $i | ~/sort_and_filter_kmer_db.sh > ~/filtered_REF_minus/${i}
#   cat $i | ~/sort_and_filter_kmer_db.sh | ~/count_GC_kmer_db.sh > ~/filtered_REF_minus2/${i}
# done

#rm -f tmp.kmer.db
#touch tmp.kmer.db
for id in ${samples[@]}
do
  cat $id.REF-minus.kmer.db >> tmp.kmer.db
done

################ Filtering the final database #######################
# Remove closely located candidates (within 25 bp from each other)
# and those with GC% >= 30/32 or GC% <= 2/32
# and those that have identical k-mer in the database
# (gmer_counter is confused by k-mers with identical sequences)
cat tmp.kmer.db | sort_kmer_db.sh | uniq | remove_closely_located_and_GC_rich_kmers.pl | remove_all_duplicate_kmers.pl > REF-minus.kmer.db
rm -f tmp.kmer.db
echo "Finished merging REF-minus elements. The results are in the file REF-minus.kmer.db"
