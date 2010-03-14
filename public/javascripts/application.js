function initialize() {
    // find flash and hide it after to 10 seconds
    var flash = $('flash');
    if (flash != null) {
        Effect.Fade.delay(5, 'flash');
    }
}

function toggleDiv(event) {
    var div = $(Event.element(event).parentNode).next();
    if (div.visible()) {
        div.blindUp();
    } else {
        div.blindDown();
    }
    return false;
}


function toggleDivDiv(event) {
    var div = $(Event.element(event).parentNode.parentNode).next();
    if (div.visible()) {
        div.blindUp();
    } else {
        div.blindDown();
    }
    return false;
}

function toggleTreeElement(Li, evt, child) {

    child = (typeof child == 'undefined') ? 1 : child;


    if (evt.stopPropagation) {
        evt.stopPropagation();
    }
    evt.cancelBubble = true;

    if (Li.className == "Expanded") {
        Li.className = "Collapsed";
    } else {
        Li.className = "Expanded";
    }
    Element.toggle(Li.children[child]);
}

function link_visible(element, show) {
    element.children[0].style.display = show;
}

function visible_remove_favorite(element, show) {
    element.children[1].firstChild.style.visibility = show;
}

Event.observe(window, 'load', initialize);