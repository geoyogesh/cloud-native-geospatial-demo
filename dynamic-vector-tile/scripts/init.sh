#!/bin/bash
set -e

dbhost="db"
dbuser="opendata_user"
dbname="opendata"
dbschema="opendata"
dbpassword="password"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER opendata_user WITH LOGIN
        SUPERUSER
        NOINHERIT
        CREATEDB
        CREATEROLE
        NOREPLICATION
        PASSWORD 'password';
    CREATE DATABASE opendata;
    GRANT ALL PRIVILEGES ON DATABASE opendata TO opendata_user;

    \c opendata;

    CREATE SCHEMA IF NOT EXISTS postgisftw;
    CREATE SCHEMA IF NOT EXISTS opendata;

    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "postgis";
    CREATE EXTENSION IF NOT EXISTS "pg_trgm";
    CREATE EXTENSION IF NOT EXISTS "btree_gin";
    CREATE EXTENSION IF NOT EXISTS btree_gist;
    select * FROM pg_extension;
EOSQL
