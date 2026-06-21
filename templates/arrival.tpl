<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>到件登记 - 快递驿站</title>
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
    <header class="topbar">
        <div class="container">
            <a href="/" class="logo">📦 快递驿站</a>
            <nav>
                <a href="/">首页</a>
                <a href="/arrival/" class="active">到件登记</a>
                <a href="/pickup/">取件出库</a>
                <a href="/overdue/">超期提醒</a>
                <a href="/shipping/">代发快递</a>
                <a href="/stats">统计/查件</a>
            </nav>
        </div>
    </header>
    <main class="container main-content">
        <h2>📥 到件登记</h2>

        % if message:
        <div class="alert alert-success">{{message}}</div>
        % end

        <form method="POST" action="/arrival/add" class="form">
            <div class="grid-3">
                <div class="form-group">
                    <label>快递单号 *</label>
                    <input type="text" name="tracking_no" id="tracking_no" required autofocus autocomplete="off" placeholder="扫描或输入单号">
                </div>
                <div class="form-group">
                    <label>收件人手机尾号 *</label>
                    <input type="text" name="phone_tail" required maxlength="4" pattern="[0-9]{4}" placeholder="如 1234">
                </div>
                <div class="form-group">
                    <label>快递公司 *</label>
                    <select name="company" required>
                        <option value="">请选择</option>
                        % for c in companies:
                        <option value="{{c}}">{{c}}</option>
                        % end
                    </select>
                </div>
            </div>
            <div class="grid-3 mt-15">
                <div class="form-group">
                    <label>到件日期 *</label>
                    <input type="date" name="arrival_date" value="{{today}}" required>
                </div>
                <div class="form-group">
                    <label>货架号 *</label>
                    <input type="number" name="shelf_no" required min="1" placeholder="如 1">
                </div>
                <div class="form-group">
                    <label>货架层 *</label>
                    <select name="shelf_layer" required>
                        <option value="">请选择</option>
                        <option value="1">第1层</option>
                        <option value="2">第2层</option>
                        <option value="3">第3层</option>
                        <option value="4">第4层</option>
                        <option value="5">第5层</option>
                        <option value="底层">底层</option>
                        <option value="顶层">顶层</option>
                    </select>
                </div>
            </div>
            <div class="mt-20">
                <button type="submit" class="btn btn-primary btn-lg">📥 入库登记</button>
                <button type="reset" class="btn btn-default btn-lg">重置</button>
            </div>
        </form>

        <h3 class="mt-40">今日入库记录（最近20条）</h3>
        % if recent:
        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>单号</th>
                        <th>尾号</th>
                        <th>公司</th>
                        <th>取件码</th>
                        <th>货架</th>
                        <th>入库时间</th>
                    </tr>
                </thead>
                <tbody>
                    % for p in recent:
                    <tr>
                        <td class="mono">{{p['tracking_no']}}</td>
                        <td><span class="badge">{{p['phone_tail']}}</span></td>
                        <td>{{p['company']}}</td>
                        <td><span class="badge badge-code">{{p['pickup_code']}}</span></td>
                        <td>{{p['shelf_no']}}号{{p['shelf_layer']}}层</td>
                        <td class="muted">{{p['created_at']}}</td>
                    </tr>
                    % end
                </tbody>
            </table>
        </div>
        % else:
        <p class="muted">暂无今日入库记录</p>
        % end
    </main>
    <footer class="footer">
        <div class="container">
            <small>快递驿站管理系统</small>
        </div>
    </footer>
    <script src="/static/js/app.js"></script>
</body>
</html>
