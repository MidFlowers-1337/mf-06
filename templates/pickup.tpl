<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>取件出库 - 快递驿站</title>
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
        <h2>📤 取件出库</h2>

        % if message:
        <div class="alert alert-info">{{message}}</div>
        % end

        <div class="tabs">
            <label class="tab-item {{'active' if mode=='phone' else ''}}">
                <input type="radio" name="search_mode" value="phone" {{'checked' if mode=='phone' else ''}} onchange="setMode(this)">
                <span>📱 手机尾号</span>
            </label>
            <label class="tab-item {{'active' if mode=='code' else ''}}">
                <input type="radio" name="search_mode" value="code" {{'checked' if mode=='code' else ''}} onchange="setMode(this)">
                <span>🔢 取件码</span>
            </label>
            <label class="tab-item {{'active' if mode=='tracking' else ''}}">
                <input type="radio" name="search_mode" value="tracking" {{'checked' if mode=='tracking' else ''}} onchange="setMode(this)">
                <span>📦 快递单号</span>
            </label>
        </div>

        <form method="POST" action="/pickup/search" class="form">
            <div class="grid-2">
                <div class="form-group">
                    <label id="search_label">请输入手机尾号（4位）</label>
                    <input type="text" name="key" id="key" value="{{search_key}}" required autofocus autocomplete="off" placeholder="如 1234">
                    <input type="hidden" name="mode" id="mode" value="{{mode or 'phone'}}">
                </div>
                <div class="form-group form-actions">
                    <label>&nbsp;</label>
                    <button type="submit" class="btn btn-primary btn-lg">🔍 查找包裹</button>
                </div>
            </div>
        </form>

        % if packages:
        <form method="POST" action="/pickup/verify" class="form mt-30">
            <h3>找到 {{len(packages)}} 个待取包裹，请选择并核验</h3>
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
                            <th>状态</th>
                        </tr>
                    </thead>
                    <tbody>
                        % for p in packages:
                        <tr class="{{'row-overdue' if p['overdue'] else ''}}">
                            <td><input type="checkbox" name="pkg_ids" value="{{p['id']}}" class="pkg-check" checked></td>
                            <td class="mono">{{p['tracking_no']}}</td>
                            <td><span class="badge">{{p['phone_tail']}}</span></td>
                            <td>{{p['company']}}</td>
                            <td><span class="badge badge-code">{{p['pickup_code']}}</span></td>
                            <td><strong>{{p['shelf_no']}}号{{p['shelf_layer']}}层</strong></td>
                            <td>{{p['arrival_date']}}</td>
                            <td>
                                % if p['overdue']:
                                <span class="tag tag-danger">⚠ 超期</span>
                                % else:
                                <span class="tag tag-success">待取</span>
                                % end
                            </td>
                        </tr>
                        % end
                    </tbody>
                </table>
            </div>

            <div class="grid-2 mt-20">
                <div class="form-group">
                    <label>核验方式</label>
                    <select name="verify_mode" id="verify_mode">
                        <option value="phone">核验手机尾号</option>
                        <option value="code">核验取件码</option>
                    </select>
                </div>
                <div class="form-group">
                    <label id="verify_label">请输入手机尾号核验</label>
                    <input type="text" name="verify_key" id="verify_key" required autocomplete="off" placeholder="请输入手机尾号或取件码">
                </div>
            </div>

            <div class="mt-15">
                <button type="submit" class="btn btn-primary btn-lg">✅ 确认取件</button>
                <a href="/pickup/" class="btn btn-default btn-lg">重新搜索</a>
            </div>
        </form>
        % end
    </main>
    <footer class="footer">
        <div class="container">
            <small>快递驿站管理系统</small>
        </div>
    </footer>
    <script src="/static/js/app.js"></script>
    <script>
    function setMode(el) {
        var mode = el.value;
        document.getElementById('mode').value = mode;
        var keyInput = document.getElementById('key');
        var label = document.getElementById('search_label');
        if (mode === 'phone') {
            label.textContent = '请输入手机尾号（4位）';
            keyInput.placeholder = '如 1234';
            keyInput.maxLength = 4;
            keyInput.pattern = '[0-9]{4}';
        } else if (mode === 'code') {
            label.textContent = '请输入6位取件码';
            keyInput.placeholder = '如 123456';
            keyInput.maxLength = 6;
            keyInput.pattern = '[0-9]{6}';
        } else {
            label.textContent = '请输入快递单号';
            keyInput.placeholder = '完整或部分单号';
            keyInput.maxLength = '';
            keyInput.pattern = '';
        }
        keyInput.value = '';
        keyInput.focus();
    }
    function toggleAll(el) {
        document.querySelectorAll('.pkg-check').forEach(function(c) {
            c.checked = el.checked;
        });
    }
    document.getElementById('verify_mode').addEventListener('change', function(e) {
        var label = document.getElementById('verify_label');
        var input = document.getElementById('verify_key');
        if (e.target.value === 'phone') {
            label.textContent = '请输入手机尾号核验';
            input.placeholder = '4位手机尾号';
        } else {
            label.textContent = '请输入取件码核验';
            input.placeholder = '6位取件码';
        }
    });
    </script>
</body>
</html>
