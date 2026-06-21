import os
import sys
from datetime import date

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from bottle import Bottle, request, template, redirect, response
import json

from database.db import get_conn
from utils import is_overdue, get_overdue_days, OVERDUE_DAYS

app = Bottle()


def get_overdue_packages():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("""
        SELECT *, julianday('now') - julianday(arrival_date) as days
        FROM packages WHERE status='pending'
        ORDER BY arrival_date ASC
    """)
    all_pending = [dict(row) for row in cur.fetchall()]
    conn.close()

    overdue_list = []
    for pkg in all_pending:
        if is_overdue(pkg['arrival_date']):
            pkg['overdue_days'] = get_overdue_days(pkg['arrival_date']) - OVERDUE_DAYS
            overdue_list.append(pkg)
    return overdue_list


@app.route('/')
def overdue_list():
    overdue = get_overdue_packages()
    return template('overdue', packages=overdue, OVERDUE_DAYS=OVERDUE_DAYS, message='')


@app.route('/remind', method='POST')
def send_reminders():
    pkg_ids = request.forms.getall('pkg_ids')
    if not pkg_ids:
        overdue = get_overdue_packages()
        return template('overdue', packages=overdue, OVERDUE_DAYS=OVERDUE_DAYS,
                        message='请选择要提醒的包裹')

    conn = get_conn()
    cur = conn.cursor()

    today = date.today().isoformat()
    sent_count = 0
    for pid in pkg_ids:
        cur.execute("SELECT id, phone_tail FROM packages WHERE id=? AND status='pending'", (pid,))
        pkg = cur.fetchone()
        if pkg:
            cur.execute("""
                INSERT INTO reminders (package_id, phone_tail, reminder_date)
                VALUES (?, ?, ?)
            """, (pkg['id'], pkg['phone_tail'], today))
            sent_count += 1

    conn.commit()
    conn.close()

    overdue = get_overdue_packages()
    msg = f'已向 {sent_count} 个包裹的收件人发送取件提醒（模拟短信）'
    return template('overdue', packages=overdue, OVERDUE_DAYS=OVERDUE_DAYS, message=msg)


@app.route('/remind_all', method='POST')
def remind_all():
    overdue = get_overdue_packages()
    if not overdue:
        return template('overdue', packages=[], OVERDUE_DAYS=OVERDUE_DAYS,
                        message='没有超期包裹')

    conn = get_conn()
    cur = conn.cursor()
    today = date.today().isoformat()
    sent_count = 0
    for pkg in overdue:
        cur.execute("""
            INSERT INTO reminders (package_id, phone_tail, reminder_date)
            VALUES (?, ?, ?)
        """, (pkg['id'], pkg['phone_tail'], today))
        sent_count += 1
    conn.commit()
    conn.close()

    return template('overdue', packages=overdue, OVERDUE_DAYS=OVERDUE_DAYS,
                    message=f'已向全部 {sent_count} 个超期包裹发送取件提醒')


@app.route('/api/list')
def api_list():
    response.content_type = 'application/json'
    overdue = get_overdue_packages()
    return json.dumps(overdue, ensure_ascii=False)
