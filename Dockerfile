# An image for building manylinux1 wheels

FROM quay.io/pypa/manylinux1_x86_64

RUN sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf \
    && sed -i 's/mirrorlist/#mirrorlist/' /etc/yum.repos.d/CentOS-Base.repo \
    && sed -i 's|#baseurl=http://mirror.centos.org/centos/$releasever|baseurl=http://vault.centos.org/5.11|' /etc/yum.repos.d/CentOS-Base.repo

RUN yum update -y && yum install -y curl-devel json-c-devel zlib-devel libtiff-devel

# cmake
RUN cd /usr/local/src \
    && curl -f -L -O http://www.cmake.org/files/v3.11/cmake-3.11.1.tar.gz \
    && tar xzf cmake-3.11.1.tar.gz \
    && cd cmake-3.11.1 \
    && ./bootstrap --prefix=/usr/local/cmake \
    && make -j 4 \
    && make install

# Install openssl
RUN cd /usr/local/src \
    && curl -f -L -O https://s3.amazonaws.com/boundless-cloudfoundry/src/openssl-1.0.2p.tar.gz \
    && echo "50a98e07b1a89eb8f6a99477f262df71c6fa7bef77df4dc83025a2845c827d00  openssl-1.0.2p.tar.gz" > checksum \
    && sha256sum -c checksum \
    && tar zxf openssl-1.0.2p.tar.gz \
    && cd openssl-1.0.2p \
    && ./config no-shared no-ssl2 no-async -fPIC -O2 \
    && make -j 4 \
    && make install

# Install curl
RUN mkdir -p /usr/local/src \
    && cd /usr/local/src \
    && curl -f -L -O http://curl.askapache.com/download/curl-7.59.0.tar.bz2 \
    && tar jxf curl-7.59.0.tar.bz2 \
    && cd curl-7.59.0 \
    && LIBS=-ldl CFLAGS="-O2 -Wl,-S" ./configure --with-ssl=/usr/local/ssl \
    && make -j 4 \
    && make install

# Install geos
RUN cd /usr/local/src \
    && curl -f -L -O http://download.osgeo.org/geos/geos-3.6.0.tar.bz2 \
    && tar jxf geos-3.6.0.tar.bz2 \
    && cd geos-3.6.0 \
    && CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure \
    && make -j 4 \
    && make install

# Install jasper
RUN cd /usr/local/src \
    && curl -f -L -O http://download.osgeo.org/gdal/jasper-1.900.1.uuid.tar.gz \
    && tar xzf jasper-1.900.1.uuid.tar.gz \
    && cd jasper-1.900.1.uuid \
    && ./configure --disable-debug --enable-shared \
    && make -j 4 \
    && make install

# proj4
RUN cd /usr/local/src \
    && curl -f -L -O http://download.osgeo.org/proj/proj-4.9.3.tar.gz \
    && tar xzf proj-4.9.3.tar.gz \
    && cd proj-4.9.3 \
    && ./configure CFLAGS="-O2 -Wl,-S" \
    && make -j 4 \
    && make install

# postgresql client
RUN cd /usr/local/src \
    && curl -f -L -O https://s3.amazonaws.com/boundless-cloudfoundry/src/postgresql-9.6.1.tar.gz \
    && tar xzf postgresql-9.6.1.tar.gz \
    && cd postgresql-9.6.1 \
    && sed --in-place '/fmgroids/d' src/include/Makefile \
    && ./configure CFLAGS="-O2 -Wl,-S" --prefix=/usr/local --without-readline \
    && make -j 4 \
    && make install

# Install libkml
RUN cd /usr/local/src \
    && curl -f -L -O https://s3.amazonaws.com/boundless-cloudfoundry/src/libkml-1.3.0.tar.gz \
    && tar xzf libkml-1.3.0.tar.gz \
    && cd libkml-1.3.0 \
    && sed -i "s|typedef voidpf|/**typedef voidpf|" src/kml/base/contrib/minizip/iomem_simple.h \
    && sed -i "/KMR/d" src/kml/base/contrib/minizip/iomem_simple.h \
    && sed -i "s|zlib.net|zlib.net/fossils|" cmake/External_zlib.cmake \
    && mkdir -p build \
    && cd build \
    && /usr/local/cmake/bin/cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local \
    && make -j 4 install \
    && make clean

