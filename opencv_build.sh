#!/bin/bash

# Instale as dependências necessárias
sudo apt update
sudo apt install -y cmake build-essential g++ openjdk-17-jdk wget unzip ant python3 python3-numpy libtbb-dev libeigen3-dev libavcodec-dev libavformat-dev libswscale-dev libavutil-dev libswresample-dev liblzma-dev ffmpeg libpulse0

# Baixe e descompacte as fontes do OpenCV
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.6.0.zip
unzip opencv.zip

# Crie o diretório de construção
mkdir -p build
cd build

# Configure o OpenCV. Desative recursos que não são necessários para reduzir o tamanho
cmake -DWITH_GSTREAMER=OFF \
-DBUILD_opencv_highgui=OFF \
-DBUILD_opencv_dnn=OFF \
-DBUILD_opencv_ml=OFF \
-DBUILD_opencv_apps=OFF \
-DBUILD_opencv_js=OFF \
-DBUILD_opencv_ts=OFF \
-DBUILD_opencv_viz=OFF \
-DBUILD_opencv_legacy=OFF \
-DBUILD_opencv_androidcamera=OFF \
-DBUILD_SHARED_LIBS=OFF \
-DBUILD_PERF_TESTS=OFF \
-DBUILD_TESTS=OFF \
-DBUILD_opencv_python2=OFF  \
-DOPENCV_FFMPEG_SKIP_BUILD_CHECK=ON \
-DWITH_V4L=OFF \
-DWITH_FFMPEG=ON \
-DBUILD_opencv_python3=OFF ../opencv-4.6.0

# Compile o OpenCV
make -j8

# Copie os arquivos necessários para o contêiner OpenCV
# Nota: você pode adaptar isso para o seu caso específico, dependendo de como deseja usar os arquivos resultantes
mkdir /opencvlibs
cp /usr/bin/ffmpeg /usr/bin/ffmpeg
cp /lib/libopencv_java460.so /opencvlibs/
cp /bin/opencv-460.jar /opencvlibs/

# Copie as bibliotecas compartilhadas necessárias pelo OpenCV
# Nota: você pode ajustar essa lista de acordo com suas necessidades
cp /lib/liblzma* /lib/x86_64-linux-gnu/
cp /lib/libbz2* /lib/x86_64-linux-gnu/
cp /lib/libgpg-error* /lib/x86_64-linux-gnu/
cp /lib/libselinux* /lib/x86_64-linux-gnu/
cp /lib/libcom_err* /lib/x86_64-linux-gnu/
cp /lib/libkeyutils* /lib/x86_64-linux-gnu/
cp /lib/libncursesw.so.6 /lib/x86_64-linux-gnu/
cp /lib/libtinfo.so.6 /lib/x86_64-linux-gnu/
cp /lib/libdbus-1.so.3 /lib/x86_64-linux-gnu/
cp /lib/libtirpc.so.3 /lib/x86_64-linux-gnu/
cp /usr/lib/x86_64-linux-gnu/libavcodec.so.58 /lib/x86_64-linux-gnu/
cp /usr/lib/x86_64-linux-gnu/libavutil.so.56 /lib/x86_64-linux-gnu/
cp /usr/lib/x86_64-linux-gnu/libswscale.so.5 /lib/x86_64-linux-gnu/
cp /usr/lib/x86_64-linux-gnu/libavformat.so.58 /lib/x86_64-linux-gnu/
cp /usr/lib/x86_64-linux-gnu/libswresample.so.3 /lib/x86_64-linux-gnu/
cp /usr/lib/x86_64-linux-gnu/libavdevice.so.58 /lib/x86_64-linux-gnu/
cp /usr/lib/x86_64-linux-gnu/libavfilter.so.7 /lib/x86_64-linux-gnu/
cp /usr/lib/x86_64-linux-gnu/libavresample.so.4 /lib/x86_64-linux-gnu/
cp /usr/lib/x86_64-linux-gnu/libpostproc.so.55 /lib/x86_64-linux-gnu/

# Exemplo de saída dos arquivos copiados
echo "Arquivos copiados para /opencvlibs:"
ls /opencvlibs

