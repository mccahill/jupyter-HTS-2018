# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

FROM debian:jessie 

MAINTAINER Mark McCahill "mark.mccahill@duke.edu"

USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN REPO=http://cdn-fastly.deb.debian.org \
 && echo "deb $REPO/debian jessie main\ndeb $REPO/debian-security jessie/updates main" > /etc/apt/sources.list \
 && apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    git \
    ssh \
    vim \
    jed \
    emacs \
    xclip \
    build-essential \
    python-dev \
    unzip \
    libsm6 \
    pandoc \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    libxrender1 \
    inkscape \
    rsync \
    gzip \
    tar \
    apt-utils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# Configure environment
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV SHELL /bin/bash
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/$NB_USER
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Create jovyan user with UID=1000 and in the 'users' group
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER $CONDA_DIR

USER $NB_USER

# Setup jovyan home directory
RUN mkdir /home/$NB_USER/work && \
    mkdir /home/$NB_USER/.jupyter && \
    mkdir /home/$NB_USER/.ssh && \
    printf "Host gitlab.oit.duke.edu \n \t IdentityFile ~/work/.HTSgitlab.key\n"  > /home/$NB_USER/.ssh/config && \
    echo "cacert=/etc/ssl/certs/ca-certificates.crt" > /home/$NB_USER/.curlrc

# Install conda as jovyan
RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.3.30-Linux-x86_64.sh && \
    # echo "bd1655b4b313f7b2a1f2e15b7b925d03 *Miniconda3-4.3.30-Linux-x86_64.sh" | sha256sum -c - && \
    /bin/bash Miniconda3-4.3.30-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-4.3.30-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda install --quiet --yes conda==4.3.30 && \
    $CONDA_DIR/bin/conda config --system --add channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false 
    # conda clean -tipsy

# Temporary workaround for https://github.com/jupyter/docker-stacks/issues/210
# Stick with jpeg 8 to avoid problems with R packages
### RUN echo "jpeg 8*" >> /opt/conda/conda-meta/pinned

# Install Jupyter notebook as jovyan
RUN conda install --quiet --yes \
    'jupyter' 
    # 'notebook' \
    # 'jupyterhub' \
    # 'jupyterlab' # \
    # && conda clean -tipsy
    
#----------- scipy
USER root

# libav-tools for matplotlib anim
RUN apt-get update && \
    apt-get install -y --no-install-recommends \ 
      libav-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

# Install Python 3 packages
# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
# use notebook-friendly backends in these images
RUN conda install --quiet --yes \
    'nomkl' \
    'ipywidgets' \
    'pandas' \
    'numexpr' \
    'matplotlib' \
    'scipy' \
    'seaborn' \
    'scikit-learn' \
    'scikit-image' \
    'sympy' \
    'cython' \
    'patsy' \
    'statsmodels' \
    'cloudpickle' \
    'dill' \
    'numba' \
    'bokeh' \
    'sqlalchemy' \
    'hdf5' \
    'h5py' \
	'pyzmq' \
    'vincent' \
    'beautifulsoup4' \
    'openpyxl' \
    'pandas-datareader' \
    'ipython-sql' \
    'pandasql' \
    'memory_profiler'\
    'psutil' \
    'cythongsl' \
    'joblib' \
    'ipyparallel' \
    'pybind11' \
    'pytables' \
    'plotnine' \
    'xlrd'  && \
    conda remove --quiet --yes --force qt pyqt # && \
    conda clean -tipsy

# Activate ipywidgets extension in the environment that runs the notebook server
RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix
RUN ipcluster nbextension  enable --user


# Install Python 2 packages
# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
# use notebook-friendly backends in these images
RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 \
    'nomkl' \
    'ipython=4.2*' \
    'ipywidgets=5.2*' \
    'pandas=0.19*' \
    'numexpr=2.6*' \
    'matplotlib=1.5*' \
    'scipy=0.17*' \
    'seaborn=0.7*' \
#    'scikit-learn=0.17*' \
#    'scikit-image=0.11*' \
#    'sympy=1.0*' \
#    'cython=0.23*' \
    'patsy=0.4*' \
    'statsmodels=0.6*' \
#    'cloudpickle=0.1*' \
#    'dill=0.2*' \
    'numba=0.23*' \
    'bokeh=0.11*' \
#    'hdf5=1.8.17' \
#    'h5py=2.6*' \
#    'sqlalchemy=1.0*' \
#    'pyzmq' \
#    'vincent=0.4.*' \
#    'beautifulsoup4=4.5.*' \
    'xlrd' && \
    conda remove -n python2 --quiet --yes --force qt pyqt && \
    conda clean -tipsy
# Add shortcuts to distinguish pip for python2 and python3 envs
RUN ln -s $CONDA_DIR/envs/python2/bin/pip $CONDA_DIR/bin/pip2 && \
    ln -s $CONDA_DIR/bin/pip $CONDA_DIR/bin/pip3

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg $CONDA_DIR/envs/python2/bin/python -c "import matplotlib.pyplot"

# Configure ipython kernel to use matplotlib inline backend by default
RUN mkdir -p $HOME/.ipython/profile_default/startup
COPY mplimporthook.py $HOME/.ipython/profile_default/startup/

USER root

# Install Python 2 kernel spec globally to avoid permission problems when NB_UID
# switching at runtime.
RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install

USER $NB_USER

#----------- end scipy

#----------- datascience
USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc  \
    graphviz \
    libgraphviz-dev \
    pkg-config && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

