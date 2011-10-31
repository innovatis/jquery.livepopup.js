(($) ->

  postHandler = (data, button) ->
    popupContent    = data
    popup           = button.data('popupElement')
    shouldCacheAjax = button.is('[data-cache-ajax]')
    wrapperClass    = button.data('wrapperClass')

    unless popup
      popup = $(popupContent)  #.hide()
      #wrap popup in .exo-popup if it isn't already
      unless popup.is('.exo-popup')
        # have to do it this way because popup.wrap() does not return a reference to the wrapping html
        # and since this isn't written to the dom yet, wrap() ends up doing nothing
        popup = $("<div class='exo-popup'></div>").html(popup)

      popup.hide()
      popup.addClass(wrapperClass) if wrapperClass
      popup.insertAfter(button)
      button.data( 'popupElement', popup )

      #trigger event hook on button
      button.trigger( $.Event("popup:ajaxLoaded"), [popup])

    togglePopup(popup, button)



  togglePopup = (popup, button) ->
    closesOnClick = popup.is('[data-close-on-click]')                  or button.is('[data-close-on-click]')
    closesOnClickSelector = popup.data('closeOnClick')                 or button.data('closeOnClick')
    closesOnExternalClick = popup.is('[data-close-on-external-click]') or button.is('[data-close-on-external-click]')


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
            .click (e) ->
              e.preventDefault()
              popup.toggle()
        else
          popup.click -> popup.toggle()
    popup.toggle()

  actsAsPopup = (e) ->
    e.preventDefault()
    button    = $(e.target)
    href      = button.attr('href') or button.data('href')
    element   = button.data('popupElement')
    isAjax    = (href[0] isnt '#')
    ajaxIsntCached     = !element
    ajaxIsCacheable    = button.is('[data-cache-ajax]')
    shouldMakeAjaxCall = (ajaxIsntCached or !ajaxIsCacheable)

    unless href
      throw '[actsAsPopup]: href is empty'

    if isAjax and shouldMakeAjaxCall
      ajaxSpinner = $("<div class='spinner'></div>")
      button.after(ajaxSpinner)
      button.exoPositionRelative(ajaxSpinner, {left: 10, top: "none"})
      $.get href, (data) ->
        ajaxSpinner.remove()
        postHandler(data, button)
    else
      popup = element or $(href)
      togglePopup(popup, button)

  $.fn.exoPopup = -> this.live('click', actsAsPopup)
  $.fn.exoPositionRelative = (child, opts) ->
    parent     = this
    options    = opts or {}
    topFromParent   = child.data('popupTop')  or parent.data( 'popupTop'  )
    leftFromParent  = child.data('popupLeft') or parent.data( 'popupLeft' )
    offsetTop  = options.top  or topFromParent  or 0
    offsetLeft = options.left or leftFromParent or 0

    offsetTop  = 0 if options.top  is "none"
    offsetLeft = 0 if options.left is "none"

    $(window).resize (e) ->
      offset = parent.offset()
      top    = offset.top + offsetTop
      left   = offset.left + offsetLeft
      child.css
        left: left
        top: top

    $(window).trigger('resize')

  $ ->
    $('[data-popup-trigger]').exoPopup()
)(jQuery)
