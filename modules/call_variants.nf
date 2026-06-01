// GATK two-stage variant calling: HaplotypeCaller (per-sample gVCF) ->
// GenotypeGVCFs (final VCF). The split exists to support scalable cohort
// joint-genotyping — each sample is called once, joint-genotyping replays
// only the final step when new samples are added. Used here on a single
// sample but architecturally ready for the cohort step from the paper.

process CALL_VARIANTS {
    tag "${srr}"
    container 'broadinstitute/gatk:4.5.0.0'
    publishDir "${params.outdir}/vcf", mode: 'copy'

    input:
    tuple val(srr), path(bam), path(bai)
    tuple path(fasta), path(fai), path(dict)

    output:
    tuple val(srr), path("${srr}.vcf.gz"), path("${srr}.vcf.gz.tbi")

    script:
    """
    # -ERC GVCF emits both variants AND confidently-reference blocks, which is what enables joint-genotyping
    gatk HaplotypeCaller \\
        -R ${fasta} -I ${bam} \\
        -O ${srr}.g.vcf.gz -ERC GVCF

    # Turns the gVCF into a final VCF with called genotypes (0/0, 0/1, 1/1)
    # For a cohort the paper would run CombineGVCFs (637 control + case)
    # before this step - we run single-sample, which is enough to verify
    # the published genotype at the LOXHD1 locus

    gatk GenotypeGVCFs \\
        -R ${fasta} -V ${srr}.g.vcf.gz \\
        -O ${srr}.vcf.gz
    """
}
