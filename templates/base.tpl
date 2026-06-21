<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{title or '快递驿站管理系统'}}</title>
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
    <header class="topbar">
        <div class="container">
            <a href="/" class="logo">📦 快递驿站</a>
            <nav>
                <a href="/" class="{{'active' if request.path == '/' else ''}}">首页</a>
                <a href="/arrival/" class="{{'active' if request.path.startswith('/arrival') else ''}}">到件登记</a>
                <a href="/pickup/" class="{{'active' if request.path.startswith('/pickup') else ''}}">取件出库</a>
                <a href="/overdue/" class="{{'active' if request.path.startswith('/overdue') else ''}}">超期提醒</a>
                <a href="/shipping/" class="{{'active' if request.path.startswith('/shipping') else ''}}">代发快递</a>
                <a href="/stats" class="{{'active' if request.path == '/stats' else ''}}">统计/查件</a>
            </nav>
        </div>
    </header>
    <main class="container main-content">
        !{{!base or ''}}
    </main>
    <footer class="footer">
        <div class="container">
            <small>快递驿站管理系统 · Python + Bottle + SQLite</small>
        </div>
    </footer>
    <script src="/static/js/app.js"></script>
</body>
</html>
