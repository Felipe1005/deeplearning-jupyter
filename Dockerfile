# Use an official Python runtime as a parent image
FROM jupyter/base-notebook:ubuntu-18.04

WORKDIR /code/

USER root

RUN apt-get update && apt-get upgrade -y &&\
   apt-get install -y build-essential \
   cmake \
   unzip \
   pkg-config \
   libjpeg-dev \
   libpng-dev \
   libtiff-dev \
   libavcodec-dev \
   libavformat-dev \
   libswscale-dev \
   libv4l-dev \
   libxvidcore-dev \
   libx264-dev\
   libgtk-3-dev\
   libatlas-base-dev\
   gfortran\
#    python3-dev \
   wget\
   graphviz

# Install python libraries

RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py

RUN pip3 install --upgrade pip    
COPY ./requirements.txt /code/requirements.txt
RUN pip3 install -r /code/requirements.txt

# Install OpenCV

RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.4.0.zip && \
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.4.0.zip
    
RUN unzip opencv.zip && \
    unzip opencv_contrib.zip 

RUN rm open*zip

RUN mv opencv-4.4.0 opencv && \
    mv opencv_contrib-4.4.0 opencv_contrib

RUN cd opencv && \
    mkdir build && \
    cd build && \ 
    #cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_PYTHON_EXAMPLES=ON -D INSTALL_C_EXAMPLES=OFF -D OPENCV_ENABLE_NONFREE=ON -D OPENCV_EXTRA_MODULES_PATH=/code/opencv_contrib/modules -D PYTHON_EXECUTABLE=/opt/conda/bin/python -D BUILD_EXAMPLES=ON ..
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_PYTHON_EXAMPLES=ON -D INSTALL_C_EXAMPLES=OFF -D OPENCV_ENABLE_NONFREE=ON -D OPENCV_EXTRA_MODULES_PATH=/code/opencv_contrib/modules -D BUILD_opencv_python3=yes -D PYTHON3_EXECUTABLE=$(which python) -D PYTHON3_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") -D PYTHON3_PACKAGES_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") -D BUILD_EXAMPLES=ON ..

RUN cd opencv/build && \
    make -j8

RUN cd opencv/build && \
    ldconfig /etc/ld.so.conf.d

RUN mv /code/opencv/build/lib/python3/cv2.cpython-37m-x86_64-linux-gnu.so /code/opencv/build/lib/python3/cv2.so && \
ln -s /code/opencv/build/lib/python3/cv2.so /opt/conda/lib/python3.7/site-packages/cv2.so

# Finish OpenCV install

# Install tensorflow
RUN python3 -m pip install --upgrade tensorflow

# install python libs scikit
COPY ./requirements-post.txt /code/requirements-post.txt
RUN pip3 install -r /code/requirements-post.txt

# Switch back to jovyan to avoid accidental container runs as root
# USER $NB_UID
