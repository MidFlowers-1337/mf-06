<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>代发历史 - 快递驿站</title>
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
        <h2>📋 今日代发记录</h2>
        <div class="mb-15">
            <a href="/shipping/" class="btn btn-primary">➕ 新建代发</a>
        </div>
        % if shipments:
        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>单号</th>
                        <th>公司</th>
                        <th>寄件人</th>
                        <th>收件人</th>
                        <th>重量</th>
                        <th>运费</th>
                        <th>时间</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    % for s in shipments:
                    <tr>
                        <td class="mono">{{s['tracking_no']}}</td>
                        <td>{{s['company']}}</td>
                        <td>{{s['sender_name']}}</td>
                        <td>{{s['receiver_name']}}</td>
                        <td>{{s['weight']}}kg</td>
                        <td><strong style="color:#c0392b;">¥{{s['fee']}}</strong></td>
                        <td class="muted">{{s['created_at']}}</td>
                        <td><a href="/shipping/label/{{s['id']}}" class="btn btn-sm btn-default">🖨️ 重打</a></td>
                    </tr>
                    % end
                </tbody>
            </table>
        </div>
        % else:
        <div class="empty-box">
            <div class="empty-icon">📋</div>
            <h3>暂无记录</h3>
            <p>今日还没有代发记录</p>
        </div>
        % end
    </main>
    <footer class="footer">
        <div class="container">
            <small>快递驿站管理系统</small>
        </div>
    </footer>
</body>
</html>
