function initialize() {
    // find flash and hide it after to 10 seconds
    var flash = $('flash');
    if(flash != null) {
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

function toggleTreeElement(Li,UI){
  Li.className= Li.className=="Expanded"? "Collapsed":"Expanded";
  Element.toggle(UI);
}

Event.observe(window, 'load', initialize);