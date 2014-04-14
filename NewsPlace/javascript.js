(function () {
    var items = document.getElementsByTagName('*');
    for (var i = items.length; i--;) {
        var item = items[i];
        item.className = '';
    }
}());