from datetime import date, datetime

OVERDUE_DAYS = 3


def is_overdue(arrival_date_str, today_str=None):
    if today_str is None:
        today_str = date.today().isoformat()
    arrival = datetime.fromisoformat(arrival_date_str).date()
    today = datetime.fromisoformat(today_str).date()
    return (today - arrival).days > OVERDUE_DAYS


def get_overdue_days(arrival_date_str, today_str=None):
    if today_str is None:
        today_str = date.today().isoformat()
    arrival = datetime.fromisoformat(arrival_date_str).date()
    today = datetime.fromisoformat(today_str).date()
    return (today - arrival).days


def verify_pickup(package, phone_tail=None, pickup_code=None):
    if package['status'] != 'pending':
        return False, '该包裹已被取走'
    if phone_tail:
        if package['phone_tail'] != phone_tail:
            return False, '手机尾号不匹配'
    if pickup_code:
        if package['pickup_code'] != pickup_code:
            return False, '取件码不匹配'
    return True, '核验通过'


BASE_FEE = 10
PER_KG_FEE = 5


def calculate_fee(weight_kg, company=None):
    if weight_kg <= 0:
        return 0
    if weight_kg <= 1:
        fee = BASE_FEE
    else:
        fee = BASE_FEE + (weight_kg - 1) * PER_KG_FEE
    if company == '顺丰':
        fee = fee * 1.3
    return round(fee, 2)
