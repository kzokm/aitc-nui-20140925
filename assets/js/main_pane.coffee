class @MainPane

  constructor: (element)->
    @element = $(element).addClass 'pane'
    panes.push @

  onResume: ->
    $('#message').text @message

  show: ->
    panes.current = @
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
    $('#main-prev').text @prev()?.name || ''
    $('#main-next').text @next()?.name || ''

  $.main = (command)->
    switch command
      when 'prev'
        panes.set panes.prev()
      when 'next'
        panes.set panes.next()