# hdf
RUN cd /usr/local/src \
    && curl -f -L -O https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.2/src/hdf5-1.10.2.tar.gz \
    && tar xzf hdf5-1.10.2.tar.gz \
    && cd hdf5-1.10.2 \
    && ./configure --prefix=/usr/local --enable-shared --enable-build-mode=production CFLAGS="-O2 -Wl,-S" \
    && make -j 4 \
    && make install

## netcdf
RUN cd /usr/local/src \
    && curl -f -L -O ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.6.1.tar.gz \
    && tar xzf netcdf-4.6.1.tar.gz \
    && cd netcdf-4.6.1 \
    && CFLAGS="-I/usr/local/include -O2 -Wl,-S" CXXFLAGS="-I/usr/local/include -O2 -Wl,-S" LDFLAGS="-L/usr/local/lib" ./configure \
    && make -j 4 \
    && make install

## expat
RUN cd /usr/local/src \
    && curl -f -L -O https://github.com/libexpat/libexpat/releases/download/R_2_2_5/expat-2.2.5.tar.bz2 \
    && tar xjf expat-2.2.5.tar.bz2 \
    && cd expat-2.2.5 \
    && CFLAGS="-O2 -Wl,-S" ./configure --prefix=/usr/local \
    && make -j 4 \
    && make install

## webp
RUN cd /usr/local/src \
    && curl -f -L -O https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-0.6.1.tar.gz \
    && tar xzf libwebp-0.6.1.tar.gz \
    && cd libwebp-0.6.1 \
    && CFLAGS="-O2 -Wl,-S" ./configure --prefix=/usr/local \
    && make -j 4 \
    && make install

# gdal
RUN cd /usr/local/src \
    && curl -f -L -O http://download.osgeo.org/gdal/2.3.1/gdal-2.3.1.tar.gz \
    && tar xzf gdal-2.3.1.tar.gz \
    && cd gdal-2.3.1 \
    && CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure \
        --with-threads \
        --disable-debug \
        --disable-static \
        --without-grass \
        --without-libgrass \
        --without-jpeg12 \
        --with-libtiff \
        --with-jpeg \
        --with-gif \
        --with-png \
        --with-webp \
        --with-geotiff=internal \
        --with-sqlite3=/usr \
        --with-pcraster=internal \
        --with-pcidsk=internal \
        --with-bsb \
        --with-grib \
        --with-pam \
        --with-geos=/usr/local/bin/geos-config \
        --with-static-proj4=/usr/local \
        --with-expat=/usr/local \
        --with-libjson-c \
        --with-libiconv-prefix=/usr \
        --with-libkml=/usr/local \
        --with-libkml-inc=/usr/local/include/kml \
        --with-libz=/usr \
        --with-curl=/usr/local/bin/curl-config \
        --with-netcdf=/usr/local/netcdf \
        --with-pg=/usr/local/bin/pg_config \
        --with-jasper=/usr/local \
        --without-python \
        --without-hdf4 \
        --without-hdf5 \
    && make -j 4 \
    && make install

# Bake dev requirements into the Docker image for faster builds
ADD requirements.txt /tmp/requirements.txt
RUN for PYBIN in /opt/python/*/bin; do \
        if [[ $PYBIN == *"26"* ]]; then continue; fi; \
        if [[ $PYBIN == *"33"* ]]; then continue; fi; \
        $PYBIN/pip install -U pip ; \
        $PYBIN/pip install -r /tmp/requirements.txt ; \
    done

# Replace SWIG's setup.py with this modified one.
ADD setup.py /usr/local/src/gdal-2.3.1/swig/python/setup.py

# Replace the osgeo module __init__.py with this modified one, which
# sets the GDAL_DATA and PROJ_LIB variables on import to where they've
# been copied to.
ADD gdalinit.py /usr/local/src/gdal-2.3.1/swig/python/osgeo/__init__.py

WORKDIR /io
CMD ["/io/build-linux-wheels.sh"]
