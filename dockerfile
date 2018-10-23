FROM nvidia/cuda:latest as build

LABEL com.nvidia.volumes.needed="nvidia_driver"

WORKDIR /root/mathewmiller/

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

RUN /opt/conda/bin/conda update conda

RUN git clone https://github.com/fastai/fastai.git ./fastaiv1/
RUN ls && /opt/conda/bin/conda env create

RUN /opt/conda/bin/conda install --name fastai -c conda-forge jupyterlab
RUN /opt/conda/bin/conda install --name fastai -c pytorch pytorch-nightly cuda92
RUN /opt/conda/bin/conda install --name fastai -c fastai torchvision-nightly
RUN /opt/conda/bin/conda install --name fastai -c fastai fastai
RUN /opt/conda/bin/conda install --name fastai -c fastai fastprogress
RUN /opt/conda/bin/conda clean -ya


RUN git clone https://github.com/fastai/fastai.git
 
RUN mkdir ~/fastai_setup ; cd ~/fastai_setup ; \
 wget -q https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh -O ~/fastai_setup/Anaconda_Install.sh ;\
 chmod u+x ~/fastai_setup/Anaconda_Install.sh ; \
 cd ~/fastai_setup ; \
 bash "Anaconda_Install.sh" -b ; \
 echo "export PATH=\"$HOME/anaconda3/bin:\$PATH\"" >> ~/.bashrc; \
 export PATH="$HOME/anaconda3/bin:$PATH"; \
 rm -r ~/fastai_setup
RUN ["/bin/bash","--login","-c"," \
 cd ~ && \
 ls -lah && \
 git clone https://github.com/fastai/fastai.git && \
 cd fastai && \
 ~/anaconda3/bin/conda env update -q"]
ENV PATH ~/anaconda3/envs/fastai/bin:$PATH
RUN ~/anaconda3/envs/fastai/bin/jupyter notebook --generate-config &&\
 echo "c.NotebookApp.token = ''" >> ~/.jupyter/jupyter_notebook_config.py &&\
 #Jeremy’s old default password from the early lessons.  Not sure if he’s changed it in the new lessons.  You can change this if you want.
 echo "c.NotebookApp.password = u'sha1:0799d4d911b0:bf164ace01e6a4d833e43a6ef720b660641ad512'" >> ~/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.allow_root = True" >> ~/.jupyter/jupyter_notebook_config.py
EXPOSE 8888:8888
CMD ["/bin/bash","-c","jupyter notebook"]
