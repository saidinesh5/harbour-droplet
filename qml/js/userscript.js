// Catch window open events as normal links
window.open = function (url, windowName, windowFeatures) {
    var link = new Object({'type':'link', 'target':'_blank', 'href':url});
    navigator.qt.postMessage( JSON.stringify(link) );
}

document.documentElement.addEventListener('click', (function(e) {
    var node = e.target;
    while(node) {
        if (node.tagName === 'A') {
            var link = new Object({'type':'link', 'pageX': e.pageX, 'pageY': e.pageY})
            if (node.hasAttribute('target'))
                link.target = node.getAttribute('target');
            link.href = node.href //node.getAttribute('href'); // We want always the absolute link
            navigator.qt.postMessage( JSON.stringify(link) );
        }
        node = node.parentNode;
    }
}), true);
