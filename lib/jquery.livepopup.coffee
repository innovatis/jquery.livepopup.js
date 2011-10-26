(($) ->

  postHandler = (data, button) ->
    popupContent = data
    popup           = button.data('popupElement')
    shouldCacheAjax = button.is('[data-cache-ajax]')

    unless popup
      popup = $(popupContent).hide()
      popup.insertAfter(button)
      button.data( 'popupElement', popup )
    togglePopup(popup, button)

  togglePopup = (popup, button) ->
    closesOnClick = popup.is('[data-close-on-click]')
    closesOnClickSelector = popup.data('closeOnClick')
    closesOnExternalClick = popup.is('[data-close-on-external-click]')


    #this one needs to get rebound every time
    if closesOnExternalClick
      $('body').one 'click', (e) ->
        if popup.find($(e.target)).length is 0
          popup.hide()

    if  button.data('popup') isnt 'initialized'
      button.data('popup', 'initialized')

      button.exoPositionRelative(popup)

      if closesOnClick
        if closesOnClickSelector
          popup
            .find(closesOnClickSelector)
            .click -> popup.toggle()
        else
          popup.click -> popup.toggle()
    popup.toggle()

  actsAsPopup = (e) ->
    e.preventDefault()
    button    = $(e.target)
    href      = button.attr('href')
    element   = button.data('popupElement')
    isAjax    = (href[0] isnt '#')
    ajaxIsntCached     = !element
    ajaxIsCacheable    = button.is('[data-cache-ajax]')
    shouldMakeAjaxCall = (ajaxIsntCached or !ajaxIsCacheable)

    unless href
      throw '[actsAsPopup]: href is empty'

    if isAjax and shouldMakeAjaxCall
      $.get href, (data) -> postHandler(data, button)
    else
      popup = element or $(href)
      togglePopup(popup, button)

  $.fn.exoPopup = -> this.live('click', actsAsPopup)
  $.fn.exoPositionRelative = (child, opts) ->
    parent     = this
    options    = opts || {}
    childTop   = child.data('popupTop')
    childLeft  = child.data('popupLeft')
    offsetTop  = childTop  || options.top  || 0
    offsetLeft = childLeft || options.left || 0

    $(window).resize (e) ->
      offset = parent.offset()
      top    = offset.top + offsetTop
      left   = offset.left + offsetLeft

      child.css
        left: left
        top: top

    $(window).trigger('resize')

  $ -> $('[data-popup-trigger]').exoPopup()

)(jQuery)
