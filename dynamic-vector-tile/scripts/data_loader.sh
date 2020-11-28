#!/bin/bash

set -e

dbhost="db"
dbuser="opendata_user"
dbname="opendata"
dbschema="opendata"
dbpassword="password"
export PGPASSWORD=$dbpassword

#loading schema
psql -f /data/scripts/vector_tile_functions.sql --username $dbuser --dbname $dbname --host $dbhost --port "5432"



wget -O county.zip https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_county_500k.zip

unzip county.zip -d county

shp2pgsql -I -s 4326 county/cb_2018_us_county_500k.shp $dbschema.counties | psql --username $dbuser --dbname $dbname --host $dbhost --port "5432"

#is it useful
#CREATE INDEX ON opendata.counties USING gist (ST_Transform(geom, 3857));
