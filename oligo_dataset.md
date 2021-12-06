---
layout: article
title: Oligo Datasets
comments: false
permalink: /Download/oligo_datasets
---

The oligo datasets currently host oligo sequences of 9 species, including six plant species (Arabidopsis, rice, maize, potato, barley and soybean), two mammals (human and mouse) and a model species zebrafish. The details of the oligos are showed in the bellow table.  
To download the oligos, please click the download link of the speices. Details about [Chorus2](#chorus_def), which was used to design the oligos can be found [here](https://github.com/zhangtaolab/Chorus2).

#### Information table

<style type="text/css">
    table {
        width: 100%; 
        max-width: 65em; 
        border: 1px solid #dedede; 
        margin: 15px auto; 
        border-collapse: collapse; 
        empty-cells: show; 
    }
    table th,
    table td {
        border: 1px solid #dedede; 
        padding: 0 10px; 
    }
    table th {
        font-weight: bold;
        background: rgb(245, 245, 245); 
}
</style>

|Species|Scientific name |Reference |No. of oligos |Download1|Download2|
|---        |---                   |---                                                                   |---         |---     |---     |
|Arabidopsis|*Arabidopsis thaliana*|[TAIR10](https://www.arabidopsis.org/)                                |1,089,367   |[bed](http://jianglab.plantbiology.msu.edu/oligo_datasets/data/TAIR10.bed.bgz)|[bed](https://bioinfor.yzu.edu.cn/download/oligodatasets/TAIR10.bed.bgz)|
|Rice       |*Oryza sativa*        |[TIGR7](http://rice.plantbiology.msu.edu/)                            |1,710,279   |[bed](http://jianglab.plantbiology.msu.edu/oligo_datasets/data/TIGR7.bed.bgz)|[bed](https://bioinfor.yzu.edu.cn/download/oligodatasets/TIGR7.bed.bgz)|
|Maize      |*Zea mays*            |[B73_v4](https://www.maizegdb.org/)                                   |1,641,770   |[bed](http://jianglab.plantbiology.msu.edu/oligo_datasets/data/B73_v4.bed.bgz)|[bed](https://bioinfor.yzu.edu.cn/download/oligodatasets/B73_v4.bed.bgz)|
|Potato     |*Solanum tuberosum*   |[DM_v4.04](http://solanaceae.plantbiology.msu.edu/pgsc_download.shtml)|1,674,902   |[bed](http://jianglab.plantbiology.msu.edu/oligo_datasets/data/DM_v404.bed.bgz)|[bed](https://bioinfor.yzu.edu.cn/download/oligodatasets/DM_v404.bed.bgz)|
|Barley     |*Hordeum vulgare*     |[IBSC_v2](http://plants.ensembl.org/Hordeum_vulgare/Info/Index)       |2,968,560   |[bed](http://jianglab.plantbiology.msu.edu/oligo_datasets/data/IBSC_v2.bed.bgz)|[bed](https://bioinfor.yzu.edu.cn/download/oligodatasets/IBSC_v2.bed.bgz)|
|Soybean    |*Glycine max*         |[Gmax_ZH13_v2.0](https://bigd.big.ac.cn/gwh/Assembly/652/show)        |1,851,420   |[bed](http://jianglab.plantbiology.msu.edu/oligo_datasets/data/Gmax_ZH13_v2.bed.bgz)|[bed](https://bioinfor.yzu.edu.cn/download/oligodatasets/Gmax_ZH13_v2.bed.bgz)|
|Human      |*Homo sapiens*        |[hg38](http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips)        |2,311,370   |[bed](http://jianglab.plantbiology.msu.edu/oligo_datasets/data/hg38.bed.bgz)|[bed](https://bioinfor.yzu.edu.cn/download/oligodatasets/hg38.bed.bgz)|
|Mouse      |*Mus musculus*        |[mm10](http://hgdownload.soe.ucsc.edu/goldenPath/mm10/bigZips)        |3,397,774   |[bed](http://jianglab.plantbiology.msu.edu/oligo_datasets/data/mm10.bed.bgz)|[bed](https://bioinfor.yzu.edu.cn/download/oligodatasets/mm10.bed.bgz)|
|Zebrafish  |*Danio rerio*         |[danRer11](http://hgdownload.soe.ucsc.edu/goldenPath/danRer11/bigZips)|2,442,308   |[bed](http://jianglab.plantbiology.msu.edu/oligo_datasets/data/danRer11.bed.bgz)|[bed](https://bioinfor.yzu.edu.cn/download/oligodatasets/danRer11.bed.bgz)|


**Images**

|<img src="{{ site.baseurl }}/assets/images/species_img/arabidopsis.jpeg" width="50%">|<img src="{{ site.baseurl }}/assets/images/species_img/rice.jpeg" width="50%">|<img src="{{ site.baseurl }}/assets/images/species_img/maize.jpeg" width="50%">|
|Arabidopsis|Rice|Maize|
|<img src="{{ site.baseurl }}/assets/images/species_img/potato.jpeg" width="50%">|<img src="{{ site.baseurl }}/assets/images/species_img/barley.jpeg" width="50%">|<img src="{{ site.baseurl }}/assets/images/species_img/soybean.jpeg" width="50%">|
|Potato|Barley|Soybean|
|<img src="{{ site.baseurl }}/assets/images/species_img/human.jpeg" width="50%">|<img src="{{ site.baseurl }}/assets/images/species_img/mouse.jpeg" width="50%">|<img src="{{ site.baseurl }}/assets/images/species_img/zebrafish.jpeg" width="50%">|
|Human|Mouse|Zebrafish|

<br/>

#### How to use the datasets

To use the oligo sequences of the target species, users should first download the *bed* file from the download column in the above table.  
Oligo sequences are provided with *bed.bgz* format, which is a compressed version of bed file. 
Users can decompress the file following the below instructions:  
**For Windows Users**:  
Download [7-Zip](https://www.7-zip.org/) software and install.  
![img]({{ site.baseurl }}/assets/images/7-zip_download.png)  
Use 7-Zip to uncompress *bed.bgz* file.  
![img]({{ site.baseurl }}/assets/images/7-zip_usage.png)  
**For Linux/MacOS Users**:  
Using the following command to uncompress *bed.bgz* file:  
`$ gzip -cd xxx.bed.bgz > xxx.bed`.  
![img]({{ site.baseurl }}/assets/images/gzip_usage.png)  

The decompressed bed file can be opened and read by text editor or *Excel* easily.  
**For Windows users**, text editor (Such as [*EditPlus*](https://www.editplus.com/)) is the optimum choice to open it.  
![img]({{ site.baseurl }}/assets/images/editplus_usage.png)  

The bed file contains six columns which are separated by delimiter, just like this:  
`Chr1	1360	1404	AAGATAGAGAACAAGAGAGTGAGAGGATAAGGATATAGACCAGAC	2841	+`  
Each column represents chromosome, oligo start site, oligo end site, oligo probe sequence, k-mer score and target strand of probes, respectively.  
Windows Users can use the filter function of *Excel* to select the target oligos.  
**For Linux/MacOS users**, `awk` or `perl` command may be a better method to select the desired oligo sequences. Just like this:  
`awk '$1=="Chr1"&&$2>=100000&&$3<=200000' TIGR7.bed`  
This command will extract oligos in the region Chr1:100000-200000 in rice.  
![img]({{ site.baseurl }}/assets/images/awk_oligo_usage.png)  

Finally, oligo sequences in the fourth column of the bed file can be synthesized directly for oligo-FISH experiments.  


<br/>

***

#### <a id="chorus_def" text-decoration="none">Chorus2</a>

[Chorus2](https://github.com/zhangtaolab/Chorus2) is a software which is developed to design genome-scale oligonucleotide-based probes for fluorescence *in situ* hybridization (FISH).  
Chorus2 uses python script Chorus2.py to identify and pre-filter oligos. It is implemented with a "k-mer score" method to remove repetitive oligos of target genome. Chorus2 run fast and can handle large genome like wheat. The oligos designed by Chorus2 has high specificity and suitable for FISH. The Chorus2 package runs on Linux, macOS and Windows with flexible command-line or an easy-to-use GUI (graphical user interface).

#### Citation
Zhang T†,\*, Liu GQ†, Zhao HN, Braz G.T, Jiang JM\*. Chorus2: design of genome-scale oligonucleotide-based probes for fluorescence *in situ* hybridization ***Plant Biotechnology Journal*** (2021) DOI: 10.1111/pbi.13610 (Accepted)
<br/>

**\* If there are any questions when using Chorus2 or our oligo datasets, please contact us ([hanyangshuo@zhangtaolab.org](mailto:hanyangshuo@zhangtaolab.org) or [liuguanqing@zhangtaolab.org](mailto:liuguanqing@zhangtaolab.org)).**

