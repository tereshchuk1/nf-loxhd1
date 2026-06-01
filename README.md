# nf-loxhd1

A Nextflow + Docker pipeline that reproduces the publicly executable part of Hytönen et al. 2021,
*Missense variant in LOXHD1 is associated with canine nonsyndromic hearing loss*
(Human Genetics 140:1611–1618, [doi:10.1007/s00439-021-02286-z](https://doi.org/10.1007/s00439-021-02286-z)).

Starting from raw SRA data for one publicly deposited affected Rottweiler, the pipeline runs
an end-to-end germline variant workflow on canFam3.1 and outputs the genotype at the LOXHD1
candidate locus plus a VEP-annotated VCF.

## Key result

| | |
|---|---|
| Sample | SRR13743383 (BioSample `SAMN17983069`, affected Rottweiler, WES) |
| Position | chr7:44,806,821 |
| Variant | G > C |
| Genotype | 1/1 (homozygous ALT, C/C) |
| Depth | DP=32, AD=0,28 (0 REF, 28 ALT reads) |
| Quality | QUAL=895, GQ=84, MQ=60 |
| VEP annotation | LOXHD1 missense, p.(Gly1914Ala), c.5747G>C |

Full output: `results/locus/SRR13743383_WES_locus.txt`.
Detailed results: [RESULTS.md](RESULTS.md).

## Pipeline structure

Eight Nextflow DSL2 processes connected as a DAG:

```
PREPARE_REFERENCE
        |
PREFETCH_WES --> SAM2BAM_WES --> BAMQC_WES
                       |
                       v
                   PREP_WES --> CALL_WES --> ANNOTATE_WES <-- DOWNLOAD_VEP_CACHE
                                       \
                                        --> LOCUS_WES   (key result)
```

| Process | Purpose | Tool |
|---|---|---|
| `PREPARE_REFERENCE` | Rename NCBI contigs (NC_*) to chr-style; index | samtools 1.19 |
| `PREFETCH_WES` | Pull aligned BAM from SRA via prefetch + sam-dump | sra-tools 3.1.1 |
| `SAM2BAM_WES` | Convert sam-dump output to BAM | samtools 1.19 |
| `BAMQC_WES` | Mapping/coverage QC, contig-name sanity check | samtools 1.19 |
| `PREP_WES` | Add read groups, coordinate-sort, mark duplicates | GATK 4.5.0 |
| `CALL_WES` | HaplotypeCaller (-ERC GVCF) then GenotypeGVCFs | GATK 4.5.0 |
| `DOWNLOAD_VEP_CACHE` | Fetch Ensembl release-104 cache (CanFam3.1) | ubuntu + wget |
| `ANNOTATE_WES` | Functional annotation | Ensembl VEP 104 |
| `LOCUS_WES` | Extract genotype at candidate position | bcftools 1.19 |

The WGS branch is wired in `main.nf` but commented out — disk constraints in the development
environment, and the WES branch alone reproduces the key result.

## Requirements

- Linux (tested on Ubuntu 22.04 / WSL2)
- Nextflow ≥ 22.10
- Docker
- ~20 GB free disk for work and results
- ~8 GB RAM (GATK)

## Reference download

The canFam3.1 FASTA is not bundled (2.4 GB). Get it from NCBI:

```bash
mkdir -p assets && cd assets
datasets download genome accession GCF_000002285.3 --include genome
unzip ncbi_dataset.zip
mv ncbi_dataset/data/GCF_000002285.3/*.fna canFam3.1.fa
```

## Run

```bash
nextflow run main.nf -profile docker \
    --wes_srr SRR13743383 \
    --ref_fasta assets/canFam3.1.fa \
    --locus chr7:44806821-44806821
```

Use `-resume` to skip cached steps on rerun.

## Output layout

```
results/
  reference/   canFam3.1 with renamed contigs, plus .fai and .dict
  bam/         prepared BAMs (ready for variant calling)
  qc/          flagstat, idxstats, contig-name dump
  vcf/         raw VCF and VEP-annotated VCF
  locus/       genotype at the target position  (key result)
  pipeline_info/  Nextflow execution report, timeline, DAG
```

## Deviations from the original methods

- BQSR omitted. There is no public canine known-sites VCF for standardised recalibration.
  HaplotypeCaller is robust without BQSR at a high-confidence locus
- No joint-genotyping with controls. The paper joint-genotypes against 637 private DBVDC
  control genomes. With one public affected sample, this pipeline does targeted
  verification of the published variant rather than de novo discovery.
- WGS branch not executed. WES alone (~3.4 GB) is enough to verify the coding variant. 
- Indel realignment skipped. Removed in GATK4 best practices since HaplotypeCaller does local
  reassembly around active regions.

## Steps not included (private data)

- SNP-array genotyping and QC of 8 affected dogs 
- PLINK homozygosity mapping and case-specific ROH intersection 
- Joint-genotyping with the DBVDC control cohort 
- Sanger validation across 585 Rottweilers and the 28k commercial breed screen 

## Repository layout

```
nf-loxhd1/
  main.nf              orchestrator
  nextflow.config      executor and container config
  modules/             per-tool Nextflow processes
  results/             pipeline outputs 
  README.md            this file
  RESULTS.md           full results breakdown with numbers
```

## Reference

Hytönen MK et al. *Missense variant in LOXHD1 is associated with canine nonsyndromic hearing
loss.* Hum Genet 140:1611–1618 (2021).
[doi:10.1007/s00439-021-02286-z](https://doi.org/10.1007/s00439-021-02286-z)