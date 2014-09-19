class @MainPane
  constructor: (element)->
    @element = $(element).addClass 'pane'
    panes.push panes.current = @

  onResume: ->
    $('#main-header').text @header
    $.tooltip.hide()

  show: (overlay)->
    if overlay?
      do @suspend
      overlay.show()
        .addClass 'overlay'
      $('#main-header').text overlay.header ? ''
      overlay.demo?()
    else
      do @resume

  hide: ->
    do @suspend

  resume: ->
    panes.current = @
    do @onResume
    do @element.show
    do $('#main-controller').show
    @
    $('.overlay').hide()

  suspend: ->
    do @element.hide
    do $('#main-controller').hide
    @

  trigger: (type, data)->
    if @element.isVisible()
      @element.triggerHandler type, data

  panes = []

  panes.prev = ->
    @[((@indexOf @current) - 1 + @length) % @length]

  panes.next = ->
    @[((@indexOf @current) + 1) % @length]

  panes.set = (@current)->
    @forEach (p)-> p?.hide()
    @current?.show()
    $('#main-prev').text @prev()?.name || ''
    $('#main-next').text @next()?.name || ''

  $.main = {
    prev: ->
      panes.set panes.prev()
    next: ->
      panes.set panes.next()
    show: (overlay)->
      panes.current?.show overlay
    resume: ->
      panes.current?.resume()
    trigger: (type, data)->
      panes.current?.trigger type, data
  }
