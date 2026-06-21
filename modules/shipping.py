import os
import sys
from datetime import date
import random
import string

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from bottle import Bottle, request, template, redirect, response
import json

from database.db import get_conn
from utils import calculate_fee, BASE_FEE, PER_KG_FEE

app = Bottle()

COMPANIES = ['顺丰', '中通', '圆通', '申通', '韵达', '百世', '邮政', '京东', '极兔', '德邦']


def generate_tracking_no(company):
    prefix_map = {
        '顺丰': 'SF', '中通': 'ZT', '圆通': 'YT', '申通': 'ST',
        '韵达': 'YD', '百世': 'BS', '邮政': 'YZ', '京东': 'JD',
        '极兔': 'JT', '德邦': 'DB'
    }
    prefix = prefix_map.get(company, 'EX')
    nums = ''.join(random.choices(string.digits, k=12))
    return prefix + nums


@app.route('/')
def shipping_form():
    return template('shipping', companies=COMPANIES, shipment=None, message='')


@app.route('/calc_fee', method='POST')
def calc_fee():
    weight_str = request.forms.get('weight', '')
    company = request.forms.get('company', COMPANIES[0])
    try:
        weight = float(weight_str)
    except ValueError:
        return template('shipping', companies=COMPANIES, shipment=None, message='重量必须是数字')
    fee = calculate_fee(weight, company)
    shipment = {
        'sender_name': request.forms.get('sender_name', ''),
        'sender_phone': request.forms.get('sender_phone', ''),
        'sender_addr': request.forms.get('sender_addr', ''),
        'receiver_name': request.forms.get('receiver_name', ''),
        'receiver_phone': request.forms.get('receiver_phone', ''),
        'receiver_addr': request.forms.get('receiver_addr', ''),
        'weight': weight,
        'company': company,
        'fee': fee
    }
    return template('shipping', companies=COMPANIES, shipment=shipment,
                    message=f'预估运费：{fee} 元（首重1kg {BASE_FEE}元，续重每kg {PER_KG_FEE}元，顺丰上浮30%）')


@app.route('/confirm', method='POST')
def confirm_shipment():
    sender_name = request.forms.get('sender_name', '').strip()
    sender_phone = request.forms.get('sender_phone', '').strip()
    sender_addr = request.forms.get('sender_addr', '').strip()
    receiver_name = request.forms.get('receiver_name', '').strip()
    receiver_phone = request.forms.get('receiver_phone', '').strip()
    receiver_addr = request.forms.get('receiver_addr', '').strip()
    weight_str = request.forms.get('weight', '')
    company = request.forms.get('company', '').strip()
    fee_str = request.forms.get('fee', '')

    required = [sender_name, sender_phone, sender_addr, receiver_name, receiver_phone, receiver_addr, weight_str, company]
    if not all(required):
        return template('shipping', companies=COMPANIES, shipment=None, message='请填写所有字段')

    try:
        weight = float(weight_str)
        fee = float(fee_str) if fee_str else calculate_fee(weight, company)
    except ValueError:
        return template('shipping', companies=COMPANIES, shipment=None, message='重量或运费格式错误')

    tracking_no = generate_tracking_no(company)

    conn = get_conn()
    cur = conn.cursor()
    cur.execute("""
        INSERT INTO shipments (
            sender_name, sender_phone, sender_addr,
            receiver_name, receiver_phone, receiver_addr,
            weight, fee, company, tracking_no
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (sender_name, sender_phone, sender_addr,
          receiver_name, receiver_phone, receiver_addr,
          weight, fee, company, tracking_no))
    ship_id = cur.lastrowid
    conn.commit()

    cur.execute("SELECT * FROM shipments WHERE id=?", (ship_id,))
    shipment = dict(cur.fetchone())
    conn.close()

    return template('shipping_label', shipment=shipment)


@app.route('/history')
def history():
    conn = get_conn()
    cur = conn.cursor()
    today = date.today().isoformat()
    cur.execute("""
        SELECT * FROM shipments
        WHERE date(created_at)=?
        ORDER BY created_at DESC LIMIT 50
    """, (today,))
    rows = [dict(row) for row in cur.fetchall()]
    conn.close()
    return template('shipping_history', shipments=rows)


@app.route('/label/<ship_id>')
def view_label(ship_id):
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SELECT * FROM shipments WHERE id=?", (ship_id,))
    shipment = cur.fetchone()
    conn.close()
    if not shipment:
        redirect('/shipping')
    return template('shipping_label', shipment=dict(shipment))


@app.route('/api/calc_fee')
def api_calc_fee():
    response.content_type = 'application/json'
    try:
        weight = float(request.query.get('weight', '0'))
        company = request.query.get('company', '')
    except ValueError:
        return json.dumps({'fee': 0}, ensure_ascii=False)
    return json.dumps({'fee': calculate_fee(weight, company)}, ensure_ascii=False)
