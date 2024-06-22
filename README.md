# FAC_analysis
Script to perform binned count of sequences in directories of FASTQ sequences, generated after a FAC experiment.

**General usage**

The Perl script FAC_analysis.pl reads in a directory of FASTQ files, collected after a FAC experiment. Exact file paths of FASTQ files are specified by a regex expression. It then perform a binned count of each unique sequence, where bins are defined by a comma-separated list of keywords, matching to FASTQ file paths. A comma-separated list of column labels corresponding to the keyword list can optionally be specified for presentation purpose. The count data will be generated as a tab-delimited file. 

An user can optionally provide a set of reference sequences. If provided, count-data will be left-joined to the reference sequence set, reference sequences that are not in the FASTQ files will have zero counts.

An user can also provide a Perl-formatted regex expression to define subsequences where counting and reference sequence matching will be performed on. By default, counting and reference sequence matching will be based on subsequences defined by the regex ".\*GAATTC([ACGT]{50,65})CTGCAG.\*"

Commands:

        sh CRISPRTarget_express.sh <crispr_array.gff> <blast_db>
        sh CRISPRTarget_express.sh <crispr_array.gff> <blast_db> > <target_data.bed>

The only dependency is the application BLASTN, which is provided, and the script is pointing to it.

In the BED6 output, column 4 (the "name" column) is formatted as "genome_accession#spacer_id#count", where the "count" is a series of integer that makes all the names unique. Bedtools uses the name field as FASTA header when extracting sequences.
