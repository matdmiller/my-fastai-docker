FROM nvidia/cuda:11.3.1-runtime-ubuntu18.04 as build

LABEL com.nvidia.volumes.needed="nvidia_driver"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV SHELL /bin/bash
WORKDIR /root

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
 
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh | bash

RUN /root/anaconda3/bin/conda update conda

#RUN git clone https://github.com/fastai/fastai.git .
#RUN ls && /root/anaconda3/bin/conda env create

#ENV PATH /root/anaconda3/envs/fastai/bin:$PATH
#ENV PATH /root/anaconda3/bin:$PATH
#ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
#ENV USER fastai

#RUN source activate fastai
#RUN source ~/.bashrc

RUN /root/anaconda3/bin/conda install -c fastchan fastai anaconda
#RUN /root/anaconda3/bin/conda install --name fastai -c conda-forge jupyterlab
#RUN /root/anaconda3/bin/conda install --name fastai -c pytorch -c fastai fastai
#RUN /root/anaconda3/bin/conda uninstall --name fastai --force jpeg libtiff -y
#RUN /root/anaconda3/bin/conda install --name fastai -c conda-forge libjpeg-turbo
#RUN echo ". /root/anaconda3/etc/profile.d/conda.sh" >> /root/.bashrc
#RUN /bin/bash && /root/anaconda3/bin/conda activate fastai && CC="cc -mavx2" pip install --no-cache-dir -U --force-reinstall --no-binary :all: --compile pillow-simd
RUN /root/anaconda3/bin/conda clean -ya

#WORKDIR /root

RUN /root/anaconda3/bin/jupyter notebook --generate-config &&\
 echo "c.NotebookApp.token = ''" >> ~/.jupyter/jupyter_notebook_config.py &&\
 #Jeremy’s old default password from the early lessons.  Not sure if he’s changed it in the new lessons.  You can change this if you want.
 echo "c.NotebookApp.password = u'sha1:0799d4d911b0:bf164ace01e6a4d833e43a6ef720b660641ad512'" >> ~/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py &&\
 echo "c.NotebookApp.allow_root = True" >> ~/.jupyter/jupyter_notebook_config.py

EXPOSE 8888:8888

WORKDIR /home/mathewmiller

CMD ["/bin/bash","-c","/root/anaconda3/envs/fastai/bin/jupyter notebook"]
#sudo docker run -itd -p 8888:8888 -p 6006:6006 -p 8008:8008 -p 8080:8080 --name fastai_v1_1 -v /home/mathewmiller:/root/mathewmiller --restart unless-stopped --ipc=host fastaiv1:latest /bin/bash -c "/root/anaconda3/envs/fastai/bin/jupyter notebook"
#sudo docker run --gpus all -p 8888:8888 -d --shm-size 8G -v /home/mathewmiller/:/home/mathewmiller --restart unless-stopped --name fastai2-7 fastdotai/fastai:latest ./run_jupyter.sh
