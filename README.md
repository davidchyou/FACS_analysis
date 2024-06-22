# FAC_analysis
Script to perform binned count of sequences in directories of FASTQ sequences, generated after a FAC experiment.

**General usage**

The Perl script FAC_analysis.pl reads in a directory of FASTQ files, collected after a FAC experiment. Exact file paths of FASTQ files are specified by a regex expression. It then perform a binned count of each unique sequence, where bins are defined by a comma-separated list of keywords, matching to FASTQ file paths. A comma-separated list of column labels corresponding to the keyword list can optionally be specified for presentation purpose. The count data will be generated as a tab-delimited file. 

An user can optionally provide a set of reference sequences in FASTA format. If provided, count-data will be left-joined to the reference sequence set, reference sequences that are not in the FASTQ files will have zero counts.

An user can also provide a Perl-formatted regex expression to define subsequences where counting and reference sequence matching will be performed on. By default, counting and reference sequence matching will be based on subsequences defined by the regex ".\*GAATTC([ACGT]{50,65})CTGCAG.\*"

Example command:

        perl FAC_count.pl \
        -fastq_regex 'FASTQ_directory/*/*.fastq' \              # Regex expression specifying the exact Fastq paths. The expression needs to be quoted. 
        -keywords presort-B,sort-1B,sort-2B,sort-3B,sort-4B \   # Keywords list separated by commas, no white spaces.
        -subseq_regex '.*GAATTC([ACGT]{50,65})CTGCAG.*' \       # Perl-formatted regex specifying subsequences to operate on. The expression needs to be quoted.
        -ref ref.fna \                                          # Reference sequences in FASTA format.
        -out out.tsv                                            # Count data in TSV format.

