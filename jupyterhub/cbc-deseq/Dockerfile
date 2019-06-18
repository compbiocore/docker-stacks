FROM compbiocore/jupyterhub-cbc:latest

MAINTAINER Jupyter Help <jupyter-help@brown.edu>

USER root

USER $NB_UID

# ********************* Bioconductor Packages ***************************

RUN cd /opt/ \
  && wget https://raw.githubusercontent.com/compbiocore/docker-stacks/master/jupyterhub/r_scripts/install_all_deseq.R \
  && Rscript install_all_deseq.R \
  && fix-permissions /opt/R-3.5.3/
