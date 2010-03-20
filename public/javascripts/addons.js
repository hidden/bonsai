/* function to remove error notification message */ 
function removeNotice(el){
  var closeLink = el;
  var noticeBox = closeLink.parentNode;
  noticeBox.removeChild(closeLink);
  noticeBox.parentNode.removeChild(noticeBox);
}

/*function to set up width of main_content element, because of problem with textarea width */ 
function setContentWidth(){
  var w = document.body.clientWidth;
  var wr = document.getElementsByClassName('main_content_right');
  if(wr != null){
      var new_width = (w - parseInt(wr[0].style.width));
      var mycont = document.getElementsByClassName('main_content');
      if(mycont != null){
        mycont[0].style.width = (new_width-170)+"px";
        mycont[0].style.float ="left";
      }
  }
}
