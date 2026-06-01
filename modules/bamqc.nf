// First-look QC on the BAM: confirms data integrity, exposes the
// chromosome naming convention used in the file, and emits standard
// QC artifacts for the final report.

process BAM_QC {
    tag {srr}  
    container "quay.io/biocontainers/samtools:1.19--h50ea8bc_0"
    publishDir "${params.outdir}/qc", mode: 'copy'

    input:
    tuple val(srr), path(bam_file)

    output:
    path "${srr}.flagstat.txt"
    path "${srr}.idxstats.txt"
    path "${srr}.chrnames.txt"

    script:
    """
    # mapping summary
    samtools flagstat ${bam_file} > ${srr}.flagstat.txt

    # per‑chromosome read counts
    samtools idxstats ${bam_file} > ${srr}.idxstats.txt

    # chromosome naming (chr7 vs NC_006583.3)
    samtools view -H ${bam_file} | grep '^@SQ' > ${srr}.chrnames.txt
    """
}