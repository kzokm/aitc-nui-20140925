Leap?.loop enableGestures: true, (frame)->
  html = 'Leap:<br>'

  frontmost = undefined
  frame.fingers.forEach (finger)->
    return unless finger.extended
    html += "Finger(#{finger.type}) [ stabilizedTipPosition:"
    html += "#{finger.stabilizedTipPosition[0]}, #{finger.stabilizedTipPosition[1]}, #{finger.stabilizedTipPosition[2]}"
    html += ' ]<br>'

    if !frontmost? || frontmost?.stabilizedTipPosition[2] > finger.stabilizedTipPosition[2]
      frontmost = finger

  tipCursor.finger = frontmost
  unless frontmost?
    tipCursor.hide()
  else
    scenePosition = tipCursor.calibrator?.convert frontmost.stabilizedTipPosition
    scenePosition ?= frame.leapToScene frontmost.stabilizedTipPosition
    tipCursor.moveTo scenePosition
      .show()

    frame.gestures.forEach (gesture)->
      if gesture.state == 'stop' && gesture.pointableIds[0] == frontmost.id
        switch gesture.type
          when 'swipe'
            onSwipe frame, gesture
          when 'circle'
            onCircle frame, gesture

  $('#leap-info').html html + '<br>'
  $.top.trigger 'leap', frame

Leap?.Frame::leapToScene = (position)->
  norm = @interactionBox.normalizePoint position
  [ window.innerWidth * norm[0], window.innerHeight * (1 - norm[1]) ]

Leap?.Hand::countExtendedFingers = ->
  counter = 0
  @fingers.forEach (finger)->
    counter++ if finger.extended
  counter;


onSwipe = (frame, gesture)->
  return
  if gesture.direction[0] > 0
    do $.main.next
  else
    do $.main.prev

onCircle = (frame, gesture)->
  if frame.hands[0].countExtendedFingers() >= 4
    clockwise = gesture.normal[2] <= 0
    $('#calibrate').toggle clockwise


EyeTribe?.loop (frame)->
  html = 'EyeTribe:<ul>'

  if frame.state & EyeTribe.GazeData.STATE_TRACKING_EYES
    clientPosition = frame.smoothedCoordinates.toClient()
    gazeCursor.moveTo clientPosition
      .show()

    frame.clientPosition = new Point clientPosition
    $('.gaze-receiver:visible').each ->
      inbounds = @containsPosition clientPosition
      $(@).toggleClass 'gaze-focus', inbounds
      $(@).triggerHandler 'gaze', frame if inbounds
  else
    gazeCursor.hide()

  $('#gaze-info').html frame.dump() + '<br>'
  $.top.trigger 'gaze', frame

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


$.top = {
  set: (element)->
    $('section.top').hide()
    @current = $(element).show()
  trigger: (type, data)->
    @current?.triggerHandler type, data
}


class FloatingElement
  constructor: (@id)->
    @element = $("<div id=#{id}>")
      .css
        position: 'absolute'
      .appendTo 'body'

  moveTo: (position)->
    if Array.isArray position
      [x, y] = position
    else
      {x, y} = position
    @element.css
      left: @x = Math.round x
      top: @y = Math.round y
    @

  show: ->
    @element.show()
    @

  hide: ->
    @element.hide()
    @


class Cursor extends FloatingElement
  constructor: (id)->
    super id + '-cursor'
    @element.addClass 'cursor'
    @info = $("<div class=#{id}>")
      .appendTo '#cursor-info'

  moveTo: (position)->
    super position
    @info.html "#{@id}: #{@x}, #{@y}<br>"
    @

class TipCursor extends Cursor
  moveTo: (position)->
    super
    @touching = @finger?.touchZone == 'touching'
    @element.toggleClass 'touching', @touching
    $.main.trigger 'finger', @
    @

class GazeCursor extends Cursor

gazeCursor = tipCursor = undefined


class @Tooltip extends FloatingElement
  constructor: ->
    super 'tooltip'

  show: (content)->
    if content
      @element.html content?() ? content
      super


Element::containsPosition = (point)->
  {x, y} = point
  rect = @getBoundingClientRect()
  x >= rect.left &&
    x <= rect.right &&
    y >= rect.top &&
    y <= rect.bottom


$ ->
  gazeCursor = new GazeCursor 'gaze'
  tipCursor = new TipCursor 'tip'
  tipCursor.calibrator = TouchCalibrator.deserialize localStorage?.calibrator

  $.tooltip = new Tooltip

  $calibrationButton = $('#calibrate').click ->
    $calibrationButton.toggleClass 'selected'
    if $calibrationButton.hasClass 'selected'
      tipCursor.calibrator = new TouchCalibrator()
        .start tipCursor, '#prices button'
    else
      json = tipCursor.calibrator.stop().serialize()
      if json?
        localStorage?.calibrator = json

  $('#main-prev').on 'click', ->
    do $.main.prev

  $('#main-next').on 'click', ->
    do $.main.next
  .trigger 'click'

  $('#container').on 'click', ->
    window.scrollTo 0, 0
