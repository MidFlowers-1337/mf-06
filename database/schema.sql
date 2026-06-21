PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS packages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tracking_no TEXT NOT NULL UNIQUE,
    phone_tail TEXT NOT NULL,
    company TEXT NOT NULL,
    arrival_date TEXT NOT NULL,
    shelf_no INTEGER NOT NULL,
    shelf_layer TEXT NOT NULL,
    pickup_code TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'pending',
    picked_date TEXT,
    picked_by TEXT,
    created_at TEXT DEFAULT (datetime('now','localtime'))
);

CREATE INDEX IF NOT EXISTS idx_packages_phone ON packages(phone_tail);
CREATE INDEX IF NOT EXISTS idx_packages_status ON packages(status);
CREATE INDEX IF NOT EXISTS idx_packages_pickup_code ON packages(pickup_code);

CREATE TABLE IF NOT EXISTS shipments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sender_name TEXT NOT NULL,
    sender_phone TEXT NOT NULL,
    sender_addr TEXT NOT NULL,
    receiver_name TEXT NOT NULL,
    receiver_phone TEXT NOT NULL,
    receiver_addr TEXT NOT NULL,
    weight REAL NOT NULL,
    fee REAL NOT NULL,
    company TEXT NOT NULL,
    tracking_no TEXT,
    status TEXT NOT NULL DEFAULT 'created',
    created_at TEXT DEFAULT (datetime('now','localtime'))
);

CREATE TABLE IF NOT EXISTS reminders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    package_id INTEGER NOT NULL,
    phone_tail TEXT NOT NULL,
    reminder_date TEXT NOT NULL,
    sent_at TEXT DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (package_id) REFERENCES packages(id)
);
