$.panel = class @Panel

  constructor: (parent)->
    panes.push @
    @element = @appendTo parent
    do @onCreate
    $.panel = @

  onCreate: ->

  onResume: ->
    $('#message').text @message

  show: ->
    $.panel = panes.current = @
    do @onResume
    do @element.show
    @

  hide: ->
    do @element.hide
    @

  trigger: ->
    @element.triggerHandler.apply @element, arguments


  panes = []

  panes.prev = ->
    @[((@indexOf @current) - 1 + @length) % @length]

  panes.next = ->
    @[((@indexOf @current) + 1) % @length]

  panes.set = (@current)->
    @forEach (p)-> p?.hide()
    @current?.show()
    $('#prev').text @prev()?.name || ''
    $('#next').text @next()?.name || ''

  showNext: ->
    panes.set panes.next()

  showPrev: ->
    panes.set panes.prev()


  @appendTo: (parent)->
    new @ parent
