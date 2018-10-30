FROM nvidia/cuda:9.2-base-ubuntu18.04 as build

LABEL com.nvidia.volumes.needed="nvidia_driver"

WORKDIR /root/docker_copy_fastaiv1

RUN apt-get update && apt-get install -y --no-install-recommends \
 build-essential \
 ca-certificates \
 cmake \
 curl \
 git \
 libjpeg-dev \
 libpng-dev \
 libsm6 \
 libxext6 \
 libxrender-dev \
 nano \
 python-qt4 \
 unzip \
 tmux \ 
 vim \
 wget \
 zip &&\
 rm -rf /var/lib/apt/lists/*
 
RUN curl https://conda.ml | bash

RUN /root/anaconda3/bin/conda update conda

RUN git clone https://github.com/fastai/fastai.git .
RUN ls && /root/anaconda3/bin/conda env create

ENV PATH /root/anaconda3/envs/fastai/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV USER fastai

CMD source activate fastai
CMD source ~/.bashrc

RUN conda install --name fastai -c conda-forge jupyterlab
RUN conda install --name fastai -c pytorch pytorch-nightly cuda92
RUN conda install --name fastai -c fastai torchvision-nightly
RUN conda install --name fastai -c fastai fastai
RUN conda install --name fastai -c fastai fastprogress
RUN conda clean -ya

WORKDIR /root

RUN jupyter notebook --generate-config &&\
 echo "c.NotebookApp.token = ''" >> ~/.jupyter/jupyter_notebook_config.py &&\
 #Jeremy’s old default password from the early lessons.  Not sure if he’s changed it in the new lessons.  You can change this if you want.
 echo "c.NotebookApp.password = u'sha1:0799d4d911b0:bf164ace01e6a4d833e43a6ef720b660641ad512'" >> ~/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.allow_root = True" >> ~/.jupyter/jupyter_notebook_config.py
EXPOSE 8888:8888

WORKDIR /root/mathewmiller

CMD ["/bin/bash","-c","jupyter notebook"]
