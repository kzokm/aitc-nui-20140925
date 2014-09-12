Leap?.loop (frame)->
  html = 'Leap:<ul>'

  nearest = undefined
  frame.fingers.forEach (finger)->
    html += "<li>#{finger.type}: "
    html += "#{finger.tipPosition[0]}, #{finger.tipPosition[1]}, #{finger.tipPosition[2]}"
    html += " / #{finger.stabilizedTipPosition[0]}, #{finger.stabilizedTipPosition[1]}, #{finger.stabilizedTipPosition[2]}"

    if !nearest? || nearest?.tipPosition[2] > finger.tipPosition[2]
      nearest = finger

  tipCursor.finger = nearest
  if nearest?
    scenePosition = tipCursor.calibrator?.convert nearest.stabilizedTipPosition
    if scenePosition?
      tipCursor.moveTo scenePosition
        .show()
    else
      scenePosition ||= frame.leapToScene nearest.stabilizedTipPosition
      tipCursor.moveTo x: scenePosition[0], y: scenePosition[1]
        .show()
  else
    tipCursor.hide()

  $('#leap-info').html html

Leap?.Frame::leapToScene = (position)->
  norm = @interactionBox.normalizePoint position
  [ window.innerWidth * norm[0], window.innerHeight * (1 - norm[1]) ]

EyeTribe?.loop (frame)->
  if frame.state & EyeTribe.GazeData.STATE_TRACKING_EYES
    clientPosition = frame.smoothedCoordinates.toClient()
    console.log frame.smoothedCoordinates, clientPosition

    gazeCursor.moveTo clientPosition
      .show()

    $('#panel .button').each ->
        if clientPosition.inbounds @getBoundingClientRect()
          $(@).addClass 'focus'
        else
          $(@).removeClass 'focus'
  else
    gazeCursor.hide()

Point = EyeTribe?.Point2D

Point?.origin = new Point window.screenX, window.screenY

Point?::toClient = ->
  @subtract Point.origin

Point?::toScreen = ->
  @add Point.origin

Point?::inbounds = (rect)->
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

gazeCursor = new Cursor 'gaze'
tipCursor = new Cursor 'tip'

$ ->
  $calibrationButton = $('#calibrate').click ->
    $calibrationButton.toggleClass 'selected'
    if $calibrationButton.hasClass 'selected'
      tipCursor.calibrator = new TouchCalibrator()
        .start(tipCursor)
    else
      tipCursor.calibrator.stop()


  panel = [
    price = PricePanel.appendTo '#content'
    map = RailwayMap.appendTo '#content'
    search = undefined
  ]

  panel.prev = ->
    @[((@indexOf @current) - 1 + @length) % @length]

  panel.next = ->
    @[((@indexOf @current) + 1) % @length]

  panel.set = (@current)->
    @forEach (p)-> p?.hide()
    @current?.show()
    console.log @current, @prev(), @next()
    $('#prev').text @prev()?.name || ''
    $('#next').text @next()?.name || ''

  $('#prev').on 'click', ->
    panel.set panel.prev()

  $('#next').on 'click', ->
    panel.set panel.next()
  .trigger 'click'
