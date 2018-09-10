# GDAL python bindings make file.

SHELL = /bin/bash

wheels: Dockerfile build-linux-wheels.sh
	docker build -t geo-wheelbuilder .
	docker run -v `pwd`:/io geo-wheelbuilder
