CREATE OR REPLACE FUNCTION opendata.tilebbox (
	z integer,
	x integer,
	y integer,
	srid integer DEFAULT 3857)
    RETURNS geometry
    LANGUAGE 'plpgsql'

    COST 100
    IMMUTABLE 
AS $body$
declare
    max numeric := 20037508.34;
    res numeric := (max*2)/(2^z);
    bbox geometry;
begin
    bbox := ST_MakeEnvelope(
        -max + (x * res),
        max - (y * res),
        -max + (x * res) + res,
        max - (y * res) - res,
        3857
    );
    if srid = 3857 then
        return bbox;
    else
        return ST_Transform(bbox, srid);
    end if;
end;
$body$;



CREATE OR REPLACE FUNCTION opendata.zres(
	z integer)
    RETURNS double precision
    LANGUAGE 'sql'

    COST 100
    IMMUTABLE STRICT 
AS $body$
select (40075016.6855785/(256*2^z));
$body$;