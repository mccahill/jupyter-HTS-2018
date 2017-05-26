# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/r-notebook

MAINTAINER Jupyter Project <jupyter@googlegroups.com>

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    less \
    make \
    git \
    libxml2-dev \
    libgsl0-dev \
    fastqc default-jre \
    bwa \
    samtools \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
#     tophat \


RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >  /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get -t jessie-backports install -y --no-install-recommends tophat \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
#     tophat \


# apt-get -t jessie-backports install "package"



### ea-utils (fastq-mcf,etc.)
RUN wget "https://drive.google.com/uc?export=download&id=0B7KhouP0YeRAc2xackxzRnFrUEU" -O ea-utils.1.1.2-806.tar.gz; \
    tar -xvf ea-utils.1.1.2-806.tar.gz ; \
    cd ea-utils.1.1.2-806; \
    make; \
    cp -a fastq-*   /usr/local/bin/; \
    cd ~; \
    rm -rf ea-utils.1.1.2-806 ea-utils.1.1.2-806.tar.gz

### sra-toolkit
## apt-get -q -y  install sra-toolkit
RUN wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.4.3/sratoolkit.2.4.3-ubuntu64.tar.gz; \
    tar -zxf sratoolkit.2.4.3-ubuntu64.tar.gz; \
    cp -r sratoolkit.2.4.3-ubuntu64/bin/*  /usr/local/bin/; \
    rm sratoolkit.2.4.3-ubuntu64.tar.gz; \
    rm -r sratoolkit.2.4.3-ubuntu64; \
    vdb-config --restore-defaults; \
    echo "test sra-toolkit with the following command:"; \
    echo "fastq-dump -X 5 -Z SRR390728"

RUN Rscript -e "install.packages(pkgs = c('pwr','RColorBrewer','GSA','dendextend','pheatmap','cgdsr'), \
    repos='https://cran.revolutionanalytics.com/', \
    dependencies=TRUE)"
RUN Rscript -e "source('https://bioconductor.org/biocLite.R'); \
    biocLite(pkgs=c('DESeq2','qvalue','multtest','org.EcK12.eg.db','genefilter','GEOquery','KEGG.db'))"

USER jovyan
# Install Bash Kernel
RUN pip install --user --no-cache-dir bash_kernel && \
    python -m bash_kernel.install
##------------------------------------------------------------
##------------------------------------------------------------
##------------------------------------------------------------
# RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.revolutionanalytics.com/'; options(repos = r)" > ~/.Rprofile
# RUN Rscript -e "source('http://bioconductor.org/biocLite.R');biocLite(suppressUpdates = FALSE);biocLite('ShortRead', suppressUpdates = FALSE);biocLite('phyloseq', suppressUpdates = FALSE);biocLite('GenomicRanges', suppressUpdates = FALSE);biocLite('golubEsets', suppressUpdates = FALSE)"

# RUN Rscript -e "install.packages('grid');install.packages('ggthemes');install.packages('pwr');install.packages('Rmisc');install.packages('vcd')"
##------------------------------------------------------------
##------------------------------------------------------------
##------------------------------------------------------------
# Following to install python2, derived from https://github.com/jupyter/docker-stacks/blob/master/scipy-notebook/Dockerfile
USER $NB_USER

# Install Python 2 packages
# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
# use notebook-friendly backends in these images
RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 \
    'ipython=4.2*' \
    && \
    conda clean -tipsy
##    'ipywidgets=5.1*' \
##     conda remove -n python2 --quiet --yes --force qt pyqt && \

# Add shortcuts to distinguish pip for python2 and python3 envs
RUN ln -s $CONDA_DIR/envs/python2/bin/pip $CONDA_DIR/bin/pip2 && \
    ln -s $CONDA_DIR/bin/pip $CONDA_DIR/bin/pip3

# Configure ipython kernel to use matplotlib inline backend by default
RUN mkdir -p $HOME/.ipython/profile_default/startup
# COPY mplimporthook.py $HOME/.ipython/profile_default/startup/

USER root

# Install Python 2 kernel spec globally to avoid permission problems when NB_UID
# switching at runtime.
# RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install

RUN conda install --quiet --yes -n python2 --channel https://conda.anaconda.org/Biobuilds htseq pysam biopython
# RUN conda install --quiet --yes -n python2 --channel https://conda.anaconda.org/Biobuilds pysam
# RUN conda install --quiet --yes -n python2 --channel https://conda.anaconda.org/Biobuilds biopython

# add htseq-count to path
ENV PATH=${PATH}:$CONDA_DIR/envs/python2/bin
