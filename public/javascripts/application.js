function initialize() {
    // find flash and hide it after to 10 seconds
    var flash = $('flash');
    if (flash != null) {
        Effect.Fade.delay(5, 'flash');
    }
}

function toggleDiv(elementId) {
    var div  = document.getElementById(elementId);
    if(div != null){
        if (div.visible()) {
            div.blindUp();
        } else {
            div.blindDown();
        }
    }
    return false;
}

function toggleTreeElement(Li, evt, id) {

    if (evt.stopPropagation) {
        evt.stopPropagation();
    }
    evt.cancelBubble = true;

    if (Li.className == "Expanded") {
        Li.className = "Collapsed";
    } else {
        Li.className = "Expanded";
    }
    childs = Li.childElements();
    for (var i = 0; i < childs.length; i++) {
        if (childs[i].id == id) {
            Element.toggle(childs[i]);
            return;
        }
    }
}

//function link_visible(element, show) {
//    element.children[0].style.display = show;
//}

function visible_remove_icon(id, show) {
    document.getElementById(id).style.visibility = show;
}

function enable_js(id1, id2) {
    document.getElementById(id1).style.display = "none";
    document.getElementById(id2).style.display = "inline";
}

function subm(id,type)
{
    var form = document.getElementById(id);
    if (type == 'preview')
    {
        form.target = "preview";
    }
    else
    {
        form.target = "_self";
    }
}

Event.observe(window, 'load', initialize);