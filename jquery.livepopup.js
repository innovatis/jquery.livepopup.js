(function($){

  function postHandler(data, button){
    var popupContent = data,
      popup           = button.data("popupElement"),
      shouldCacheAjax = button.is('[data-cache-ajax]');

    if(! popup){
      popup = $(popupContent).hide();
      popup.insertAfter(button);
      button.data( "popupElement", popup );
    }
    togglePopup(popup, button);
  }

  function togglePopup(popup, button){
    var closesOnClick = popup.is('[data-close-on-click]'),
      closesOnClickSelector = popup.data('closeOnClick'),
      closesOnExternalClick = popup.is('[data-close-on-external-click]');

    //this one needs to get rebound every time
    if(closesOnExternalClick){
      $("body").one('click', function(e){
        console.log("Body clicked");
        console.log("e.target", e.target);
        window.popup = popup;
        window.target = e.target;
        if( popup.find($(e.target)).length === 0){
          popup.hide();
        }
      });
    }

    if( button.data('popup') !== 'initialized'){
      button.data('popup', 'initialized');

      button.exoPositionRelative(popup);

      if(closesOnClick){
        if(closesOnClickSelector){
          popup
            .find(closesOnClickSelector)
            .click(function(){
              popup.toggle();
          });
        } else {
          popup.click(function(){
            popup.toggle();
          });
        }
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
      childTop   = child.data("popupTop"),
      childLeft  = child.data("popupLeft"),
      offsetTop  = childTop  || options.top  || 0,
      offsetLeft = childLeft || options.left || 0;


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
  $("[data-popup-trigger]").exoPopup();
});

