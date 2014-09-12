class @Panel
  show: ->
    $('#message').text @message
    do @panel.show
    @

  hide: ->
    do @panel.hide
    @

  @appendTo: (parent)->
    new @ parent
