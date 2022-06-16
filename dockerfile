FROM nvidia/cuda:11.3.1-runtime-ubuntu18.04 as build

LABEL com.nvidia.volumes.needed="nvidia_driver"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV SHELL /bin/bash
ENV GRADIO_SERVER_NAME=0.0.0.0
WORKDIR /root

RUN apt-get update && apt-get install -y --no-install-recommends \
 build-essential \
 ca-certificates \
 cmake \
 curl \
 git \
 graphviz \
# libjpeg-dev \
# libpng-dev \
# libsm6 \
# libxext6 \
# libxrender-dev \
 nano \
# python-qt4 \
 unzip \
 software-properties-common \
 tmux \
 vim \
 wget \
 zip &&\
 rm -rf /var/lib/apt/lists/*
 
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh &&\
 bash miniconda.sh -b -p /root/miniconda && rm miniconda.sh &&\
 /root/miniconda/bin/conda update conda -y &&\
 /root/miniconda/bin/conda install pytorch torchvision torchaudio cudatoolkit=11.3 -c pytorch -y &&\
 /root/miniconda/bin/conda install -c fastai fastai -y &&\
 /root/miniconda/bin/conda init bash &&\
 /root/miniconda/bin/conda install jupyter &&\
 /root/miniconda/bin/conda clean -ya &&\
 /root/miniconda/bin/pip install fastbook gradient gradio graphviz huggingface_hub ipywidgets jupyter_contrib_nbextensions nbdev nbconvert timm transformers[torch] wandb &&\
 /root/miniconda/bin/jupyter contrib nbextension install --sys-prefix

SHELL ["/bin/bash", "-c"]

WORKDIR /root

RUN /root/miniconda/bin/jupyter notebook --generate-config &&\
 echo "c.ServerApp.token = ''" >> /root/.jupyter/jupyter_notebook_config.py &&\
 #Jeremy’s old default password from the early lessons.  Not sure if he’s changed it in the new lessons.  You can change this if you want.
 echo "c.NotebookApp.password = u'sha1:0799d4d911b0:bf164ace01e6a4d833e43a6ef720b660641ad512'" >> /root/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.allow_root = True" >> /root/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.notebook_dir = '/home/mathewmiller'" >> /root/.jupyter/jupyter_notebook_config.py

RUN echo "#!/bin/bash" >> /root/run_jupyter.sh &&\
 echo "cd /home/mathewmiller" >> /root/run_jupyter.sh &&\
 echo "/root/miniconda/bin/jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root --no-browser --config=/root/.jupyter/jupyter_notebook_config.py" >> /root/run_jupyter.sh &&\
 chmod u+x /root/run_jupyter.sh

#Jupyter Gradio
EXPOSE 8888:8888 7860-7960:7860-7960

CMD ["/bin/bash","-c","/root/run_jupyter.sh"]

#sudo docker run --gpus all -p 8888:8888 -d --shm-size 8G -v /home/mathewmiller/:/home/mathewmiller --restart unless-stopped --name fastai2-9 my_fastai:2022-04-28
