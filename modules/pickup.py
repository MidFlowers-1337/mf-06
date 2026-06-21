import os
import sys
from datetime import date

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from bottle import Bottle, request, template, response
import json

from database.db import get_conn
from utils import is_overdue, get_overdue_days, verify_pickup, OVERDUE_DAYS

app = Bottle()


@app.route('/')
def pickup_form():
    return template('pickup', packages=[], search_key='', message='', mode='')


@app.route('/search', method='POST')
def search_packages():
    key = request.forms.get('key', '').strip()
    mode = request.forms.get('mode', 'phone')

    if not key:
        return template('pickup', packages=[], search_key=key, message='请输入搜索内容', mode=mode)

    conn = get_conn()
    cur = conn.cursor()

    packages = []
    if mode == 'phone':
        if len(key) != 4 or not key.isdigit():
            conn.close()
            return template('pickup', packages=[], search_key=key,
                            message='手机尾号必须是4位数字', mode=mode)
        cur.execute("""
            SELECT *, julianday('now') - julianday(arrival_date) as days
            FROM packages WHERE status='pending' AND phone_tail=?
            ORDER BY arrival_date ASC, shelf_no ASC, shelf_layer ASC
        """, (key,))
        packages = [dict(row) for row in cur.fetchall()]
    elif mode == 'code':
        cur.execute("""
            SELECT *, julianday('now') - julianday(arrival_date) as days
            FROM packages WHERE status='pending' AND pickup_code=?
        """, (key,))
        packages = [dict(row) for row in cur.fetchall()]
    elif mode == 'tracking':
        cur.execute("""
            SELECT *, julianday('now') - julianday(arrival_date) as days
            FROM packages WHERE status='pending' AND tracking_no LIKE ?
        """, (f'%{key}%',))
        packages = [dict(row) for row in cur.fetchall()]

    conn.close()

    if not packages:
        return template('pickup', packages=[], search_key=key,
                        message='未找到待取包裹', mode=mode)

    for p in packages:
        p['overdue'] = is_overdue(p['arrival_date'])

    msg = f'找到 {len(packages)} 个待取包裹'
    return template('pickup', packages=packages, search_key=key, message=msg, mode=mode)


@app.route('/verify', method='POST')
def verify_and_pickup():
    pkg_ids = request.forms.getall('pkg_ids')
    verify_key = request.forms.get('verify_key', '').strip()
    verify_mode = request.forms.get('verify_mode', 'phone')

    if not pkg_ids:
        return template('pickup', packages=[], search_key=verify_key,
                        message='请选择要取走的包裹', mode=verify_mode)

    if not verify_key:
        return _reload_with_packages(pkg_ids, verify_key, verify_mode, '请输入核验信息')

    conn = get_conn()
    cur = conn.cursor()

    placeholders = ','.join('?' * len(pkg_ids))
    cur.execute(f"SELECT * FROM packages WHERE id IN ({placeholders})", pkg_ids)
    selected = [dict(row) for row in cur.fetchall()]

    errors = []
    for pkg in selected:
        if verify_mode == 'phone':
            ok, msg = verify_pickup(pkg, phone_tail=verify_key)
        elif verify_mode == 'code':
            ok, msg = verify_pickup(pkg, pickup_code=verify_key)
        else:
            ok, msg = verify_pickup(pkg, phone_tail=verify_key)
        if not ok:
            errors.append(f'单号 {pkg["tracking_no"]}: {msg}')

    if errors:
        conn.close()
        return _reload_with_packages(pkg_ids, verify_key, verify_mode, '；'.join(errors))

    today = date.today().isoformat()
    picked_by = '自提'
    for pkg in selected:
        cur.execute("""
            UPDATE packages SET status='picked', picked_date=?, picked_by=? WHERE id=?
        """, (today, picked_by, pkg['id']))
    conn.commit()
    conn.close()

    return template('pickup_success', count=len(selected), packages=selected)


@app.route('/api/verify')
def api_verify():
    response.content_type = 'application/json'
    pkg_id = request.query.get('pkg_id')
    phone_tail = request.query.get('phone_tail')
    pickup_code = request.query.get('pickup_code')
    if not pkg_id:
        return json.dumps({'ok': False, 'msg': '缺少包裹ID'}, ensure_ascii=False)
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SELECT * FROM packages WHERE id=?", (pkg_id,))
    pkg = cur.fetchone()
    conn.close()
    if not pkg:
        return json.dumps({'ok': False, 'msg': '包裹不存在'}, ensure_ascii=False)
    ok, msg = verify_pickup(dict(pkg), phone_tail=phone_tail, pickup_code=pickup_code)
    return json.dumps({'ok': ok, 'msg': msg}, ensure_ascii=False)


def _reload_with_packages(pkg_ids, key, mode, msg):
    conn = get_conn()
    cur = conn.cursor()
    placeholders = ','.join('?' * len(pkg_ids))
    cur.execute(f"""
        SELECT *, julianday('now') - julianday(arrival_date) as days
        FROM packages WHERE id IN ({placeholders}) AND status='pending'
        ORDER BY arrival_date ASC
    """, pkg_ids)
    packages = [dict(row) for row in cur.fetchall()]
    for p in packages:
        p['overdue'] = is_overdue(p['arrival_date'])
    conn.close()
    return template('pickup', packages=packages, search_key=key, message=msg, mode=mode)
