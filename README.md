# GDAL and pyproj Python Bindings Via *manylinux* Wheels

Since the acceptance of [PEP 513](https://www.python.org/dev/peps/pep-0513/), Python now supports *manylinux* wheels 
for packing up Python code with the c extensions vendorized into the wheel itself. This repo provides a template for 
building GDAL's python bindings as manylinux wheels, allowing for a quick install of the GDAL Python bindings without 
expicitly installing GDAL and its dependencies. It also builds pyproj python bindings.

The template was directly derived from the [rasterio](https://github.com/mapbox/rasterio) project.  

## Building the Wheels

The building of the wheels is done via the docker container provided by the Python Packaging Authority as described 
[here](https://github.com/pypa/manylinux). To build, clone this repo, navigate to its root and run `make wheels`.  
The container may take a while to build on first go, but once complete you should have a subdirectory called `wheels` 
filled with wheels containing the bindings.  

The resulting wheels have the gdal and proj data directories packaged up inside of them, but you can set the 
appropriate environment viaraibles to use your own data directories. 

## Using the Wheels

These may be `pip` installed into your linux environment ad nauseam.  For example, from the directory containing the 
'wheels' directory, you can run

```bash
docker run -v `pwd`:/io -it --rm python:2.7 /bin/bash
```

to get yourself into a clean python docker container.  From inside this container, try

```bash
pip install /io/wheels/GDAL-2.3.1-cp27-cp27mu-manylinux1_x86_64.whl
```

to use in django add the following to your settings.py

```python
import glob, inspect, os, osgeo

GEOS_LIBRARY_PATH = glob.glob("{}".format(os.path.join(
    os.path.dirname(inspect.getfile(osgeo)), '.libs/libgeos_c*')))
```

Current Available Drivers:

```bash
root@9b6bf31bb981:/# python -c "import ogr; vector_driver_list = [ogr.GetDriver(i).GetDescription() for i in range(ogr.GetDriverCount())]; vector_driver_list.sort(); print(vector_driver_list)"
['ARCGEN', 'AVCBin', 'AVCE00', 'AeronavFAA', 'AmigoCloud', 'BNA', 'CAD', 'CSV', 'CSW', 'Carto', 'Cloudant', 'CouchDB', 'DGN', 'DXF', 'EDIGEO', 'ESRI Shapefile', 'ESRIJSON', 'ElasticSearch', 'GFT', 'GML', 'GPKG', 'GPSBabel', 'GPSTrackMaker', 'GPX', 'GeoJSON', 'GeoRSS', 'Geoconcept', 'HTF', 'HTTP', 'Idrisi', 'JML', 'JPEG2000', 'KML', 'LIBKML', 'MBTiles', 'MVT', 'MapInfo File', 'Memory', 'ODS', 'OGR_GMT', 'OGR_PDS', 'OGR_SDTS', 'OGR_VRT', 'OSM', 'OpenAir', 'OpenFileGDB', 'PCIDSK', 'PDF', 'PGDUMP', 'PLSCENES', 'PostgreSQL', 'REC', 'S57', 'SEGUKOOA', 'SEGY', 'SQLite', 'SUA', 'SVG', 'SXF', 'Selafin', 'TIGER', 'TopoJSON', 'UK .NTF', 'VDV', 'VFK', 'WAsP', 'WFS', 'WFS3', 'XLSX', 'XPlane', 'netCDF']

root@9b6bf31bb981:/# python -c "import gdal; raster_driver_list = [gdal.GetDriver(i).GetDescription() for i in range(gdal.GetDriverCount())]; raster_driver_list.sort(); print(raster_driver_list)"
['AAIGrid', 'ACE2', 'ADRG', 'AIG', 'ARCGEN', 'ARG', 'AVCBin', 'AVCE00', 'AeronavFAA', 'AirSAR', 'AmigoCloud', 'BIGGIF', 'BLX', 'BMP', 'BNA', 'BSB', 'BT', 'CAD', 'CALS', 'CEOS', 'COASP', 'COSAR', 'CPG', 'CSV', 'CSW', 'CTG', 'CTable2', 'Carto', 'Cloudant', 'CouchDB', 'DERIVED', 'DGN', 'DIMAP', 'DIPEx', 'DOQ1', 'DOQ2', 'DTED', 'DXF', 'E00GRID', 'ECRGTOC', 'EDIGEO', 'EHdr', 'EIR', 'ELAS', 'ENVI', 'ERS', 'ESAT', 'ESRI Shapefile', 'ESRIJSON', 'ElasticSearch', 'FAST', 'FIT', 'FujiBAS', 'GFF', 'GFT', 'GIF', 'GML', 'GMT', 'GNMDatabase', 'GNMFile', 'GPKG', 'GPSBabel', 'GPSTrackMaker', 'GPX', 'GRASSASCIIGrid', 'GRIB', 'GS7BG', 'GSAG', 'GSBG', 'GSC', 'GTX', 'GTiff', 'GXF', 'GenBin', 'GeoJSON', 'GeoRSS', 'Geoconcept', 'HF2', 'HFA', 'HTF', 'HTTP', 'IDA', 'ILWIS', 'INGR', 'IRIS', 'ISCE', 'ISIS2', 'ISIS3', 'Idrisi', 'JAXAPALSAR', 'JDEM', 'JML', 'JPEG', 'JPEG2000', 'KML', 'KMLSUPEROVERLAY', 'KRO', 'L1B', 'LAN', 'LCP', 'LIBKML', 'LOSLAS', 'Leveller', 'MAP', 'MBTiles', 'MEM', 'MFF', 'MFF2', 'MRF', 'MSGN', 'MVT', 'MapInfo File', 'Memory', 'NDF', 'NGSGEOID', 'NITF', 'NTv2', 'NWT_GRC', 'NWT_GRD', 'ODS', 'OGR_GMT', 'OGR_PDS', 'OGR_SDTS', 'OGR_VRT', 'OSM', 'OZI', 'OpenAir', 'OpenFileGDB', 'PAux', 'PCIDSK', 'PCRaster', 'PDF', 'PDS', 'PDS4', 'PGDUMP', 'PLMOSAIC', 'PLSCENES', 'PNG', 'PNM', 'PRF', 'PostGISRaster', 'PostgreSQL', 'R', 'RDA', 'REC', 'RIK', 'RMF', 'ROI_PAC', 'RPFTOC', 'RRASTER', 'RS2', 'RST', 'Rasterlite', 'S57', 'SAFE', 'SAGA', 'SAR_CEOS', 'SDTS', 'SEGUKOOA', 'SEGY', 'SENTINEL2', 'SGI', 'SNODAS', 'SQLite', 'SRP', 'SRTMHGT', 'SUA', 'SVG', 'SXF', 'Selafin', 'TIGER', 'TIL', 'TSX', 'Terragen', 'TopoJSON', 'UK .NTF', 'USGSDEM', 'VDV', 'VFK', 'VICAR', 'VRT', 'WAsP', 'WCS', 'WEBP', 'WFS', 'WFS3', 'WMS', 'WMTS', 'XLSX', 'XPM', 'XPlane', 'XYZ', 'ZMap', 'netCDF']

```

