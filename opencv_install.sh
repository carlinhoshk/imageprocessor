#!/bin/bash

# Verifique se os arquivos já foram baixados
if [ ! -f opencv.zip ]; then
    # Baixe as fontes do OpenCV se ainda não estiverem baixadas
    wget -O opencv.zip https://github.com/opencv/opencv/archive/3.2.0.zip
fi

# Verifique se a pasta "build" já existe e crie-a se não existir
if [ ! -d build ]; then
    mkdir -p build
fi

# Instale as dependências necessárias
sudo apt update
sudo apt install -y cmake build-essential g++ openjdk-17-jdk wget unzip ant python3 python3-numpy libtbb-dev libeigen3-dev libavcodec-dev libavformat-dev libswscale-dev libavutil-dev libswresample-dev liblzma-dev ffmpeg libpulse0

# Descompacte as fontes do OpenCV
unzip -q -u -o opencv.zip -d opencv

# Acesse o diretório de construção
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
-DBUILD_opencv_python3=OFF ../opencv-3.2.0

# Compile o OpenCV
make -j8

# Copie os arquivos necessários para a pasta "build" no diretório atual
cp ../opencv-3.2.0/bin/opencv-320.jar .
cp ../opencv-3.2.0/lib/libopencv_java320.so .

# Copie as bibliotecas compartilhadas necessárias pelo OpenCV para a pasta "lib" no diretório atual
# Nota: você pode ajustar essa lista de acordo com suas necessidades
mkdir -p lib
cp /usr/lib/x86_64-linux-gnu/libavcodec.so.58 lib/
cp /usr/lib/x86_64-linux-gnu/libavutil.so.56 lib/
cp /usr/lib/x86_64-linux-gnu/libswscale.so.5 lib/
cp /usr/lib/x86_64-linux-gnu/libavformat.so.58 lib/
cp /usr/lib/x86_64-linux-gnu/libswresample.so.3 lib/
cp /usr/lib/x86_64-linux-gnu/libavdevice.so.58 lib/
cp /usr/lib/x86_64-linux-gnu/libavfilter.so.7 lib/
cp /usr/lib/x86_64-linux-gnu/libpostproc.so.55 lib/

# Exemplo de saída dos arquivos copiados
echo "Arquivos copiados para $(pwd):"
ls -l
