import os
import sys
import unittest
import tempfile
import shutil
from datetime import date, timedelta

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, BASE_DIR)

from database import db
from utils import is_overdue, get_overdue_days, verify_pickup, OVERDUE_DAYS, calculate_fee


class TestDatabase(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.mkdtemp()
        self.test_db = os.path.join(self.tmp_dir, 'test.db')
        db.DB_PATH = self.test_db
        db.SCHEMA_PATH = os.path.join(BASE_DIR, 'database', 'schema.sql')
        db.init_db()

    def tearDown(self):
        shutil.rmtree(self.tmp_dir, ignore_errors=True)

    def test_init_db_creates_tables(self):
        conn = db.get_conn()
        cur = conn.cursor()
        cur.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = [row['name'] for row in cur.fetchall()]
        conn.close()
        self.assertIn('packages', tables)
        self.assertIn('shipments', tables)
        self.assertIn('reminders', tables)


class TestOverdueLogic(unittest.TestCase):
    def test_not_overdue_same_day(self):
        today = date.today().isoformat()
        self.assertFalse(is_overdue(today, today))
        self.assertEqual(get_overdue_days(today, today), 0)

    def test_not_overdue_one_day(self):
        today = date.today()
        arrival = (today - timedelta(days=1)).isoformat()
        self.assertFalse(is_overdue(arrival, today.isoformat()))
        self.assertEqual(get_overdue_days(arrival, today.isoformat()), 1)

    def test_not_overdue_exact_days(self):
        today = date.today()
        arrival = (today - timedelta(days=OVERDUE_DAYS)).isoformat()
        self.assertFalse(is_overdue(arrival, today.isoformat()))

    def test_overdue_one_day_over(self):
        today = date.today()
        arrival = (today - timedelta(days=OVERDUE_DAYS + 1)).isoformat()
        self.assertTrue(is_overdue(arrival, today.isoformat()))
        self.assertEqual(get_overdue_days(arrival, today.isoformat()), OVERDUE_DAYS + 1)

    def test_overdue_long_overdue(self):
        today = date.today()
        arrival = (today - timedelta(days=30)).isoformat()
        self.assertTrue(is_overdue(arrival, today.isoformat()))
        self.assertEqual(get_overdue_days(arrival, today.isoformat()), 30)


class TestPickupVerification(unittest.TestCase):
    def test_verify_phone_success(self):
        pkg = {'status': 'pending', 'phone_tail': '1234', 'pickup_code': '567890'}
        ok, msg = verify_pickup(pkg, phone_tail='1234')
        self.assertTrue(ok)
        self.assertEqual(msg, '核验通过')

    def test_verify_phone_fail(self):
        pkg = {'status': 'pending', 'phone_tail': '1234', 'pickup_code': '567890'}
        ok, msg = verify_pickup(pkg, phone_tail='9999')
        self.assertFalse(ok)
        self.assertIn('不匹配', msg)

    def test_verify_code_success(self):
        pkg = {'status': 'pending', 'phone_tail': '1234', 'pickup_code': '567890'}
        ok, msg = verify_pickup(pkg, pickup_code='567890')
        self.assertTrue(ok)

    def test_verify_code_fail(self):
        pkg = {'status': 'pending', 'phone_tail': '1234', 'pickup_code': '567890'}
        ok, msg = verify_pickup(pkg, pickup_code='000000')
        self.assertFalse(ok)
        self.assertIn('不匹配', msg)

    def test_verify_already_picked(self):
        pkg = {'status': 'picked', 'phone_tail': '1234', 'pickup_code': '567890'}
        ok, msg = verify_pickup(pkg, phone_tail='1234')
        self.assertFalse(ok)
        self.assertIn('已被取走', msg)

    def test_verify_both_success(self):
        pkg = {'status': 'pending', 'phone_tail': '1234', 'pickup_code': '567890'}
        ok, msg = verify_pickup(pkg, phone_tail='1234', pickup_code='567890')
        self.assertTrue(ok)

    def test_verify_wrong_person_phone(self):
        pkg = {'status': 'pending', 'phone_tail': '1234', 'pickup_code': '567890'}
        ok, msg = verify_pickup(pkg, phone_tail='5678')
        self.assertFalse(ok)

    def test_verify_empty_phone(self):
        pkg = {'status': 'pending', 'phone_tail': '1234', 'pickup_code': '567890'}
        ok, msg = verify_pickup(pkg, phone_tail='')
        self.assertTrue(ok)


class TestShippingFee(unittest.TestCase):
    def test_zero_weight(self):
        self.assertEqual(calculate_fee(0), 0)

    def test_negative_weight(self):
        self.assertEqual(calculate_fee(-1), 0)

    def test_one_kg(self):
        self.assertEqual(calculate_fee(1), 10)

    def test_two_kg(self):
        self.assertEqual(calculate_fee(2), 15)

    def test_three_kg(self):
        self.assertEqual(calculate_fee(3), 20)

    def test_half_kg(self):
        self.assertEqual(calculate_fee(0.5), 10)

    def test_shunfeng_premium(self):
        normal = calculate_fee(1, '中通')
        sf = calculate_fee(1, '顺丰')
        self.assertGreater(sf, normal)
        self.assertAlmostEqual(sf, normal * 1.3)

    def test_shunfeng_two_kg(self):
        fee = calculate_fee(2, '顺丰')
        self.assertAlmostEqual(fee, 19.5)


class TestPackageWorkflow(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.mkdtemp()
        self.test_db = os.path.join(self.tmp_dir, 'test.db')
        db.DB_PATH = self.test_db
        db.SCHEMA_PATH = os.path.join(BASE_DIR, 'database', 'schema.sql')
        db.init_db()

    def tearDown(self):
        shutil.rmtree(self.tmp_dir, ignore_errors=True)

    def test_add_and_pickup_workflow(self):
        conn = db.get_conn()
        cur = conn.cursor()

        code = '123456'
        cur.execute("""
            INSERT INTO packages (tracking_no, phone_tail, company, arrival_date,
                                  shelf_no, shelf_layer, pickup_code)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, ('SF1234567890', '8888', '顺丰', date.today().isoformat(),
              1, '2', code))
        conn.commit()

        cur.execute("SELECT * FROM packages WHERE tracking_no='SF1234567890'")
        pkg = dict(cur.fetchone())
        self.assertEqual(pkg['status'], 'pending')
        self.assertEqual(pkg['phone_tail'], '8888')

        ok, msg = verify_pickup(pkg, phone_tail='8888')
        self.assertTrue(ok)

        ok, msg = verify_pickup(pkg, phone_tail='0000')
        self.assertFalse(ok)

        cur.execute("""
            UPDATE packages SET status='picked', picked_date=?, picked_by=?
            WHERE id=?
        """, (date.today().isoformat(), 'test', pkg['id']))
        conn.commit()

        cur.execute("SELECT status FROM packages WHERE id=?", (pkg['id'],))
        self.assertEqual(cur.fetchone()['status'], 'picked')

        conn.close()

    def test_duplicate_tracking_prevented(self):
        conn = db.get_conn()
        cur = conn.cursor()

        cur.execute("""
            INSERT INTO packages (tracking_no, phone_tail, company, arrival_date,
                                  shelf_no, shelf_layer, pickup_code)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, ('ZT000001', '1111', '中通', date.today().isoformat(), 1, '1', '000001'))
        conn.commit()

        with self.assertRaises(Exception):
            cur.execute("""
                INSERT INTO packages (tracking_no, phone_tail, company, arrival_date,
                                      shelf_no, shelf_layer, pickup_code)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, ('ZT000001', '2222', '中通', date.today().isoformat(), 1, '1', '000002'))
            conn.commit()

        conn.close()

    def test_overdue_packages_detected(self):
        conn = db.get_conn()
        cur = conn.cursor()

        old_date = (date.today() - timedelta(days=OVERDUE_DAYS + 5)).isoformat()
        cur.execute("""
            INSERT INTO packages (tracking_no, phone_tail, company, arrival_date,
                                  shelf_no, shelf_layer, pickup_code)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, ('YD999999', '5555', '韵达', old_date, 3, '4', '999999'))
        conn.commit()

        cur.execute("""
            SELECT arrival_date FROM packages WHERE tracking_no='YD999999'
        """)
        arrival = cur.fetchone()['arrival_date']
        self.assertTrue(is_overdue(arrival))
        self.assertGreater(get_overdue_days(arrival), OVERDUE_DAYS)

        conn.close()


if __name__ == '__main__':
    unittest.main(verbosity=2)
