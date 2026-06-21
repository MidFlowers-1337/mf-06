import os
import sys
from datetime import date

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from bottle import Bottle, request, template, redirect, response
import json

from database.db import get_conn, generate_pickup_code

app = Bottle()

COMPANIES = ['顺丰', '中通', '圆通', '申通', '韵达', '百世', '邮政', '京东', '极兔', '德邦']


@app.route('/')
def arrival_form():
    conn = get_conn()
    today = date.today().isoformat()
    cur = conn.cursor()
    cur.execute("SELECT * FROM packages WHERE arrival_date=? ORDER BY created_at DESC LIMIT 20", (today,))
    recent = [dict(row) for row in cur.fetchall()]
    conn.close()
    return template('arrival', companies=COMPANIES, today=today, recent=recent, message='')


@app.route('/add', method='POST')
def add_package():
    tracking_no = request.forms.get('tracking_no', '').strip()
    phone_tail = request.forms.get('phone_tail', '').strip()
    company = request.forms.get('company', '').strip()
    arrival_date = request.forms.get('arrival_date', '').strip()
    shelf_no = request.forms.get('shelf_no', '').strip()
    shelf_layer = request.forms.get('shelf_layer', '').strip()

    if not all([tracking_no, phone_tail, company, arrival_date, shelf_no, shelf_layer]):
        return _arrival_page_with_msg('请填写所有字段')

    if len(phone_tail) != 4 or not phone_tail.isdigit():
        return _arrival_page_with_msg('手机尾号必须是4位数字')

    try:
        shelf_no = int(shelf_no)
    except ValueError:
        return _arrival_page_with_msg('货架号必须是数字')

    conn = get_conn()
    cur = conn.cursor()

    cur.execute("SELECT id FROM packages WHERE tracking_no=? AND status='pending'", (tracking_no,))
    if cur.fetchone():
        conn.close()
        return _arrival_page_with_msg('该单号已存在且未取走')

    pickup_code = generate_pickup_code()
    while True:
        cur.execute("SELECT id FROM packages WHERE pickup_code=?", (pickup_code,))
        if not cur.fetchone():
            break
        pickup_code = generate_pickup_code()

    try:
        cur.execute("""
            INSERT INTO packages (tracking_no, phone_tail, company, arrival_date, shelf_no, shelf_layer, pickup_code)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (tracking_no, phone_tail, company, arrival_date, shelf_no, shelf_layer, pickup_code))
        conn.commit()
        pkg_id = cur.lastrowid
    except Exception as e:
        conn.close()
        return _arrival_page_with_msg(f'入库失败: {e}')

    cur.execute("SELECT * FROM packages WHERE id=?", (pkg_id,))
    new_pkg = dict(cur.fetchone())
    conn.close()

    today = date.today().isoformat()
    conn2 = get_conn()
    cur2 = conn2.cursor()
    cur2.execute("SELECT * FROM packages WHERE arrival_date=? ORDER BY created_at DESC LIMIT 20", (today,))
    recent = [dict(row) for row in cur2.fetchall()]
    conn2.close()

    return template('arrival', companies=COMPANIES, today=today, recent=recent,
                    message=f'入库成功！取件码：{new_pkg["pickup_code"]}，货架：{new_pkg["shelf_no"]}号{new_pkg["shelf_layer"]}层')


@app.route('/api/search')
def api_search():
    response.content_type = 'application/json'
    q = request.query.get('q', '').strip()
    if not q:
        return json.dumps([])
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("""
        SELECT * FROM packages
        WHERE status='pending' AND (tracking_no LIKE ? OR phone_tail LIKE ? OR pickup_code LIKE ?)
        ORDER BY arrival_date DESC LIMIT 20
    """, (f'%{q}%', f'%{q}%', f'%{q}%'))
    rows = [dict(row) for row in cur.fetchall()]
    conn.close()
    return json.dumps(rows, ensure_ascii=False)


def _arrival_page_with_msg(msg):
    conn = get_conn()
    today = date.today().isoformat()
    cur = conn.cursor()
    cur.execute("SELECT * FROM packages WHERE arrival_date=? ORDER BY created_at DESC LIMIT 20", (today,))
    recent = [dict(row) for row in cur.fetchall()]
    conn.close()
    return template('arrival', companies=COMPANIES, today=today, recent=recent, message=msg)
