process DELLY_SV {
    tag "${srr}"
    container 'quay.io/biocontainers/delly:1.2.6--hb7e2ac5_0'
    publishDir "${params.outdir}/vcf", mode: 'copy'

    input:
    tuple val(srr), path(bam), path(bai)
    tuple path(fasta), path(fai), path(dict)

    output:
    path "${srr}.sv.vcf"

    script:
    """
    # Structural variants (deletions, duplications, inversions, insertions)
    # via paired-end + split-read signal. WGS only
    delly call -g ${fasta} -o ${srr}.sv.bcf ${bam}
    bcftools view ${srr}.sv.bcf > ${srr}.sv.vcf
    """
}
