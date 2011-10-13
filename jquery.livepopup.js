(function($){

  function postHandler(data, button){
      // var popupContent = data.html;
      var popupContent = "<p>Text echoed back to request</p>",
          popup        = button.data("popupElement"),
          shouldCacheAjax = button.is('[data-cache-ajax]');

        if(! popup){
           popup = $("<div class='exo-popup'" + popupContent + "</div>").hide().appendTo("body");
           button.data( "popupElement", popup );
        }
        togglePopup(popup, button);
    }

    function togglePopup(popup, button){
      var closesOnClick = button.is("[data-close-on-click]");
        if( button.data('popup') !== 'initialized'){
        button.data('popup', 'initialized');

       if(closesOnClick){
          popup.click( function(){
            popup.toggle();
          });
        }
      }
      popup.toggle();
    }


  function actsAsPopup(e){
    e.preventDefault();
    var button    = $(e.target),
        href      = button.attr("href"),
        element   = button.data('popupElement'),
        isAjax    = (href[0] !== "#"),
        ajaxIsntCached     = !element,
        ajaxIsCacheable    = button.is("[data-cache-ajax]"),
        shouldMakeAjaxCall = (ajaxIsntCached || !ajaxIsCacheable);

    if(! href){
      throw("[actsAsPopup]: href is empty");
    }

    if(isAjax && shouldMakeAjaxCall ){
      //there is no ajax server in testing
      //$.post(href, {html: "<p>test</p>"}, function(data){
      //  postHandler(data, button);
      //});
      postHandler("jakhdfjkads", button);
    } else {
      var popup = element || $(href);
      togglePopup(popup, button);
    }
  }

  $.fn.exoPopup = function(){
    this.live('click', actsAsPopup);
  };

})(jQuery);

$(function(){
  $("[data-popup]").exoPopup();
});

