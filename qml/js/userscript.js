// Catch window open events as normal links
window.open = function (url, windowName, windowFeatures) {
    var link = new Object({'type':'link', 'target':'_blank', 'href':url});
    navigator.qt.postMessage( JSON.stringify(link) );
}
