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

function visible_remove_icon(element, show, child) {
    element.children[child].firstChild.style.visibility = show;
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