FROM jupyter/minimal-notebook:abdb27a6dfbb

MAINTAINER Jupyter Help <jupyter-help@brown.edu>


USER root

# Install missing tools
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade \
    && apt-get install -yq --no-install-recommends \
    libssl-dev \
    openssh-client \
    vim \ 
    && apt-get clean \
    && apt-get -y build-dep r-base \
    && apt-get clean


USER $NB_UID


RUN pip install --upgrade pip
RUN npm i npm@latest -g

# *********************Compile R From Source*****************

RUN wget https://cran.r-project.org/src/base/R-3/R-3.5.3.tar.gz \
  && tar -xf R-3.5.3.tar.gz \
  && cd R-3.5.3 \
  && ./configure --with-x=no --with-cairo=yes --with-libpng=yes --enable-R-shlib --prefix=$HOME \
  && make

ENV PATH=/home/$NB_USER/R-3.5.3/bin:$PATH

# *********************Extensions ***************************

# Install google-drive extension
RUN jupyter labextension install @jupyterlab/google-drive

# Install nbgitpuller extension
RUN pip install nbgitpuller && \
    jupyter serverextension enable --py nbgitpuller --sys-prefix && \
    npm cache clean --force

# Install RISE extension
RUN pip install RISE && \
    jupyter nbextension install rise --py --sys-prefix &&\
    jupyter nbextension enable rise --py --sys-prefix &&\
    npm cache clean --force

# RUN jupyter labextension install @jupyterlab/git && \
#     pip install jupyterlab-git && \
#     jupyter serverextension enable --py jupyterlab_git &&\
#     npm cache clean --force

# Clean up and fix permissions    
RUN rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# *********************R Extras ***************************
# R packages including IRKernel which gets installed globally.

RUN wget https://raw.githubusercontent.com/compbiocore/docker-stacks/master/jupyterhub/r_scripts/irkernel.R \
  && Rscript irkernel.R \
  && fix-permissions /home/$NB_USER
