import flask
from flask_cors import CORS
import psycopg2
import io
from psycopg2 import sql

app = flask.Flask(__name__)
app.config["DEBUG"] = True
CORS(app)
cors = CORS(app, resources={r"/tiles/*": {"origins": "*"}})
con = None

@app.route('/', methods=['GET'])
def home():
    return "<h1>Distant Reading Archive</h1><p>This site is a prototype API for distant reading of science fiction novels.</p>"

@app.route('/tiles/<layer>/<z>/<x>/<y>', methods=['GET'])
def my_view_func(layer, z: int, x: int, y: int):
    global con
    no_transform_sql = "SELECT public.ST_AsMVT(q, 'layer', 4096, 'geom') as vt FROM(SELECT gid, public.ST_AsMVTGeom(geom, opendata.tilebbox(%(z)s, %(x)s, %(y)s, %(dst_srid)s), 4096, 256, true ) geom FROM opendata.{} WHERE geom && opendata.tilebbox(%(z)s, %(x)s, %(y)s, %(src_srid)s) AND public.ST_Intersects(geom, opendata.tilebbox(%(z)s, %(x)s, %(y)s, %(src_srid)s))) q;"
    transform_sql = "SELECT public.ST_AsMVT(q, 'layer', 4096, 'geom') as vt FROM(SELECT gid, public.ST_AsMVTGeom(ST_Transform(geom, %(dst_srid)s), opendata.tilebbox(%(z)s, %(x)s, %(y)s, %(dst_srid)s), 4096, 256, true ) geom FROM opendata.{} WHERE geom && opendata.tilebbox(%(z)s, %(x)s, %(y)s, %(src_srid)s) AND public.ST_Intersects(geom, opendata.tilebbox(%(z)s, %(x)s, %(y)s, %(src_srid)s))) q;"
    src_srid = flask.request.args.get('src_srid') if 'src_srid' in flask.request.args else 3857 
    dst_srid = 3857

    data = None
    if con == None:
        con = psycopg2.connect(host='db', database='opendata', user='opendata_user', password='password')
    cur = None
    try:
        cur = con.cursor()
        if src_srid == dst_srid:
            cur.execute(no_transform_sql, {'x': x, 'y': y, 'z': z, 'dst_srid': dst_srid, 'src_srid': src_srid})
        else:
            cur.execute(sql.SQL(transform_sql).format(sql.Identifier(layer))
            , {'x': x, 'y': y, 'z': z, 'dst_srid': dst_srid, 'src_srid': src_srid})

        data = bytes(cur.fetchone()[0])
    except:
        con = psycopg2.connect(host='db', database='opendata', user='opendata_user', password='password')
    finally:
        if cur:
            cur.close()

    return flask.Response(data, mimetype='application/octet-stream')

app.run()
