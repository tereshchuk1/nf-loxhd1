# Pipeline Results

End-to-end run of nf-loxhd1 on the publicly deposited WES sample from PRJNA702911.

- Sample: SRR13743383 (BioSample `SAMN17983069`, affected Rottweiler)
- Reference: canFam3.1 (`GCF_000002285.3`)
- Runtime: 4h 30m wall-clock, 7.8 CPU-hours
- Outcome: paper's central finding reproduced

## 1. Variant at LOXHD1 locus

The genotype at `chr7:44,806,821` matches the published variant:

```
#CHROM  POS         REF  ALT  QUAL    FORMAT             SAMN17983069
chr7    44806821    G    C    895.06  GT:AD:DP:GQ:PL     1/1:0,28:28:84:909,84,0
```

| Field | Value | Meaning |
|---|---|---|
| GT | 1/1 | Homozygous ALT — both copies are the mutant C allele |
| AD | 0,28 | 0 reads supporting REF (G), 28 supporting ALT (C) |
| DP | 32 | Total reads at this position |
| QUAL | 895.06 | Variant call confidence |
| GQ | 84 | Genotype call confidence |
| MQ | 60 | Mapping quality (maximum) |
| AF | 1.00 | All alleles in this sample are ALT |
| QD | 31.97 | Quality-by-depth, passes filter (>2) |

The affected dog is homozygous for the C allele at chr7:44,806,821, matching the paper.

Source: `results/locus/SRR13743383_WES_locus.txt`.

## 2. VEP annotation confirms LOXHD1 missense

Ensembl release 104 (CanFam3.1) identifies the variant as a missense in LOXHD1 across all
five annotated transcripts:

| Transcript | Exon | AA position | Codon | AA change |
|---|---|---|---|---|
| ENSCAFT00000027958 | 37/41 | 1852 | gGg → gCg | G → A |
| ENSCAFT00000046415 | 35/39 | 1706 | gGg → gCg | G → A |
| ENSCAFT00000049867 | 38/42 | 1914 | gGg → gCg | G → A |
| ENSCAFT00000063075 | 9/13  | 150  | gGg → gCg | G → A |
| ENSCAFT00000080394 | 18/23 | 801  | gGg → gCg | G → A |

`ENSCAFT00000049867` is the canonical full-length isoform; its amino-acid position 1914
matches the paper's nomenclature p.(Gly1914Ala). The variant lies in the 14th of 15 PLAT
domains.

The cDNA coordinate in VEP output (5741) differs from the paper's `c.5747G>C` because of
different 5′ UTR definitions between Ensembl and RefSeq transcripts. The genomic change
(chr7:44806821 G>C) and the protein change (Gly1914Ala) are identical.

## 3. Variant calling statistics

| Metric | Value |
|---|---|
| Total variants (raw VCF) | 755,487 |
| Total variants (annotated VCF) | 755,487 |
| Variants with VEP CSQ annotation | 755,487 (100%) |

100% annotation rate confirms no silent failures from contig-name mismatch.

## 4. Mapping QC

`samtools flagstat`:

| Metric | Value |
|---|---|
| Total reads | 109,128,265 |
| Mapped | 100.00% |
| Properly paired | 99.36% |
| Duplicates | 8,438,944 (7.7%) |
| Singletons | 0 |

Data quality is in the normal range for WES, no flags for contamination or library issues.

## 5. Coverage by chromosome (top 10)

`samtools idxstats`:

| Chromosome | Length (bp) | Mapped reads | Reads/Mb |
|---|---:|---:|---:|
| chr1  | 122,678,785 | 6,642,133 | 54.1 |
| chr2  | 85,426,708  | 4,578,715 | 53.6 |
| chr3  | 91,889,043  | 3,860,589 | 42.0 |
| chr4  | 88,276,631  | 3,906,712 | 44.3 |
| chr5  | 88,915,250  | 4,686,654 | 52.7 |
| chr6  | 77,573,801  | 4,421,591 | 57.0 |
| chr7  | 80,974,532  | 4,220,612 | 52.1 |
| chr8  | 74,330,416  | 3,607,647 | 48.5 |
| chr9  | 61,074,082  | 4,632,924 | 75.9 |
| chr10 | 69,331,447  | 3,544,037 | 51.1 |

Balanced coverage across chromosomes (40–80 reads/Mb), no anomalies. chr7 has expected
coverage (52 reads/Mb).

## 6. Pipeline artifacts

| Output | Size | Description |
|---|---|---|
| `results/locus/SRR13743383_WES_locus.txt` | 4 KB | Genotype at chr7:44,806,821 (key result) |
| `results/vcf/SRR13743383.vcf.gz` | 27 MB | Raw VCF from GenotypeGVCFs |
| `results/vcf/SRR13743383.annotated.vcf.gz` | 36 MB | VCF with VEP CSQ field |
| `results/qc/SRR13743383.flagstat.txt` | 4 KB | Mapping statistics |
| `results/qc/SRR13743383.idxstats.txt` | 4 KB | Per-chromosome read counts |
| `results/qc/SRR13743383.chrnames.txt` | 4 KB | BAM contig naming |
| `results/pipeline_info/report.html` | 1.6 MB | Nextflow resource usage |
| `results/pipeline_info/timeline.html` | 250 KB | Process execution timeline |
| `results/pipeline_info/dag.html` | 2 KB | DAG visualization |

## 7. Execution summary

All 8 processes completed:

```
PREPARE_REFERENCE     1/1   (rename + index canFam3.1)
PREFETCH_WES          1/1   (SRA download + sam-dump)
BAMQC_WES             1/1   (flagstat + idxstats + chrnames)
PREP_WES              1/1   (RG + sort + MarkDuplicates + index)
CALL_WES              1/1   (HaplotypeCaller gVCF + GenotypeGVCFs)
DOWNLOAD_VEP_CACHE    1/1   (Ensembl release-104 cache)
ANNOTATE_WES          1/1   (VEP functional annotation)
LOCUS_WES             1/1   (genotype extraction)

Duration:  4h 30m 37s
CPU hours: 7.8
Status:    Completed (8/8 succeeded)
```

Per-process resource usage in `results/pipeline_info/report.html`.

## Summary

| | |
|---|---|
| Paper's claim | Affected Rottweilers are homozygous for LOXHD1 c.5747G>C, p.(Gly1914Ala) at chr7:44,806,821 |
| Pipeline finding | `SAMN17983069` is 1/1 at chr7:44,806,821 with 28 ALT / 0 REF reads; VEP confirms missense in LOXHD1 with p.Gly1914Ala across all 5 transcripts |
| Verdict | Reproduced on independent processing of public SRA data |

The variant signal (28/0 alt/ref reads, QUAL=895, GQ=84) is strong enough that the call is
unambiguous regardless of the deviations documented in the README (no BQSR, no joint-genotyping
with a control cohort).