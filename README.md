# Cloud Native Geospatial Demo

## File Formats
- Mapbox Vector Tiles
- Cloud Optimized GeoTiff
- Tiledb
- Zarr


### Mapbox Vector Tiles
- Pregenerate Vector Tiles
	- GDAL with MVT Plugin
	- Tippecanoe
- Generate Dynamic Vector Tiles
	- PostGIS + Dynamic Vector tile generation
		- pg_tileserv (https://github.com/CrunchyData/pg_tileserv)
		- Custom api implementation

mvtview (https://github.com/mapbox/mvtview) - Test generated Vector tile

Notes:
	- Use gzip compression to serve vector tiles
	- Choose right HTTP Caching strategy based on usecase
	- To cut down the tiling time choose appropriate number of tile levels (Pregenerate Vector Tiles)
	- To improve user experience Push lower tile levels first to object storage (Pregenerate Vector Tiles)

## Catalog
- OGC Spatio Temporal Asset Catalog
- OGC Catalogue Service

## Storage
- S3
- MinIo

## Local Development
docker-compose  up --build --remove-orphans


## init data
docker exec -it data_loader_tile /bin/bash
./data_loader.sh




## random notes
#./mc ls minio/test
#./mc policy set public minio/test
#http://127.0.0.1:9000/test/county/metadata.json
#http://127.0.0.1:9000/minio/test/county/


GDAL performace improvement
investigate GDAL_NUM_THREADS configuration option. https://gdal.org/drivers/vector/mvt.html
How to compute max-zoom level required for data?
