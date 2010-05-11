/* function to remove error notification message */ 
function removeNotice(el){
  var closeLink = el;
  var noticeBox = closeLink.parentNode;
  noticeBox.removeChild(closeLink);
  noticeBox.parentNode.removeChild(noticeBox);
}

function hide_elements_by_name(name){
    var links = document.getElementsByName(name);
    var len = links.length;
    for(i=0; i<len; i++){
        links[i].style.visibility = "hidden";
    }
}
