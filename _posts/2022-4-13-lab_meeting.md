---
layout: meeting
title: "ReFeaFi: Genome-wide prediction of regulatory elements driving transcription initiation"
image: assets/images/lab_meeting/2022-04-13.png
author: lgq
source: https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1009376
is_meeting: true
categories: [Lab Meeting]
hostDate: 2022-4-16
journal: PLOS Computational Biology (2021)
---
### Abstract:
Regulatory elements control gene expression through transcription initiation (promoters) and by enhancing transcription at distant regions (enhancers). Accurate identification of regulatory elements is fundamental for annotating genomes and understanding gene expression patterns. While there are many attempts to develop computational promoter and enhancer identification methods, reliable tools to analyze long genomic sequences are still lacking. Prediction methods often perform poorly on the genome-wide scale because the number of negatives is much higher than that in the training sets. To address this issue, we propose a dynamic negative set updating scheme with a two-model approach, using one model for scanning the genome and the other one for testing candidate positions. The developed method achieves good genome-level performance and maintains robust performance when applied to other vertebrate species, without re-training. Moreover, the unannotated predicted regulatory regions made on the human genome are enriched for disease-associated variants, suggesting them to be potentially true regulatory elements rather than false positives. We validated high scoring “false positive” predictions using reporter assay and all tested candidates were successfully validated, demonstrating the ability of our method to discover novel human regulatory regions.

#### Source: [{{page.journal}}]({{page.source}})
