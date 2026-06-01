// Final pipeline step: extract the genotype at the candidate locus from the VCF

process LOCUS_CHECK {
    tag "${srr}:${label}"
    container 'quay.io/biocontainers/bcftools:1.19--h8b25389_0'
    publishDir "${params.outdir}/locus", mode: 'copy'

    input:
    tuple val(srr), path(vcf), path(tbi)            
    val   locus                                     
    val   label                                      

    output:
    // human-readable report, one per (sample, sequencing type)
    path "${srr}_${label}_locus.txt"

    script:
    """
    # Self-documenting output. The "||" branch emits a diagnostic if no record
    # was found - guards against silent empty output on naming mismatches.
    {
      echo "### ${label} sample ${srr} — genotype at ${locus}"
      echo "### Expected: homozygous ALT (C/C), GT=1/1"
      echo ""

      # bcftools view -r uses the tabix index for O(1) region lookup.
      # grep -v '^##' drops VCF metadata header, keeps column header + data.

      bcftools view -r ${locus} ${vcf} | grep -v '^##' || \\
        echo "(no VCF record — check chromosome naming: chr7 vs NC_006583.3)"
    } > ${srr}_${label}_locus.txt
    """
}