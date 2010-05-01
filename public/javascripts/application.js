function initialize() {
    // find flash and hide it after to 10 seconds
    var flash = $('flash');
    if (flash != null) {
        Effect.Fade.delay(5, 'flash');
    }
}

function switchVisibility(div){

    if(navigator.appName == "Microsoft Internet Explorer"){
        if(div.style.display=='none')
            div.style.display='block';
        else
            div.style.display='none';
    }
    else{
        if (div.visible()) {
            div.blindUp();
        } else {
            div.blindDown();
        }
    }
}

function toggleDiv(elementId) {
    var div  = document.getElementById(elementId);
    if(div != null){
      switchVisibility(div);
    }
    return false;
}

function toggleTextAreaDiv(elementId) {
    var element  = document.getElementById(elementId);
    toggleDiv(elementId);
    var areas = element.getElementsByTagName("textarea");
    for(var i=0; i < areas.length; i++){
        switchVisibility(areas[i]);
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

function visible_remove_icon(id, show) {
    document.getElementById(id).style.visibility = show;
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

function resize_frame(id, count)
{
    var frame = parent.document.getElementById(id);
    frame.style.height = (((count) *30) + 80) + "px";
}

Event.observe(window, 'load', initialize);