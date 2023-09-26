FROM debian:11 AS opencv-libs

# Install minimal prerequisites (Debian 11)
# Build tools for OpenCV
# libavcodec, libavformat, libswscale, libavutil, libswresample are needed by ffmpeg. See https://ffmpeg.org/about.html
RUN apt update && \
    apt install -y cmake build-essential g++ openjdk-17-jdk wget unzip ant python3 python3-numpy \
    libtbb-dev libeigen3-dev \
    libavcodec-dev libavformat-dev libswscale-dev libavutil-dev libswresample-dev liblzma-dev \
    ffmpeg libpulse0

# Download and unpack OpenCV sources
# Note that the Java jar version must match the version we build here - 3.2 at the moment

# Create the build directory if it doesn't exist and set it as the working directory



RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/3.2.0.zip && unzip opencv.zip

WORKDIR /opencv
# Configure OpenCV. Turn off features we do not need to restrict size
# See: https://docs.opencv.org/4.x/db/d05/tutorial_config_reference.html
#
# CMAKE OUTPUT, MUST LOOK LIKE SHOWN BELOW:
# (O restante do seu comando cmake permanece o mesmo)
RUN cmake -DWITH_GSTREAMER=OFF \
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
    -DBUILD_opencv_python3=OFF /opencv-3.2.0

# Build OpenCV Java shared lib
RUN make -j8

FROM gitpod/workspace-full

USER gitpod

RUN bash -c ". /home/gitpod/.sdkman/bin/sdkman-init.sh && \
    sdk install java 17.0.3-ms && \
    sdk default java 17.0.3-ms"

COPY --from=opencv-libs /usr/bin/ffmpeg /usr/bin/ffmpeg

# Big(ish) static lib from the OpenCV build. Contains all OpenCV deps.
# OpenCV JNI layer needs this to work
COPY --from=opencv-libs /lib/libopencv_java320.so /opencvlibs/
COPY --from=opencv-libs /bin/opencv-320.jar /opencvlibs/

