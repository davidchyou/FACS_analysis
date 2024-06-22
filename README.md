# FAC_analysis

A Perl script that computes binned count of sequences of interest from directories of FASTQ sequences, generated after a FAC experiment.

**General usage**

The Perl script FAC_analysis.pl reads in a directory of FASTQ files, collected after a FAC experiment. Exact paths of FASTQ files are specified by a regex expression. It then computes binned count of each unique sequence, where bins are defined by a comma-separated list of keywords provided by the user, matching to FASTQ file paths. A comma-separated list of column labels corresponding to the keyword list can optionally be specified for presentation purpose. If a keyword list is not provided, grant total of all sequences will be computed. Sequence counts in FASTQ files where file paths do not match to any specified keyword will also be computed. The count data will be generated as a tab-delimited file. 

An user can optionally provide a set of reference sequences in FASTA format. If provided, count-data will be left-joined to the reference sequence set, reference sequences that are not in the FASTQ files will have zero counts.

Because in FAC experiments, sequences of interest are cloned between two restriction site, an user can provide a Perl-formatted regex expression to define subsequences where counting and reference sequence matching will be performed on. By default, counting and reference sequence matching will be based on subsequences defined by the regex ".\*GAATTC([ACGT]{50,65})CTGCAG.\*"

Example command:

        perl FAC_count.pl \
        -fastq_regex 'FASTQ_directory/*/*.fastq' \              # [Required] Regex expression specifying the exact Fastq paths. The expression needs to be quoted. 
        -keywords presort-B,sort-1B,sort-2B,sort-3B,sort-4B \   # [Optional but recommended] Keywords list separated by commas, no white spaces.
        -subseq_regex '.*GAATTC([ACGT]{50,65})CTGCAG.*' \       # [Optional] Perl-formatted regex specifying subsequences to operate on. The expression needs to be quoted.
        -ref ref.fna \                                          # [Optional but recommended] Reference sequences in FASTA format.
        -out out.tsv                                            # [Required] Count data in TSV format.

**Output**

The count data will be generated as a tab-delimited file, and columns are

- Sequence_ID: If a ref-FASTA is provided, these are the ID parts of FASTA headers (i.e. the first full word), auto-generated ID if not.
- Description: If a ref-FASTA is provided, these are the description parts of FASTA headers (i.e. words after the first full word), set to NA if not.
- Columns corresponding to file-path keywords, or the corresponding labels if specified: Binned counts of sequences, one column per bin.
- all_others: Binned counts of sequences in FASTQ files where file paths do not match to any specified keyword. If a keyword list is not provided, this is a sequence grant total column. This column is always generated.
- Sequence: Subsequences being processed.