# R packages
RUN conda install  --yes \
    'r-base=3.4.1' \
    'r-irkernel=0.8*' \
    'r-plyr=1.8*' \
    'r-devtools=1.13*' \
    'r-tidyverse=1.1*' \
    'r-shiny=1.0*' \
    'r-rmarkdown=1.8*' \
    'r-forecast=8.2*' \
    'r-rsqlite=2.0*' \
    'r-reshape2=1.4*' \
    'r-nycflights13=0.2*' \
    'r-caret=6.0*' \
    'r-rcurl=1.95*' \
    'r-crayon=1.3*' \
    'r-randomforest=4.6*' \
    'r-htmltools=0.3*' \
    'r-sparklyr=0.7*' \
    'r-htmlwidgets=1.0*' \
    'r-hexbin=1.27*' && \
    conda clean -tipsy 

#----------- end datascience

USER root

EXPOSE 8888
WORKDIR /home/$NB_USER/work

# Configure container startup
ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /home/$NB_USER/.jupyter/
RUN chown -R $NB_USER:users /home/$NB_USER/.jupyter

#--------- Duke-specific additions ---
# add bash kernel for the user jovyan
USER jovyan
RUN pip install  bash_kernel
RUN python -m bash_kernel.install
USER root

RUN conda install --yes \
    'numpy' \
    'pillow' \
    'requests' \
    'nose' \
    'pystan' \
   && conda clean -yt

USER root

# we need dvipng so that matplotlib can do LaTeX
# we want OpenBLAS for faster linear algebra as described here: http://brettklamer.com/diversions/statistical/faster-blas-in-r/
# Armadillo C++ linear algebra library - see http://arma.sourceforge.net
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    dvipng \
    libopenblas-base \
    libarmadillo4 \
    libarmadillo-dev \
    liblapack3 \
    libblas-dev \
    liblapack-dev \
    libeigen3-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
 
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    graphviz \
    libgraphviz-dev \
    pkg-config && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
 

USER jovyan
# ggplot
#
#RUN pip install ggplot
RUN pip install cppimport

# pgmpy is not available in anaconda, so we use pip to install it
RUN pip install pgmpy
RUN pip install pygraphviz


####### start HTS-summer-2018 additions

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    less \
    make \
    libxml2-dev \
    libgsl0-dev \
    fastqc default-jre \
    openjdk-7-jdk \
    circos \
    parallel \
    time \
    htop \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >  /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get -t jessie-backports install -y --no-install-recommends \
    bwa \
    samtools \
    tabix \
    picard-tools \
    openjdk-8-jdk \
    openjdk-8-jre \
    sra-toolkit \
    bcftools \
    bedtools \
    vcftools \
    seqtk \
    ea-utils \
    rna-star \
    lftp \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#  this part of the build hangs seemingly forever - so comment it out for now
# RUN Rscript -e "install.packages(pkgs = c('pwr','RColorBrewer','GSA','dendextend','pheatmap','cgdsr', 'caret', 'ROCR'), \
#    repos='https://cran.revolutionanalytics.com/', \
#    dependencies=TRUE)"
# RUN Rscript -e "source('https://bioconductor.org/biocLite.R'); \
#     biocLite(pkgs=c('DESeq2','qvalue','multtest','org.EcK12.eg.db','genefilter','GEOquery','KEGG.db','golubEsets', \
#     'ggbio', 'limma'))"


# Install R and bioconductor packages for Kouros's notebooks
RUN Rscript -e "install.packages(pkgs = c('ROCR','mvtnorm','pheatmap','formatR'), \
            repos='https://cran.revolutionanalytics.com/', \
            dependencies=TRUE)"
RUN Rscript -e "install.packages(pkgs = c('dendextend'), \
            repos='https://cran.revolutionanalytics.com/', \
            dependencies=TRUE)"
RUN Rscript -e "source('https://bioconductor.org/biocLite.R'); \
    biocLite(pkgs=c('golubEsets','multtest','qvalue','limma','gage','pheatmap'))"

USER $NB_USER


# Configure ipython kernel to use matplotlib inline backend by default
RUN mkdir -p $HOME/.ipython/profile_default/startup
# COPY mplimporthook.py $HOME/.ipython/profile_default/startup/

USER root

# RUN conda install --quiet --yes -c r r-essentials
# RUN conda install --quiet --yes -c bioconda bioconductor-ggbio
RUN conda install --quiet --yes -c bioconda bioconductor-shortread
RUN conda install --quiet --yes -c bioconda bioconductor-dada2
RUN conda install --quiet --yes 'nbdime' 
RUN conda install --quiet --yes -c bioconda bioconductor-deseq2 bioconductor-pathview r-rentrez
RUN conda install --quiet --yes -n python2 --channel https://conda.anaconda.org/Biobuilds htseq pysam biopython tophat

# add htseq-count to path
ENV PATH=${PATH}:$CONDA_DIR/envs/python2/bin

# Setup up git auto-completion based on https://git-scm.com/book/en/v1/Git-Basics-Tips-and-Tricks#Auto-Completion
# RUN wget --directory-prefix /etc/bash_completion.d/ \
#      https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

# directories to hold data for the students and a common shared space
#######
# RUN mkdir /data /shared_space 
# RUN chown jovyan /data /shared_space 

####### end HTS-summer-2018 additions

#------end Duke-specific additions ---

# Switch back to jovyan to avoid accidental container runs as root
USER jovyan

