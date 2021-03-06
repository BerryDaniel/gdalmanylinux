#!/bin/bash
set -e

GDAL_BUILD_PATH=/usr/local/src/gdal-2.3.1/swig/python
ORIGINAL_PATH=$PATH
UNREPAIRED_WHEELS=/tmp/wheels

# Enable devtoolset-2 for C++11
source /opt/rh/devtoolset-2/enable

# Compile wheels
pushd ${GDAL_BUILD_PATH}
for PYBIN in /opt/python/*/bin; do
    if [[ $PYBIN == *"26"* ]]; then continue; fi
    if [[ $PYBIN == *"27m/"* ]]; then continue; fi
    if [[ $PYBIN == *"33"* ]]; then continue; fi
    if [[ $PYBIN == *"34"* ]]; then continue; fi
    if [[ $PYBIN == *"35"* ]]; then continue; fi
    if [[ $PYBIN == *"37"* ]]; then continue; fi
    export PATH=${PYBIN}:$ORIGINAL_PATH
    rm -rf build
    CFLAGS="-std=c++11" python setup.py bdist_wheel -d ${UNREPAIRED_WHEELS}
done
popd

pushd /tmp
filename='/io/package_endpoints.txt'
filelines=`cat $filename`
for line in $filelines ; do
    curl -f -L -O $line
    fn="${line##*/}"
    tar xzf ${fn}
    pushd "${fn//.tar.gz}"
    for PYBIN in /opt/python/*/bin; do
        if [[ $PYBIN == *"26"* ]]; then continue; fi
        if [[ $PYBIN == *"27m/"* ]]; then continue; fi
        if [[ $PYBIN == *"33"* ]]; then continue; fi
        if [[ $PYBIN == *"34"* ]]; then continue; fi
        if [[ $PYBIN == *"35"* ]]; then continue; fi
        if [[ $PYBIN == *"37"* ]]; then continue; fi
        export PATH=${PYBIN}:$ORIGINAL_PATH
        rm -rf build
        CFLAGS="-std=c++11" python setup.py bdist_wheel -d ${UNREPAIRED_WHEELS}
    done
    popd
done
popd

# Bundle dependency libs into the wheels
for whl in ${UNREPAIRED_WHEELS}/*.whl; do
    auditwheel repair ${whl} -w wheels
done
