App.onLaunch = function(options) {
    var mainURL = 'http://localhost:9001/main.tvml';
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.responseType = "document";
    xmlhttp.onload = function () {
        navigationDocument.pushDocument(xmlhttp.responseXML);
    };
    xmlhttp.open("GET", mainURL, true);
    xmlhttp.send();
}

App.onExit = function() {
    console.log('App finished');
}