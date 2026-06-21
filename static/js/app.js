(function() {
    document.addEventListener('keydown', function(e) {
        if (e.target.tagName === 'INPUT' && e.key === 'Enter' && e.target.form) {
            var type = e.target.type;
            if (type === 'text' || type === 'number' || type === 'date') {
            }
        }
    });
})();
