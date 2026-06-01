#!/usr/bin/env nextflow

/*
 * nf-loxhd1 — Nextflow pipeline reproducing the public, executable subset of
 * Hytönen et al. 2021 (Hum Genet 140:1611-1618).
 *
 * What this pipeline does:
 *   Starts from raw SRA data for one publicly deposited affected Rottweiler
 *   (PRJNA702911) and runs an end-to-end germline variant discovery workflow
 *   on canFam3.1, producing both the genotype at the LOXHD1 candidate locus
 *   and a fully VEP-annotated VCF.
 *
 * Pipeline stages (WES branch, run end-to-end on SRR13743383):
 *
 *   PREPARE_REFERENCE   — rename NCBI contig names (NC_006583.3, ...) to chr-
 *                         style (chr1..chr38, chrX, chrMT) to match the SRA
 *                         BAM headers, then build .fai + GATK .dict.
 *   PREFETCH_WES        — pull aligned data from SRA via prefetch + sam-dump
 *   SAM2BAM_WES         — convert sam-dump output to BAM.
 *   BAMQC_WES           — samtools flagstat, idxstats; sanity-check chromosome
 *                         naming used in the BAM.
 *   PREP_WES            — add read groups (GATK requires @RG), coordinate-sort,
 *                         index.
 *   CALL_WES            — GATK HaplotypeCaller (-ERC GVCF) followed by
 *                         GenotypeGVCFs. Single-sample genotyping
 *   DOWNLOAD_VEP_CACHE  — fetch Ensembl release-104 cache for canis_familiaris
 *   ANNOTATE_WES        — VEP functional annotation. Strips 'chr' prefix from
 *                         VCF to match Ensembl naming, then re-bgzips.
 *   LOCUS_WES           — bcftools view at the candidate position
 *                         (chr7:44806821) — the verification readout.
 *
 * WGS branch is wired in main.nf but commented out - my laptop doesn't have 
 * enough resources for processing, however WGS results are not required to 
 * verify the LOXHD1 coding variant, and the WES branch reproduces the key result.
*/

nextflow.enable.dsl = 2

// Parameters 
params.wgs_srr = 'SRR_WGS_PLACEHOLDER'   // run under SAMN17983068 (WGS)
params.wes_srr = 'SRR_WES_PLACEHOLDER'   // run under SAMN17983069 (WES)
params.ref_fasta = "${projectDir}/assets/canFam3.1.fa"  
params.ref_acc = 'GCF_000002285.3'       // canFam3.1 
params.locus = 'chr7:44806821-44806821'
params.vep_cache = "${projectDir}/assets/vep_cache"
params.outdir = 'results'

include {PREPARE_REFERENCE}              from './modules/reference.nf'
include {PREFETCH_BAM as PREFETCH_WGS}   from './modules/prefetch.nf'
include {PREFETCH_BAM as PREFETCH_WES}   from './modules/prefetch.nf'
include {BAM_QC as BAMQC_WGS}            from './modules/bamqc.nf'
include {BAM_QC as BAMQC_WES}            from './modules/bamqc.nf'
include {MARKDUP_ADDRG as PREP_WGS}      from './modules/prep_bam.nf'
include {MARKDUP_ADDRG as PREP_WES}      from './modules/prep_bam.nf'
include {CALL_VARIANTS as CALL_WGS}      from './modules/call_variants.nf'
include {CALL_VARIANTS as CALL_WES}      from './modules/call_variants.nf'
include {DELLY_SV}                       from './modules/delly.nf'
include {ANNOTATE as ANNOTATE_WGS}       from './modules/annotate.nf'
include {ANNOTATE as ANNOTATE_WES}       from './modules/annotate.nf'
include {DOWNLOAD_VEP_CACHE}             from './modules/annotate.nf'
include {LOCUS_CHECK as LOCUS_WGS}       from './modules/locus_check.nf'
include {LOCUS_CHECK as LOCUS_WES}       from './modules/locus_check.nf'

workflow {

    //  reference
    ref = PREPARE_REFERENCE(file(params.ref_fasta))
    // ref emits: tuple(fasta, fai, dict)

    // WGS path 
    // wgs_bam = PREFETCH_WGS(params.wgs_srr)
    // BAMQC_WGS(wgs_bam)
    // wgs_prep = PREP_WGS(wgs_bam, 'SAMN17983068')
    // wgs_vcf = CALL_WGS(wgs_prep, ref)
    // DELLY_SV(wgs_prep, ref) // SV calling (WGS only)
    // wgs_ann = ANNOTATE_WGS( wgs_vcf, file(params.vep_cache))
    // LOCUS_WGS(wgs_vcf, ref, params.locus, 'WGS') // key result

    // WES path 
    wes_bam  = PREFETCH_WES(params.wes_srr)
    BAMQC_WES(wes_bam)
    wes_prep = PREP_WES(wes_bam, 'SAMN17983069')
    wes_vcf = CALL_WES(wes_prep, ref)
    vep_cache = DOWNLOAD_VEP_CACHE()
    wes_ann = ANNOTATE_WES( wes_vcf, vep_cache )
    LOCUS_WES(wes_vcf, ref, params.locus, 'WES') // key result
}

