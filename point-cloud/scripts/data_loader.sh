#!/bin/bash

set -e


url="http://nginx:9000"
access_key="admin"
secret_key="password"

./mc config host add minio $url $access_key $secret_key
./mc ls minio

./mc mb minio/test

./mc policy set download minio/test


# 3D Tiles, I3S and potree
# https://loaders.gl/modules/3d-tiles/docs/api-reference/tiles-3d-loader


rm tiles/ -r

name='red-rocks'

entwine build -i https://data.entwine.io/red-rocks.laz -o ./tiles/$name -r EPSG:4978
	

# upload tiles
./mc rm minio/test/$name -r --force
./mc mirror ./tiles/$name minio/test/$name/


#3D Tiles
ept tile -i ./tiles/$name/ept.json -o ./tiles/$name_3d_tiles/



