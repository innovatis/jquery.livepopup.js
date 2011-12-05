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

  togglePopup = (popup, button, teardown) ->
    closesOnClick = popup.is('[data-close-on-click]')                  or button.is('[data-close-on-click]')
    closesOnClickSelector = popup.data('closeOnClick')                 or button.data('closeOnClick')
    closesOnExternalClick = popup.is('[data-close-on-external-click]') or button.is('[data-close-on-external-click]')
    href   = button.attr('href') or button.data('href')
    isNotAjax = (href[0] is '#')
    teardown = teardown or false

    if isNotAjax #then we do setup/teardown every time
      if teardown or button.data('popup') is 'initialized'
        button.data('popup', '')
        popup.data('position-object').disable()
        popup.hide()

      else #if popup is not initialized
        #these ones need to get rebound every time
        if closesOnExternalClick
          $('body').one 'click', (e) ->
            if popup.find($(e.target)).length is 0
              togglePopup(popup, button, true)

        #do this one always
        $('body').one 'keydown', (e) ->
          if e.keyCode is 27 #code for escape
            togglePopup(popup, button, true)

        button.data('popup', 'initialized')
        button.positionRelative(popup)

        if closesOnClick
          if closesOnClickSelector
            popup
              .find(closesOnClickSelector)
              .one 'click', (e) ->
                e.preventDefault()
                togglePopup(popup, button, true)
          else
            popup.one 'click', -> togglePopup(popup, button, true)
        popup.show();



    else #handle the ajax popup just the same as we always did

      #these ones need to get rebound every time
      if closesOnExternalClick
        $('body').one 'click', (e) ->
          if popup.find($(e.target)).length is 0
            popup.hide()

      #do this one always
      $('body').one 'keydown', (e) ->
        if e.keyCode is 27 #code for escape
          popup.hide()

      if button.data('popup') isnt 'initialized'
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
    button    = $(this)
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
      $.get(href, (data) ->
        ajaxSpinner.remove()
        postHandler(data, button)
      ).error( ->
        ajaxSpinner.remove()
        alert("There was an error retrieving the popup")
      )
    else
      popup = element or $(href)
      togglePopup(popup, button)

  $.fn.exoPopup = -> this.live('click', actsAsPopup)
  $ -> $('[data-popup-trigger]').exoPopup()
)(jQuery)
