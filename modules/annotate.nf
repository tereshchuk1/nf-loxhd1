// Functional annotation via Ensembl VEP, release 104.

process DOWNLOAD_VEP_CACHE {
    // bare Ubuntu — we just need wget + tar, no bioinformatics tools
    container 'ubuntu:22.04'
    containerOptions '--user root'   // apt-get install needs root

    output:
    path 'vep_cache'               

    script:
    """
    set -e
    mkdir -p vep_cache
    cd vep_cache

    # skip if already extracted 
    if [ -d canis_lupus_familiaris/104_CanFam3.1 ]; then
        echo "VEP cache already present, skipping download."
        exit 0
    fi

    apt-get update -qq
    apt-get install -y -qq wget

    wget https://ftp.ensembl.org/pub/release-104/variation/vep/canis_lupus_familiaris_vep_104_CanFam3.1.tar.gz
    tar xzf canis_lupus_familiaris_vep_104_CanFam3.1.tar.gz
    rm canis_lupus_familiaris_vep_104_CanFam3.1.tar.gz

    ls -la canis_lupus_familiaris/104_CanFam3.1/   # sanity check
    """
}

process ANNOTATE {
    tag "${srr}"
    // VEP 104 must match cache 104 
    container "quay.io/biocontainers/ensembl-vep:104.3--pl5262h4a94de4_0"
    publishDir "${params.outdir}/vcf", mode: 'copy'

    input:
    tuple val(srr), path(vcf), path(tbi)
    path vep_cache

    output:
    path "${srr}.annotated.vcf.gz"

    script:
    """
    set -euo pipefail

    # Our VCF uses 'chr7', but the Ensembl cache uses plain '7'. Strip 'chr' prefix 
    # in both data rows and contig header lines — otherwise VEP silently emits empty annotations.
    zcat ${vcf} | sed 's/^chr//; s/contig=<ID=chr/contig=<ID=/' > input.nochr.vcf

    vep \\
        --species canis_lupus_familiaris \\
        --offline --cache \\
        --dir_cache ${vep_cache} \\
        --cache_version 104 \\
        --vcf --force_overwrite \\
        -i input.nochr.vcf \\
        -o ${srr}.annotated.vcf \\
        --no_stats

    # bgzip for random-access compatibility with downstream tools.
    bgzip -c ${srr}.annotated.vcf > ${srr}.annotated.vcf.gz
    """
}