#!/bin/bash

set -e


url="http://nginx:9000"
access_key="admin"
secret_key="password"

./mc config host add minio $url $access_key $secret_key
./mc ls minio

./mc mb test

./mc policy set download minio/test

wget -O county.zip https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_county_500k.zip

unzip county.zip -d county

rm county_tiles/ -r
# generate vector tiles

name='county'
input_file='./county/cb_2018_us_county_500k.shp'
geojson_file="./county/$name.json"
minzoom=0
maxzoom=10
# method 1
ogr2ogr -f MVT ./tiles/$name $input_file -dsco MINZOOM=$minzoom -dsco MAXZOOM=$maxzoom -dsco NAME=$name

#method 2
'''
ogr2ogr -f GeoJSONSeq $geojson_file $input_file
tippecanoe --name=$name --layer=$name --read-parallel --no-progress-indicator --output-to-directory=./tiles/$name $geojson_file --force --no-feature-limit --no-tile-size-limit -rg --maximum-zoom=$maxzoom --minimum-zoom=$minzoom
'''

# upload tiles
'''
# method 1 to upload tiles
./mc rm minio/test/$name -r --force
./mc mirror ./tiles/$name minio/test/$name/  --attr "Content-Type=application/octet-stream;Content-Encoding=gzip" 
./mc cp ./tiles/$name/metadata.json minio/test/$name/metadata.json
'''

'''
# method 2 to upload tiles - all zoom levels are getting updated parallel
./mc rm minio/test/$name -r --force -q 
./mc cp ./tiles/$name/metadata.json minio/test/$name/metadata.json
parallel --keep-order --jobs 2 './mc mirror ./tiles/$name/{} minio/test/$name/{}  -q --attr "Content-Type=application/octet-stream;Content-Encoding=gzip"' ::: {$minzoom..$maxzoom}
'''


