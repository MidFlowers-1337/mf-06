import os
import sys

try:
    import legacy_cgi
    sys.modules['cgi'] = legacy_cgi
except ImportError:
    pass

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from bottle import Bottle, static_file, redirect

from database.db import init_db
from modules import arrival, pickup, overdue, shipping

STATIC_ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'static')
TEMPLATE_ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'templates')

app = Bottle()

init_db()

app.mount('/arrival', arrival.app)
app.mount('/pickup', pickup.app)
app.mount('/overdue', overdue.app)
app.mount('/shipping', shipping.app)


@app.route('/')
def index():
    from bottle import template
    return template('index')


@app.route('/static/<filepath:path>')
def serve_static(filepath):
    return static_file(filepath, root=STATIC_ROOT)


@app.route('/stats')
def stats():
    from bottle import template
    import sqlite3
    from database.db import DB_PATH
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    today = __import__('datetime').date.today().isoformat()
    cur.execute("SELECT COUNT(*) as c FROM packages WHERE arrival_date=?", (today,))
    today_arrived = cur.fetchone()['c']

    cur.execute("SELECT COUNT(*) as c FROM packages WHERE status='picked' AND picked_date=?", (today,))
    today_picked = cur.fetchone()['c']

    cur.execute("SELECT COUNT(*) as c FROM packages WHERE status='pending'")
    pending = cur.fetchone()['c']

    cur.execute("""
        SELECT p.*, julianday('now') - julianday(p.arrival_date) as days
        FROM packages p
        WHERE p.status='pending'
        ORDER BY p.arrival_date ASC, p.shelf_no ASC, p.shelf_layer ASC
    """)
    pending_list = [dict(row) for row in cur.fetchall()]
    from utils import is_overdue
    for p in pending_list:
        p['overdue'] = is_overdue(p['arrival_date'])
        p['days_int'] = int(p['days']) if p['days'] else 0

    conn.close()
    return template('stats', today_arrived=today_arrived, today_picked=today_picked,
                    pending=pending, pending_list=pending_list)


if __name__ == '__main__':
    from bottle import TEMPLATE_PATH
    TEMPLATE_PATH.insert(0, TEMPLATE_ROOT)
    app.run(host='0.0.0.0', port=8080, debug=True, reloader=False)
