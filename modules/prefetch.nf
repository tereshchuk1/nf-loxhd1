
// Two-stage SRA download for PRJNA702911 which stores aligned (not raw)
// data: prefetch + sam-dump produce a SAM, then samtools converts to BAM.
// Split across two processes because the sra-tools container has no
// samtools and vice versa — keeping one tool per container.

process PREFETCH_BAM {
    tag "${srr}"
    container 'quay.io/biocontainers/sra-tools:3.1.1--h4304569_2'
    // symlink because SAM is a large intermediate, not a final artifact
    publishDir "${params.outdir}/bam", mode: 'symlink'

    input:
    val srr

    output:
    // pass srr forward so downstream knows which sample this is
    tuple val(srr), path("${srr}.sam")

    script:
    """
    set -euo pipefail

    # Download .sra; --max-size 50g overrides the default cap
    prefetch ${srr} --max-size 50g

    # prefetch's output layout varies by version (file vs subdir)
    if [ -f "${srr}.sra" ]; then SRA="${srr}.sra"
    elif [ -f "${srr}/${srr}.sra" ]; then SRA="${srr}/${srr}.sra"
    else echo "ERROR: .sra not found"; ls -la; exit 1
    fi
    echo "SRA file: \$SRA"

    # Extract aligned reads into SAM 
    sam-dump "\$SRA" > ${srr}.sam
    """
}

process SAM_TO_BAM {
    tag "${srr}"
    container 'quay.io/biocontainers/samtools:1.19--h50ea8bc_0'
    publishDir "${params.outdir}/bam", mode: 'copy'

    input:
    tuple val(srr), path(sam)

    output:
    tuple val(srr), path("${srr}.bam")

    script:
    """
    set -euo pipefail
    samtools view -bS ${sam} > ${srr}.bam
    [ -s "${srr}.bam" ] || { echo "ERROR: empty BAM"; exit 1; }
    """
}