# These are all the shared libs needed by OpenCV - not available in the Distroless container
# Copy all the /lib dir. Linux will pick up shared libs from /lib by default convention
COPY --from=opencv-libs /lib/liblzma* \
/lib/x86_64-linux-gnu/liblzma* \
/lib/x86_64-linux-gnu/libbz2* \
/lib/x86_64-linux-gnu/libgpg-error* \
/lib/x86_64-linux-gnu/libselinux* \
/lib/x86_64-linux-gnu/libcom_err* \
/lib/x86_64-linux-gnu/libkeyutils* \
/lib/x86_64-linux-gnu/libncursesw.so.6 \
/lib/x86_64-linux-gnu/libtinfo.so.6 \
/lib/x86_64-linux-gnu/libdbus-1.so.3 \
/lib/x86_64-linux-gnu/libtirpc.so.3 \
/usr/lib/x86_64-linux-gnu/libavcodec.so.58 \
/usr/lib/x86_64-linux-gnu/libavutil.so.56 \
/usr/lib/x86_64-linux-gnu/libswscale.so.5 \
/usr/lib/x86_64-linux-gnu/libavformat.so.58 \
/usr/lib/x86_64-linux-gnu/libswresample.so.3 \
/usr/lib/x86_64-linux-gnu/libavdevice.so.58 \
/usr/lib/x86_64-linux-gnu/libavfilter.so.7 \
/usr/lib/x86_64-linux-gnu/libavresample.so.4 \
/usr/lib/x86_64-linux-gnu/libpostproc.so.55 \
/usr/lib/x86_64-linux-gnu/libraw1394.so.11 \
/usr/lib/x86_64-linux-gnu/libavc1394.so.0 \
/usr/lib/x86_64-linux-gnu/librom1394.so.0 \
/usr/lib/x86_64-linux-gnu/libiec61883.so.0 \
/usr/lib/x86_64-linux-gnu/libjack.so.0 \
/usr/lib/x86_64-linux-gnu/libopenal.so.1 \
/usr/lib/x86_64-linux-gnu/libcdio_paranoia.so.2 \
/usr/lib/x86_64-linux-gnu/libcdio_cdda.so.2 \
/usr/lib/x86_64-linux-gnu/libdc1394.so.25 \
/usr/lib/x86_64-linux-gnu/libcaca.so.0 \
/usr/lib/x86_64-linux-gnu/libpulse.so.0 \
/usr/lib/x86_64-linux-gnu/pulseaudio/libpulsecommon-14.2.so \
/usr/lib/x86_64-linux-gnu/libwrap.so.0 \
/usr/lib/x86_64-linux-gnu/libsndfile.so.1 \
/usr/lib/x86_64-linux-gnu/libasyncns.so.0 \
/usr/lib/x86_64-linux-gnu/libwayland-server.so.0 \
/usr/lib/x86_64-linux-gnu/libgfortran.so.5 \
/usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0 \
/usr/lib/x86_64-linux-gnu/libpocketsphinx.so.3 \
/usr/lib/x86_64-linux-gnu/libsphinxbase.so.3 \
/usr/lib/x86_64-linux-gnu/libbs2b.so.0 \
/usr/lib/x86_64-linux-gnu/liblilv-0.so.0 \
/usr/lib/x86_64-linux-gnu/libquadmath.so.0 \
/usr/lib/x86_64-linux-gnu/librubberband.so.2 \
/usr/lib/x86_64-linux-gnu/libmysofa.so.1 \
/usr/lib/x86_64-linux-gnu/libFLAC.so.8 \
/usr/lib/x86_64-linux-gnu/libflite_cmu_us_awb.so.1 \
/usr/lib/x86_64-linux-gnu/libflite_cmu_us_kal.so.1 \
/usr/lib/x86_64-linux-gnu/libflite_cmu_us_kal16.so.1 \
/usr/lib/x86_64-linux-gnu/libflite_cmu_us_rms.so.1 \
/usr/lib/x86_64-linux-gnu/libflite_cmu_us_slt.so.1 \
/usr/lib/x86_64-linux-gnu/libflite.so.1 \
/usr/lib/x86_64-linux-gnu/libass.so.9 \
/usr/lib/x86_64-linux-gnu/libusb-1.0.so.0 \
/usr/lib/x86_64-linux-gnu/libslang.so.2 \
/usr/lib/x86_64-linux-gnu/libXss.so.1 \
/usr/lib/x86_64-linux-gnu/libgbm.so.1 \
/usr/lib/x86_64-linux-gnu/libwayland-egl.so.1 \
/usr/lib/x86_64-linux-gnu/libwayland-cursor.so.0 \
/usr/lib/x86_64-linux-gnu/libxkbcommon.so.0 \
/usr/lib/x86_64-linux-gnu/libblas.so.3 \
/usr/lib/x86_64-linux-gnu/liblapack.so.3 \
/usr/lib/x86_64-linux-gnu/libserd-0.so.0 \
/usr/lib/x86_64-linux-gnu/libsord-0.so.0 \
/usr/lib/x86_64-linux-gnu/libsratom-0.so.0 \
/usr/lib/x86_64-linux-gnu/libsamplerate.so.0 \
/usr/lib/x86_64-linux-gnu/libfftw3.so.3 \
/usr/lib/x86_64-linux-gnu/libflite_usenglish.so.1 \
/usr/lib/x86_64-linux-gnu/libflite_cmulex.so.1 \
/usr/lib/x86_64-linux-gnu/libflite_usenglish.so.1 \
/usr/lib/x86_64-linux-gnu/libvidstab.so.1.1 \
/usr/lib/x86_64-linux-gnu/libsndio.so.7.0 \
/usr/lib/x86_64-linux-gnu/libcdio.so.19 \
/usr/lib/x86_64-linux-gnu/libcdio.so.19 \
/usr/lib/x86_64-linux-gnu/libdc1394.so.25 \
/usr/lib/x86_64-linux-gnu/libaom* \
/usr/lib/x86_64-linux-gnu/libbluray* \
/usr/lib/x86_64-linux-gnu/libcairo.so.2 \
/usr/lib/x86_64-linux-gnu/libcairo-gobject.so.2 \
/usr/lib/x86_64-linux-gnu/libchromaprint* \
/usr/lib/x86_64-linux-gnu/libcodec2* \
/usr/lib/x86_64-linux-gnu/libdav1d.so.4 \
/usr/lib/x86_64-linux-gnu/libdrm* \
/usr/lib/x86_64-linux-gnu/libglib-2* \
/usr/lib/x86_64-linux-gnu/libgme* \
/usr/lib/x86_64-linux-gnu/libgobject-2* \
/usr/lib/x86_64-linux-gnu/libgsm* \
/usr/lib/x86_64-linux-gnu/libmfx* \
/usr/lib/x86_64-linux-gnu/libmp3lame.so.0 \
/usr/lib/x86_64-linux-gnu/libOpenCL* \
/usr/lib/x86_64-linux-gnu/libopenjp2* \
/usr/lib/x86_64-linux-gnu/libopenmpt.so.0 \
/usr/lib/x86_64-linux-gnu/libopus* \
/usr/lib/x86_64-linux-gnu/librabbitmq* \
/usr/lib/x86_64-linux-gnu/librsvg-2.so.2 \
/usr/lib/x86_64-linux-gnu/libshine* \
/usr/lib/x86_64-linux-gnu/libsnappy* \
/usr/lib/x86_64-linux-gnu/libsoxr* \
/usr/lib/x86_64-linux-gnu/libspeex* \
/usr/lib/x86_64-linux-gnu/libsrt-gnutls.so.1.4 \
/usr/lib/x86_64-linux-gnu/libssh-gcrypt.so.4 \
/usr/lib/x86_64-linux-gnu/libtheoradec* \
/usr/lib/x86_64-linux-gnu/libtheoraenc.so.1 \
/usr/lib/x86_64-linux-gnu/libtwolame* \
/usr/lib/x86_64-linux-gnu/libva-drm* \
/usr/lib/x86_64-linux-gnu/libva* \
/usr/lib/x86_64-linux-gnu/libvdpau* \
/usr/lib/x86_64-linux-gnu/libvorbis* \
/usr/lib/x86_64-linux-gnu/libvorbisenc.so.2 \
/usr/lib/x86_64-linux-gnu/libvpx.so.6 \
/usr/lib/x86_64-linux-gnu/libwavpack* \
/usr/lib/x86_64-linux-gnu/libwebp.so.6 \
/usr/lib/x86_64-linux-gnu/libwebpmux* \
/usr/lib/x86_64-linux-gnu/libX11.so.6 \
/usr/lib/x86_64-linux-gnu/ibx26460* \
/usr/lib/x86_64-linux-gnu/libx26592* \
/usr/lib/x86_64-linux-gnu/libxml2.so.2 \
/usr/lib/x86_64-linux-gnu/libxvidcore.so.4 \
/usr/lib/x86_64-linux-gnu/libzmq.so.5 \
/usr/lib/x86_64-linux-gnu/libzvbi.so.0 \
/usr/lib/x86_64-linux-gnu/libpangocairo-1.0* \
/usr/lib/x86_64-linux-gnu/libxcb-shm* \
/usr/lib/x86_64-linux-gnu/libxcb* \
/usr/lib/x86_64-linux-gnu/libXrender* \
/usr/lib/x86_64-linux-gnu/libffi* \
/usr/lib/x86_64-linux-gnu/libpango-1.0* \
/usr/lib/x86_64-linux-gnu/libpixman-1.so.0 \
/usr/lib/x86_64-linux-gnu/libgdk_pixbuf* \
/usr/lib/x86_64-linux-gnu/libgnutls.so.30 \
/usr/lib/x86_64-linux-gnu/libx264* \
/usr/lib/x86_64-linux-gnu/libx265* \
/usr/lib/x86_64-linux-gnu/libogg* \
/usr/lib/x86_64-linux-gnu/libnuma* \
/usr/lib/x86_64-linux-gnu/libmpg123* \
/usr/lib/x86_64-linux-gnu/libudfread* \
/usr/lib/x86_64-linux-gnu/libsodium.so.23 \
/usr/lib/x86_64-linux-gnu/libpgm-5.3* \
/usr/lib/x86_64-linux-gnu/libnorm.so.1 \
/usr/lib/x86_64-linux-gnu/libgomp.so.1 \
/usr/lib/x86_64-linux-gnu/libXext* \
/usr/lib/x86_64-linux-gnu/libicuuc.so.67 \
/usr/lib/x86_64-linux-gnu/libp11-kit.so.0 \
/usr/lib/x86_64-linux-gnu/libidn2* \
/usr/lib/x86_64-linux-gnu/libunistring.so.2 \
/usr/lib/x86_64-linux-gnu/libtasn1* \
/usr/lib/x86_64-linux-gnu/libnettle.so.8 \
/usr/lib/x86_64-linux-gnu/libhogweed.so.6 \
/usr/lib/x86_64-linux-gnu/libgmp.so.10 \
/usr/lib/x86_64-linux-gnu/libgcrypt.so.20 \
/usr/lib/x86_64-linux-gnu/libgssapi_krb5* \
/usr/lib/x86_64-linux-gnu/libbsd* \
/usr/lib/x86_64-linux-gnu/libXfixes* \
/usr/lib/x86_64-linux-gnu/libmount.so.1 \
/usr/lib/x86_64-linux-gnu/libpangoft2-1.0* \
/usr/lib/x86_64-linux-gnu/libfribidi* \
/usr/lib/x86_64-linux-gnu/libthai* \
/usr/lib/x86_64-linux-gnu/libXau* \
/usr/lib/x86_64-linux-gnu/libXdmcp* \
/usr/lib/x86_64-linux-gnu/libicudata.so.67 \
/usr/lib/x86_64-linux-gnu/libkrb5.so.3 \
/usr/lib/x86_64-linux-gnu/libkrb5support.so.0 \
/usr/lib/x86_64-linux-gnu/libk5crypto* \
/usr/lib/x86_64-linux-gnu/libmd* \
/usr/lib/x86_64-linux-gnu/libblkid* \
/usr/lib/x86_64-linux-gnu/libpcre2-8.so.0 \
/usr/lib/x86_64-linux-gnu/libdatrie* \
/usr/lib/x86_64-linux-gnu/libasound.so.2 \
/usr/lib/x86_64-linux-gnu/libGL.so.1 \
/usr/lib/x86_64-linux-gnu/libXv.so.1 \
/usr/lib/x86_64-linux-gnu/libGLdispatch.so.0 \
/usr/lib/x86_64-linux-gnu/libGLX.so.0 \
/usr/lib/x86_64-linux-gnu/libXcursor.so.1 \
/usr/lib/x86_64-linux-gnu/libXinerama.so.1 \
/usr/lib/x86_64-linux-gnu/libXi.so.6 \
/usr/lib/x86_64-linux-gnu/libXrandr.so.2 \
/usr/lib/x86_64-linux-gnu/libXxf86vm.so.1 \
/usr/lib/x86_64-linux-gnu/libwayland-client.so.0 \
/usr/lib/x86_64-linux-gnu/libudev.so.1 \
/usr/lib/x86_64-linux-gnu/libsystemd.so.0 \
/usr/lib/x86_64-linux-gnu/libzstd.so.1 \
/usr/lib/x86_64-linux-gnu/liblz4.so.1 \
/usr/lib/x86_64-linux-gnu/libnsl.so.2 \
/opencvlibs/

ENTRYPOINT ["ls", "opencvlibs"]
