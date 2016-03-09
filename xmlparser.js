var URL = "http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml";
// https://gist.github.com/kovrov/3544715

function showRequestInfo(text) {
    //    log.text = log.text + "\n" + text
    console.log(text)
}

function getElementsByTagName(rootElement, tagName) {
    var childNodes = rootElement.childNodes;
    var elements = [];
    for(var i = 0; i < childNodes.length; i++) {
        if(childNodes[i].tagName === tagName) {
            elements.push(childNodes[i]);
        }
    }
    return elements;
}

function startParse(callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
        } else if (xhr.readyState == XMLHttpRequest.DONE) {
            var doc = xhr.responseXML.documentElement;
            showRequestInfo("xhr length: " + doc.childNodes.length );

            for (var i = 0; i < doc.childNodes.length; ++i) {
                var child = doc.childNodes[i];

                for (var j = 0; j < child.childNodes.length; ++j) {
                    if ( child.nodeName ===  "Cube") {

                        var kid = child.childNodes[j];
                        var length = kid.childNodes.length;

                        for ( var k = 0; k < length; k ++) {
                            var cube = kid.childNodes[k];

                            if ( cube.nodeName === "Cube") {
                                var len = cube.attributes.length;
                                var currency = cube.attributes[0].nodeValue;
                                var rate = cube.attributes[1].nodeValue;
                                currencies.append({"currency": currency, "rate": parseFloat(rate)})
                                callback.update();
                            }
                        }
                    }

                }
            }
        }
    }

    xhr.open("GET", URL);
    xhr.send();
}
