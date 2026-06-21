<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>统计与查件 - 快递驿站</title>
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
                <a href="/shipping/">代发快递</a>
                <a href="/stats" class="active">统计/查件</a>
            </nav>
        </div>
    </header>
    <main class="container main-content">
        <h2>📊 今日统计</h2>
        <div class="grid-3">
            <div class="stat-card stat-arrival">
                <div class="stat-num">{{today_arrived}}</div>
                <div class="stat-label">今日入库</div>
            </div>
            <div class="stat-card stat-pickup">
                <div class="stat-num">{{today_picked}}</div>
                <div class="stat-label">今日出库</div>
            </div>
            <div class="stat-card stat-pending">
                <div class="stat-num">{{pending}}</div>
                <div class="stat-label">库存积压</div>
            </div>
        </div>

        <h3 class="mt-40">🔍 库存包裹（按货架排序，找件不用翻箱倒柜）</h3>

        <div class="form mt-15">
            <div class="grid-3">
                <div class="form-group">
                    <label>搜索单号/尾号/取件码</label>
                    <input type="text" id="search_input" oninput="liveSearch()" placeholder="输入关键字快速查找">
                </div>
                <div class="form-group">
                    <label>按货架号筛选</label>
                    <select id="shelf_filter" onchange="applyFilter()">
                        <option value="">全部货架</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>状态筛选</label>
                    <select id="status_filter" onchange="applyFilter()">
                        <option value="">全部</option>
                        <option value="normal">正常待取</option>
                        <option value="overdue">超期未取</option>
                    </select>
                </div>
            </div>
        </div>

        % if pending_list:
        <div class="table-wrap mt-15">
            <table class="table" id="pkg_table">
                <thead>
                    <tr>
                        <th>单号</th>
                        <th>尾号</th>
                        <th>公司</th>
                        <th>取件码</th>
                        <th>货架位置</th>
                        <th>到件日期</th>
                        <th>存放天数</th>
                        <th>状态</th>
                    </tr>
                </thead>
                <tbody id="pkg_tbody">
                    % for p in pending_list:
                    <tr class="{{'row-overdue' if p['overdue'] else ''}}"
                        data-tracking="{{p['tracking_no']}}"
                        data-phone="{{p['phone_tail']}}"
                        data-code="{{p['pickup_code']}}"
                        data-shelf="{{p['shelf_no']}}"
                        data-status="{{'overdue' if p['overdue'] else 'normal'}}">
                        <td class="mono">{{p['tracking_no']}}</td>
                        <td><span class="badge">{{p['phone_tail']}}</span></td>
                        <td>{{p['company']}}</td>
                        <td><span class="badge badge-code">{{p['pickup_code']}}</span></td>
                        <td><strong style="color:#2980b9;">{{p['shelf_no']}}号{{p['shelf_layer']}}层</strong></td>
                        <td>{{p['arrival_date']}}</td>
                        <td>{{p['days_int']}} 天</td>
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
        % else:
        <div class="empty-box">
            <div class="empty-icon">🎉</div>
            <h3>库存空空如也</h3>
            <p>当前没有积压的待取包裹</p>
        </div>
        % end
    </main>
    <footer class="footer">
        <div class="container">
            <small>快递驿站管理系统</small>
        </div>
    </footer>
    <script>
    (function() {
        var shelves = new Set();
        document.querySelectorAll('[data-shelf]').forEach(function(tr) {
            shelves.add(tr.getAttribute('data-shelf'));
        });
        var sel = document.getElementById('shelf_filter');
        Array.from(shelves).sort(function(a,b){return a-b;}).forEach(function(s) {
            var opt = document.createElement('option');
            opt.value = s; opt.textContent = s + '号货架';
            sel.appendChild(opt);
        });
    })();
    function liveSearch() {
        applyFilter();
    }
    function applyFilter() {
        var q = document.getElementById('search_input').value.trim().toLowerCase();
        var shelf = document.getElementById('shelf_filter').value;
        var status = document.getElementById('status_filter').value;
        document.querySelectorAll('#pkg_tbody tr').forEach(function(tr) {
            var show = true;
            if (q) {
                var t = (tr.getAttribute('data-tracking') + ' ' +
                         tr.getAttribute('data-phone') + ' ' +
                         tr.getAttribute('data-code')).toLowerCase();
                if (t.indexOf(q) === -1) show = false;
            }
            if (shelf && tr.getAttribute('data-shelf') !== shelf) show = false;
            if (status && tr.getAttribute('data-status') !== status) show = false;
            tr.style.display = show ? '' : 'none';
        });
    }
    </script>
</body>
</html>
