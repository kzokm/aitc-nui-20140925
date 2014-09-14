class @Panel

  onCreate: ->

  onResume: ->
    $('#message').text @message

  trigger: ->
    @panel.triggerHandler.apply @panel, arguments

  show: ->
    do @panel.show
    do @onResume
    @

  hide: ->
    do @panel.hide
    @

  @appendTo: (parent)->
    self = new @ parent
    do self.onCreate
    self
