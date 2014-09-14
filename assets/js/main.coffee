Leap?.loop (frame)->
  html = 'Leap:<ul>'

  frontmost = undefined
  frame.fingers.forEach (finger)->
    return unless finger.extended
    html += "<li>#{finger.type}: "
    html += "#{finger.stabilizedTipPosition[0]}, #{finger.stabilizedTipPosition[1]}, #{finger.stabilizedTipPosition[2]}"

    if !frontmost? || frontmost?.stabilizedTipPosition[2] > finger.stabilizedTipPosition[2]
      frontmost = finger

  tipCursor.finger = frontmost
  if frontmost?
    scenePosition = tipCursor.calibrator?.convert frontmost.stabilizedTipPosition
    if scenePosition?
      tipCursor.moveTo scenePosition
        .show()
    else
      scenePosition = frame.leapToScene frontmost.stabilizedTipPosition
      tipCursor.moveTo scenePosition
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

    $('#content .button').each ->
      inbounds = @containsPosition clientPosition
      $(@).toggleClass 'focus', inbounds
  else
    gazeCursor.hide()

Point = EyeTribe?.Point2D

Point?.origin = new Point window.screenX, window.screenY

Point?::toClient = ->
  @subtract Point.origin

Point?::toScreen = ->
  @add Point.origin


document.onmousemove = (event)->
  clientLeft = event.screenX - event.clientX
  clientTop = event.screenY - event.clientY
  Point?.origin = new Point clientLeft, clientTop


class FloatingElement
  constructor: (@id)->
    @element = $("<div id=#{id}>")
      .css
        position: 'absolute'
      .appendTo 'body'

  moveTo: (position)->
    if Array.isArray position
      [@x, @y] = position
    else
      {@x, @y} = position
    @info.html "#{@id}:<br>#{@x}, #{@y}"
    @element.css
      left: @x
      top: @y
    @

  show: ->
    @element.show()
    @

  hide: ->
    @element.hide()
    @


class Cursor extends FloatingElement
  constructor: (id)->
    super id
    @element.addClass 'cursor'
    @info = $("<div id=#{id}-info>")
      .appendTo '#debug'

class TipCursor extends Cursor
  moveTo: (position)->
    super
    touching = @finger?.touchZone == 'touching'
    @element.toggleClass 'touching', touching
    if touching
      $.panel.trigger 'touching', @
    else
      $.panel.trigger 'blur'
    @

gazeCursor = tipCursor = undefined



class @Tooltip extends FloatingElement
  constructor: ->
    super 'tooltip'

  bind: (element)->

  show: (content)->
    @element.html content
    super

@tooltip = undefined


Element::containsPosition = (point)->
  {x, y} = point
  rect = @getBoundingClientRect()
  x >= rect.left &&
    x <= rect.right &&
    y >= rect.top &&
    y <= rect.bottom


$ ->
  gazeCursor = new Cursor 'gaze-cursor'
  tipCursor = new TipCursor 'tip-cursor'

  $.tooltip = new Tooltip

  $calibrationButton = $('#calibrate').click ->
    $calibrationButton.toggleClass 'selected'
    if $calibrationButton.hasClass 'selected'
      tipCursor.calibrator = new TouchCalibrator()
        .start tipCursor, '#prices .button'
    else
      tipCursor.calibrator.stop()

  PricePanel.appendTo '#content'
  RailwayMap.appendTo '#content'
  StationSearch.appendTo '#content'

  $('#prev').on 'click', ->
    $.panel.showPrev()

  $('#next').on 'click', ->
    $.panel.showNext()
  .trigger 'click'
