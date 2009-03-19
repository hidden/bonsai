function initialize() {
    // find flash and hide it after to 10 seconds
    var flash = $('flash');
    if(flash != null) {
        Effect.Fade.delay(5, 'flash');
    }
}

function toggleDiv(event) {
    var div = $(Event.element(event)).parentNode.next();
    if (div.visible()) {
        div.blindUp();
    } else {
        div.blindDown();
    }
    return false;
}

Event.observe(window, 'load', initialize);