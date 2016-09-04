# Base image heroku cedar stack v14
#FROM heroku/cedar:14
# Inherit from Heroku's python stack
FROM heroku/python

# Remove all system python interpreters
RUN apt-get remove -y python2.7
RUN apt-get remove -y python3.4
RUN apt-get remove -y python2.7-minimal
RUN apt-get remove -y python3.4-minimal
RUN apt-get remove -y libpython2.7-minimal
RUN apt-get remove -y libpython3.4-minimal
# remove ffmpeg
RUN apt-get remove ffmpeg x264 libx264-dev


# Make folder structure
RUN mkdir /app
RUN mkdir /app/.heroku
RUN mkdir /app/.heroku/vendor
RUN mkdir /app/.heroku/ffmpeg
WORKDIR /app/.heroku


# Install python 2.7.12
ENV PATH /app/.heroku/vendor/bin:$PATH
ENV LD_LIBRARY_PATH /app/.heroku/vendor/lib/
ENV PYTHONPATH /app/.heroku/vendor/lib/python2.7/site-packages
RUN curl -s -L https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz > Python-2.7.12.tgz
RUN tar zxvf Python-2.7.12.tgz
RUN rm Python-2.7.12.tgz
WORKDIR /app/.heroku/Python-2.7.12
RUN ./configure --prefix=/app/.heroku/vendor/ --enable-shared --enable-static
RUN make install
WORKDIR /app/.heroku
RUN rm -rf Python-2.7.12


# Install latest setup-tools and pip
RUN curl -s -L https://bootstrap.pypa.io/get-pip.py > get-pip.py
RUN python get-pip.py
RUN rm get-pip.py


# Install numpy
RUN pip install -v numpy


# Install ATLAS library and fortran compiler
RUN curl -s -L https://db.tt/osV4nSh0 > npscipy.tar.gz
RUN tar zxvf npscipy.tar.gz
RUN rm npscipy.tar.gz
ENV ATLAS /app/.heroku/vendor/lib/atlas-base/libatlas.a
ENV BLAS /app/.heroku/vendor/lib/atlas-base/atlas/libblas.a
ENV LAPACK /app/.heroku/vendor/lib/atlas-base/atlas/liblapack.a
ENV LD_LIBRARY_PATH /app/.heroku/vendor/lib/atlas-base:/app/.heroku/vendor/lib/atlas-base/atlas:$LD_LIBRARY_PATH
RUN apt-get update
RUN apt-get install -y gfortran


# Install scipy
RUN pip install -v scipy


# Install matplotlib
# RUN apt-get install -y libfreetype6-dev
# RUN apt-get install -y libpng-dev
RUN pip install -v matplotlib

# Install opencv dependencies from http://www.samontab.com/web/2011/06/installing-opencv-2-2-in-ubuntu-11-04/
RUN apt-get install build-essential libgtk2.0-dev libjpeg62-dev libtiff4-dev libjasper-dev libopenexr-dev cmake python-dev python-numpy libtbb-dev libeigen2-dev yasm libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev

# Compile ffmpeg
WORKDIR /app/.heroku/ffmpeg
RUN wget http://ffmpeg.org/releases/ffmpeg-0.7-rc1.tar.gz
RUN tar -xvzf ffmpeg-0.7-rc1.tar.gz
WORKDIR ffmpeg-0.7-rc1
RUN ./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-libfaac --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libxvid --enable-x11grab --enable-swscale --enable-shared
RUN make
RUN make install


# Install opencv with python bindings
RUN apt-get update
RUN apt-get install -y cmake
RUN curl -s -L https://github.com/Itseez/opencv/archive/2.4.11.zip > opencv-2.4.11.zip
RUN unzip opencv-2.4.11.zip
RUN rm opencv-2.4.11.zip
WORKDIR /app/.heroku/opencv-2.4.11
RUN cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/app/.heroku/vendor -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D BUILD_DOCS=OFF -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF -D BUILD_opencv_python=ON .
#cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D  -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D BUILD_EXAMPLES=ON -D WITH_QT=ON -D WITH_OPENGL=ON ..
#PYTHON_EXECUTABLE=/usr/local/bin/python -D PYTHONG_INCLUDE_DIR=/usr/local/include/python2.7 -D PYTHON_LIBRARY=/usr/local/lib/libpython2.7.so -D PYTHON_PACKAGES_PATH=/usr/local/lib/python2.7/site-packages -D PYTHON_NUMPY_INCLUDE_DIR=/usr/local/lib/python2.7/site-packages/numpy/core/include
RUN make install
WORKDIR /app/.heroku
RUN rm -rf opencv-2.4.11
