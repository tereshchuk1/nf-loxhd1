# Pipeline Results

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
| QUAL | 895.06 | Variant call confidence (very high)|
| GQ | 84 | Genotype call confidence (high) |
| MQ | 60 | Mapping quality (maximum) |
| AF | 1.00 | All alleles in this sample are ALT |
| QD | 31.97 | Quality-by-depth, passes filter (>2) |

The affected dog is homozygous for the C allele at chr7:44,806,821, matching the paper.

Source: `results/locus/SRR13743383_WES_locus.txt`.

## 2. VEP annotation confirms LOXHD1 missense

VEP annotation (CanFam3.1) shows that this single variant (chr7:44806821 G>C) lies in 
the LOXHD1 gene and causes a missense substitution in every annotated isoform of the protein.

The gene has 5 annotated transcripts in Ensembl. Because the same nucleotide falls in a
different exon position within each isoform, the amino acid position differs,
but the underlying codon change is identical in all five: `gGg → gCg`, which
translates to Glycine → Alanine.

| Transcript | Exon | AA position | Codon | AA change |
|---|---|---|---|---|
| ENSCAFT00000027958 | 37/41 | 1852 | gGg → gCg | G → A |
| ENSCAFT00000046415 | 35/39 | 1706 | gGg → gCg | G → A |
| ENSCAFT00000049867 | 38/42 | 1914 | gGg → gCg | G → A |
| ENSCAFT00000063075 |  9/13 |  150 | gGg → gCg | G → A |
| ENSCAFT00000080394 | 18/23 |  801 | gGg → gCg | G → A |

`ENSCAFT00000049867` is the canonical full-length isoform — its amino-acid
position 1914 matches the paper's result (p.(G1914A)). 

## 3. Mapping QC

`samtools flagstat`:

| Metric | Value |
|---|---|
| Total reads | 109,128,265 |
| Mapped | 100.00% |
| Properly paired | 99.36% |
| Duplicates | 7.7% |
| Singletons | 0 |

Data quality is high for WES, no flags for contamination or library issues

## 4. Coverage by chromosome (top 10)

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

Balanced coverage across chromosomes, no anomalies. 

## Summary

- **Paper's claim**: affected Rottweilers carry two copies of `chr7:44,806,821 G>C`,
  a missense mutation in LOXHD1 changing protein position 1914 from glycine to alanine
  (`c.5747G>C, p.(Gly1914Ala)`).
- **Pipeline's finding**: in the public sequencing data of affected dog (`SAMN17983069`), 28/28 reads
  at chr7:44,806,821 carry the C allele — genotype `1/1`. Annotation confirms missense in
  LOXHD1 with the same Gly→Ala substitution across all five annotated transcripts.
