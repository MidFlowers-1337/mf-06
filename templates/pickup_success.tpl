<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>取件成功 - 快递驿站</title>
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
    <header class="topbar">
        <div class="container">
            <a href="/" class="logo">📦 快递驿站</a>
            <nav>
                <a href="/">首页</a>
                <a href="/arrival/">到件登记</a>
                <a href="/pickup/" class="active">取件出库</a>
                <a href="/overdue/">超期提醒</a>
                <a href="/shipping/">代发快递</a>
                <a href="/stats">统计/查件</a>
            </nav>
        </div>
    </header>
    <main class="container main-content">
        <div class="success-box">
            <div class="success-icon">✅</div>
            <h2>取件成功！</h2>
            <p>已成功出库 {{count}} 个包裹</p>
        </div>

        <div class="table-wrap mt-30">
            <table class="table">
                <thead>
                    <tr>
                        <th>单号</th>
                        <th>尾号</th>
                        <th>公司</th>
                        <th>货架</th>
                        <th>出库时间</th>
                    </tr>
                </thead>
                <tbody>
                    % from datetime import datetime
                    % now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                    % for p in packages:
                    <tr>
                        <td class="mono">{{p['tracking_no']}}</td>
                        <td><span class="badge">{{p['phone_tail']}}</span></td>
                        <td>{{p['company']}}</td>
                        <td>{{p['shelf_no']}}号{{p['shelf_layer']}}层</td>
                        <td class="muted">{{now}}</td>
                    </tr>
                    % end
                </tbody>
            </table>
        </div>

        <div class="mt-30">
            <a href="/pickup/" class="btn btn-primary btn-lg">继续取件</a>
            <a href="/" class="btn btn-default btn-lg">返回首页</a>
        </div>
    </main>
    <footer class="footer">
        <div class="container">
            <small>快递驿站管理系统</small>
        </div>
    </footer>
</body>
</html>
