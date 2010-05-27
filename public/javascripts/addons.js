/* function to remove error notification message */
function removeNotice(el) {
    var closeLink = el;
    var noticeBox = closeLink.parentNode;
    noticeBox.removeChild(closeLink);
    noticeBox.parentNode.removeChild(noticeBox);
}

function hide_elements_by_name(name) {
    var links = document.getElementsByName(name);
    var len = links.length;
    for (i = 0; i < len; i++) {
        links[i].style.visibility = "hidden";
    }
}

function bielik_menu() {
    var current_url = location.href;

    if (current_url.indexOf('#') != -1)
        current_url = current_url.substr(0, current_url.indexOf('#'));

    if (current_url.indexOf(';') != -1)
        current_url = current_url.substr(0, current_url.indexOf(';'));

    var menu = document.getElementById("bielik-nav");
    if (menu != null) {

        var links = menu.getElementsByTagName('a');
        if (links != null) {
            for (i = 0; i < links.length; i++)
                if (links[i].getAttribute("href") == current_url)
                    links[i].setAttribute("class", "bielik-hover");
        }
    }

}
