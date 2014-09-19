class @MainPane
  constructor: (element)->
    @element = $(element).addClass 'pane'
    panes.push panes.current = @

  onResume: ->
    $('#main-message').text @message

  show: ->
    panes.current = @
    do @onResume
    do @element.show
    @

  hide: ->
    do @element.hide
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
    trigger: (type, data)->
      panes.current?.trigger type, data
  }


$.fn.isVisible ?= -> $.expr.filters.visible @[0]
