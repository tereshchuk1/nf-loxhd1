// Prepare aligned BAM for GATK HaplotypeCaller:
// sort -> add read groups -> mark duplicates -> index

process MARKDUP_ADDRG {
    tag "${srr}"
    container 'broadinstitute/gatk:4.5.0.0'
    publishDir "${params.outdir}/bam", mode: 'copy'

    input:
    tuple val(srr), path(bam)
    val   sample

    output:
    tuple val(srr), path("${srr}.ready.bam"), path("${srr}.ready.bam.bai")

    script:
    """
    # Add @RG and coordinate-sort in one step.
    gatk AddOrReplaceReadGroups \\
        -I ${bam} -O rg.bam \\
        -RGID ${srr} -RGSM ${sample} -RGLB lib1 -RGPL ILLUMINA -RGPU unit1 \\
        -SO coordinate

    # mark PCR/optical duplicates 
    gatk MarkDuplicates \\
        -I rg.bam -O ${srr}.ready.bam -M ${srr}.dup_metrics.txt

    samtools index ${srr}.ready.bam
    """
}
