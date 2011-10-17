(function($){

  function postHandler(data, button){
    var popupContent = data,
      popup           = button.data("popupElement"),
      shouldCacheAjax = button.is('[data-cache-ajax]');

    if(! popup){
      popup = $("<div class='exo-popup'>" + popupContent + "</div>").hide();
      popup.insertAfter(button);
      button.data( "popupElement", popup );
    }
    togglePopup(popup, button);
  }

  function togglePopup(popup, button){
    var closesOnClick = button.is("[data-close-on-click]");
    if( button.data('popup') !== 'initialized'){
      button.data('popup', 'initialized');

      button.exoPositionRelative(popup, {top: 20});


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
      $.get(href, function(data){
        postHandler(data, button);
      });
    } else {
      var popup = element || $(href);
      togglePopup(popup, button);
    }
  }

  $.fn.exoPopup = function(){
    this.live('click', actsAsPopup);

  };


  $.fn.exoPositionRelative = function(child, opts){
    var parent   = this,
      options    = opts || {},
      offsetTop  = options.top  || 0,
      offsetLeft = options.left || 0;


    $(window).resize( function(e){
      var offset = parent.offset(),
        top    = offset.top + offsetTop,
        left   = offset.left + offsetLeft;

      child.css({left: left, top: top });
    });

    $(window).trigger('resize');
  };

})(jQuery);

$(function(){
  $("[data-popup]").exoPopup();
});

