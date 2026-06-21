<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>超期提醒 - 快递驿站</title>
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
                <a href="/overdue/" class="active">超期提醒</a>
                <a href="/shipping/">代发快递</a>
                <a href="/stats">统计/查件</a>
            </nav>
        </div>
    </header>
    <main class="container main-content">
        <h2>⏰ 超期提醒</h2>
        <p class="muted">超过 {{OVERDUE_DAYS}} 天未取件的包裹将标记为超期，可一键批量发送取件提醒</p>

        % if message:
        <div class="alert alert-success">{{message}}</div>
        % end

        % if packages:
        <form method="POST" action="/overdue/remind" class="form">
            <div class="mb-15">
                <button type="submit" class="btn btn-danger btn-lg">📨 向选中的发送提醒</button>
                <button type="submit" formaction="/overdue/remind_all" formmethod="POST" class="btn btn-warning btn-lg">📨 全部催取（一键群发）</button>
                <span class="ml-15 muted">共 {{len(packages)}} 个超期包裹</span>
            </div>
            <div class="table-wrap">
                <table class="table table-selectable">
                    <thead>
                        <tr>
                            <th><input type="checkbox" id="select_all" onchange="toggleAll(this)"></th>
                            <th>单号</th>
                            <th>尾号</th>
                            <th>公司</th>
                            <th>取件码</th>
                            <th>货架位置</th>
                            <th>到件日期</th>
                            <th>超期天数</th>
                        </tr>
                    </thead>
                    <tbody>
                        % for p in packages:
                        <tr class="row-overdue">
                            <td><input type="checkbox" name="pkg_ids" value="{{p['id']}}" class="pkg-check" checked></td>
                            <td class="mono">{{p['tracking_no']}}</td>
                            <td><span class="badge">{{p['phone_tail']}}</span></td>
                            <td>{{p['company']}}</td>
                            <td><span class="badge badge-code">{{p['pickup_code']}}</span></td>
                            <td><strong>{{p['shelf_no']}}号{{p['shelf_layer']}}层</strong></td>
                            <td>{{p['arrival_date']}}</td>
                            <td><span class="tag tag-danger">{{p['overdue_days']}} 天</span></td>
                        </tr>
                        % end
                    </tbody>
                </table>
            </div>
        </form>
        % else:
        <div class="empty-box">
            <div class="empty-icon">🎉</div>
            <h3>太棒了！</h3>
            <p>当前没有超期未取的包裹</p>
        </div>
        % end
    </main>
    <footer class="footer">
        <div class="container">
            <small>快递驿站管理系统</small>
        </div>
    </footer>
    <script>
    function toggleAll(el) {
        document.querySelectorAll('.pkg-check').forEach(function(c) {
            c.checked = el.checked;
        });
    }
    </script>
</body>
</html>
