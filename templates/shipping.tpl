<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>代发快递 - 快递驿站</title>
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
    <header class="topbar">
        <div class="container">
            <a href="/" class="logo">📦 快递驿站</a>
            <nav>
                <a href="/">首页</a>
                <a href="/arrival/">到件登记</a>
                <a href="/pickup/">取件出库</a>
                <a href="/overdue/">超期提醒</a>
                <a href="/shipping/" class="active">代发快递</a>
                <a href="/stats">统计/查件</a>
            </nav>
        </div>
    </header>
    <main class="container main-content">
        <h2>🚚 代发快递</h2>

        <div class="mb-15">
            <a href="/shipping/history" class="btn btn-default">📋 查看今日代发记录</a>
        </div>

        % if message:
        <div class="alert alert-info">{{message}}</div>
        % end

        <form method="POST" action="{{'/shipping/confirm' if shipment else '/shipping/calc_fee'}}" class="form">
            <h3>寄件人信息</h3>
            <div class="grid-3">
                <div class="form-group">
                    <label>姓名 *</label>
                    <input type="text" name="sender_name" value="{{shipment['sender_name'] if shipment else ''}}" required>
                </div>
                <div class="form-group">
                    <label>手机号 *</label>
                    <input type="text" name="sender_phone" value="{{shipment['sender_phone'] if shipment else ''}}" required>
                </div>
                <div class="form-group">
                    <label>地址 *</label>
                    <input type="text" name="sender_addr" value="{{shipment['sender_addr'] if shipment else ''}}" required>
                </div>
            </div>

            <h3 class="mt-20">收件人信息</h3>
            <div class="grid-3">
                <div class="form-group">
                    <label>姓名 *</label>
                    <input type="text" name="receiver_name" value="{{shipment['receiver_name'] if shipment else ''}}" required>
                </div>
                <div class="form-group">
                    <label>手机号 *</label>
                    <input type="text" name="receiver_phone" value="{{shipment['receiver_phone'] if shipment else ''}}" required>
                </div>
                <div class="form-group">
                    <label>地址 *</label>
                    <input type="text" name="receiver_addr" value="{{shipment['receiver_addr'] if shipment else ''}}" required>
                </div>
            </div>

            <h3 class="mt-20">包裹信息</h3>
            <div class="grid-3">
                <div class="form-group">
                    <label>快递公司 *</label>
                    <select name="company" id="company" required onchange="reCalc()">
                        % for c in companies:
                        <option value="{{c}}" {{'selected' if shipment and shipment['company']==c else ''}}>{{c}}</option>
                        % end
                    </select>
                </div>
                <div class="form-group">
                    <label>重量（kg） *</label>
                    <input type="number" step="0.1" min="0.1" name="weight" id="weight" value="{{shipment['weight'] if shipment else ''}}" required onchange="reCalc()">
                </div>
                <div class="form-group">
                    <label>预估运费（元）</label>
                    % if shipment:
                    <input type="text" name="fee" value="{{shipment['fee']}}" readonly class="fee-display">
                    % else:
                    <input type="text" id="fee_display" readonly class="fee-display" placeholder="自动计算">
                    <input type="hidden" name="fee" id="fee_hidden">
                    % end
                </div>
            </div>

            <div class="mt-20">
                % if shipment:
                <button type="submit" class="btn btn-primary btn-lg">✅ 确认下单并打单</button>
                <a href="/shipping/" class="btn btn-default btn-lg">重新填写</a>
                % else:
                <button type="submit" class="btn btn-primary btn-lg">💴 计算运费</button>
                % end
            </div>

            <p class="muted mt-15">
                运费规则：首重1kg 10元，续重每kg +5元；顺丰上浮30%
            </p>
        </form>
    </main>
    <footer class="footer">
        <div class="container">
            <small>快递驿站管理系统</small>
        </div>
    </footer>
    <script>
    function reCalc() {
        var weight = parseFloat(document.getElementById('weight').value) || 0;
        var company = document.getElementById('company').value;
        if (weight <= 0) return;
        var xhr = new XMLHttpRequest();
        xhr.open('GET', '/shipping/api/calc_fee?weight=' + weight + '&company=' + encodeURIComponent(company));
        xhr.onload = function() {
            var data = JSON.parse(xhr.responseText);
            document.getElementById('fee_display').value = data.fee + ' 元';
            document.getElementById('fee_hidden').value = data.fee;
        };
        xhr.send();
    }
    </script>
</body>
</html>
