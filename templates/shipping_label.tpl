<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>打印面单 - 快递驿站</title>
    <link rel="stylesheet" href="/static/css/style.css">
    <style>
        .label {
            width: 400px;
            border: 2px solid #333;
            padding: 20px;
            margin: 30px auto;
            font-family: Arial, sans-serif;
            background: #fff;
        }
        .label-header {
            text-align: center;
            font-size: 22px;
            font-weight: bold;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        .label-row {
            margin: 8px 0;
            font-size: 14px;
            line-height: 1.6;
        }
        .label-label {
            font-weight: bold;
            color: #555;
            display: inline-block;
            width: 70px;
        }
        .label-barcode {
            text-align: center;
            margin-top: 15px;
            padding: 10px;
            border-top: 2px dashed #999;
            font-family: 'Courier New', monospace;
            font-size: 20px;
            letter-spacing: 3px;
        }
        .label-tracking {
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            margin-top: 10px;
        }
        .label-fee {
            text-align: right;
            font-size: 16px;
            font-weight: bold;
            color: #c0392b;
            margin-top: 10px;
        }
        .no-print { margin: 20px; text-align: center; }
        @media print {
            .no-print, .topbar, .footer { display: none !important; }
            body { background: #fff; }
            .label { margin: 0; border: 1px solid #000; }
        }
    </style>
</head>
<body>
    <header class="topbar">
        <div class="container">
            <a href="/" class="logo">📦 快递驿站</a>
            <nav>
                <a href="/">首页</a>
                <a href="/shipping/" class="active">代发快递</a>
                <a href="/stats">统计/查件</a>
            </nav>
        </div>
    </header>

    <div class="no-print">
        <div class="container">
            <h2>✅ 下单成功！</h2>
            <p>请确认信息无误后点击打印面单</p>
            <button onclick="window.print()" class="btn btn-primary btn-lg">🖨️ 打印面单</button>
            <a href="/shipping/" class="btn btn-default btn-lg">继续代发</a>
            <a href="/shipping/history" class="btn btn-default btn-lg">查看历史</a>
        </div>
    </div>

    <div class="label" id="label">
        <div class="label-header">{{shipment['company']}} 快递面单</div>
        <div class="label-row">
            <span class="label-label">寄件人：</span>
            {{shipment['sender_name']}} {{shipment['sender_phone']}}
        </div>
        <div class="label-row">
            <span class="label-label">寄件地址：</span>
            {{shipment['sender_addr']}}
        </div>
        <div style="border-top:1px dashed #ccc; margin:10px 0;"></div>
        <div class="label-row">
            <span class="label-label">收件人：</span>
            <strong>{{shipment['receiver_name']}} {{shipment['receiver_phone']}}</strong>
        </div>
        <div class="label-row">
            <span class="label-label">收件地址：</span>
            <strong>{{shipment['receiver_addr']}}</strong>
        </div>
        <div style="border-top:1px dashed #ccc; margin:10px 0;"></div>
        <div class="label-row">
            <span class="label-label">重量：</span>{{shipment['weight']}} kg
            &nbsp;&nbsp;<span class="label-label">费用：</span><strong style="color:#c0392b;">¥{{shipment['fee']}}</strong>
        </div>
        <div class="label-barcode">
            █ ██ █ ████ ██ █ ███ ██ █ ████ █
        </div>
        <div class="label-tracking">{{shipment['tracking_no']}}</div>
    </div>

    <footer class="footer no-print">
        <div class="container">
            <small>快递驿站管理系统</small>
        </div>
    </footer>
</body>
</html>
