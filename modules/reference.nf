// modules/reference.nf
// Renames canFam3.1 NCBI contig names to chr-style (to match PRJNA702911 BAMs),
// then indexes. Self-contained: awk + sed + samtools, all in the samtools container.
// Map: chr1..chr38 = NC_006583.3..NC_006620.3, chrX = NC_006621.3, chrMT = NC_002008.4.

process PREPARE_REFERENCE {
    tag "canFam3.1"
    container 'quay.io/biocontainers/samtools:1.19--h50ea8bc_0'
    publishDir "${params.outdir}/reference", mode: 'copy'

    input:
    path fasta

    output:
    // tuple keeps .fa + .fai + .dict together for downstream GATK
    tuple path("canFam3.1.chr.fa"), path("canFam3.1.chr.fa.fai"), path("canFam3.1.chr.dict")

    script:
    """
    set -euo pipefail

    # Generate the NC_* -> chr* sed map via awk (no python in this container).
    awk 'BEGIN {
        for (i=0; i<38; i++) {
            nc = sprintf("NC_00%d.3", 6583+i)
            printf "s/^>%s.*/>chr%d/\\n", nc, i+1
        }
        printf "s/^>NC_006621\\\\.3.*/>chrX/\\n"
        printf "s/^>NC_002008\\\\.4.*/>chrMT/\\n"
    }' > rename.sed

    # Apply renaming: pattern is anchored to "^>" so only headers are touched.
    sed -f rename.sed ${fasta} > canFam3.1.chr.fa

    # Fail-fast sanity check: chr7 must exist (the LOXHD1 chromosome).
    grep -q "^>chr7\$" canFam3.1.chr.fa || { echo "ERROR: chr7 missing"; exit 1; }

    # Build .fai (random access) and .dict (GATK sequence dictionary).
    samtools faidx canFam3.1.chr.fa
    samtools dict canFam3.1.chr.fa -o canFam3.1.chr.dict
    """
}
