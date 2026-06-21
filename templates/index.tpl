<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>快递驿站管理系统</title>
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
    <header class="topbar">
        <div class="container">
            <a href="/" class="logo">📦 快递驿站</a>
            <nav>
                <a href="/" class="active">首页</a>
                <a href="/arrival/">到件登记</a>
                <a href="/pickup/">取件出库</a>
                <a href="/overdue/">超期提醒</a>
                <a href="/shipping/">代发快递</a>
                <a href="/stats">统计/查件</a>
            </nav>
        </div>
    </header>
    <main class="container main-content">
        <div class="hero">
            <h1>欢迎使用快递驿站管理系统</h1>
            <p>到件登记、取件核验、超期提醒、代发打单，一站搞定</p>
        </div>
        <div class="grid-4">
            <a class="card-link" href="/arrival/">
                <div class="card card-arrival">
                    <div class="card-icon">📥</div>
                    <h3>到件登记</h3>
                    <p>扫描单号，录入货架位置</p>
                </div>
            </a>
            <a class="card-link" href="/pickup/">
                <div class="card card-pickup">
                    <div class="card-icon">📤</div>
                    <h3>取件出库</h3>
                    <p>手机尾号/取件码快速取件</p>
                </div>
            </a>
            <a class="card-link" href="/overdue/">
                <div class="card card-overdue">
                    <div class="card-icon">⏰</div>
                    <h3>超期提醒</h3>
                    <p>一键批量催取，减少积压</p>
                </div>
            </a>
            <a class="card-link" href="/shipping/">
                <div class="card card-shipping">
                    <div class="card-icon">🚚</div>
                    <h3>代发快递</h3>
                    <p>自动算运费，打印面单</p>
                </div>
            </a>
        </div>
        <div class="grid-2 mt-30">
            <a class="card-link" href="/stats">
                <div class="card card-stats">
                    <div class="card-icon">📊</div>
                    <h3>今日统计 & 货架查询</h3>
                    <p>查看代收、取走、积压数量，查找包裹位置</p>
                </div>
            </a>
            <a class="card-link" href="/shipping/history">
                <div class="card card-history">
                    <div class="card-icon">📋</div>
                    <h3>代发历史</h3>
                    <p>查看今日代发记录</p>
                </div>
            </a>
        </div>
    </main>
    <footer class="footer">
        <div class="container">
            <small>快递驿站管理系统 · Python + Bottle + SQLite</small>
        </div>
    </footer>
    <script src="/static/js/app.js"></script>
</body>
</html>
