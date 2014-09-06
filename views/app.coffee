Leap?.loop (frame)->
  html = 'Leap:<ul>'

  nearest = undefined
  frame.fingers.forEach (finger)->
    html += "<li>#{finger.type}: "
    html += "#{finger.tipPosition[0]}, #{finger.tipPosition[1]}, #{finger.tipPosition[2]}"

    if !nearest? || nearest?.tipPosition[2] > finger.tipPosition[2]
      nearest = finger

  if nearest?
    tip.moveTo nearest.screenPosition()
      .show()
  else
    tip.hide()

  $('#leap-info').html html

.use 'screenPosition'

EyeTribe?.loop (frame)->
  if frame.state & EyeTribe.GazeData.STATE_TRACKING_EYES
    clientPosition = frame.smoothedCoordinates.toClient()
    console.log frame.smoothedCoordinates, clientPosition

    gaze.moveTo clientPosition
      .show()

    $('#panel .button').each ->
        if clientPosition.inbounds @getBoundingClientRect()
          $(@).addClass 'focus'
        else
          $(@).removeClass 'focus'
  else
    gaze.hide()

Point = EyeTribe?.Point2D

Point?.origin = new Point window.screenX, window.screenY

Point?.prototype.toClient = ()->
  @subtract Point.origin

Point?.prototype.toScreen = ()->
  @add Point.origin

Point?.prototype.inbounds = (rect)->
  x = rect.x || rect.left
  y = rect.y || rect.top
  @x >= x &&
    @x <= x + rect.width &&
    @y >= y &&
    @y <= y + rect.height

document.onmousemove = (event)->
  clientLeft = event.screenX - event.clientX
  clientTop = event.screenY - event.clientY
  Point?.origin = new Point clientLeft, clientTop


class Cursor
  constructor: (@id)->
    @element = $("<div id=#{id} class=cursor>")
      .css
        position: 'absolute'
    $('body').append @element

    $('#debug').append @info = $("<div id=#{id}-info>")

  moveTo: (position)->
    if Array.isArray position
      [x, y] = position
    else
      {x, y} = position
    @info.html "#{@id}:<br>#{x}, #{y}"
    @element.css
      left: x
      top: y
    @

  show: ->
    @element.show()
    @

  hide: ->
    @element.hide()
    @

gaze = new Cursor 'gaze'
tip = new Cursor 'tip'
