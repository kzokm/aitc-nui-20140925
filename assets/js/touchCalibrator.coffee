class @TouchCalibrator
  tipPositions: []
  clientPositions: []

  push: (args)->
    @tipPositions.push args.tip
    @clientPositions.push args.client
    console.log args.tip, args.client

    @origin =
      tip: Vector3D.average.apply Vector3D, @tipPositions
      client: Vector3D.average.apply Vector3D, @clientPositions

    sum =
      x: []
      y: []
      z: []

    for tip, i in @tipPositions
      client = @clientPositions[i]
      dT = tip.subtract @origin.tip
      dC = client.subtract @origin.client
      sum.x.push dC.x / dT.x if dT.x
      sum.y.push dC.y / dT.y if dT.y
      sum.z.push dC.z / dT.z if dT.z

    maxLength = Math.max sum.x.length, sum.y.length, sum.z.length
    console.log maxLength
    if maxLength
      @origin.d =
        x: Math.average.apply Math, sum.x
        y: Math.average.apply Math, sum.y
        z: Math.average.apply Math, sum.z

      if maxLength > 5
        do @_compress

      do @_resolvSurface

  _compress: ->
    dMax = 0
    dI = -1
    for tip, i in @tipPositions
      conv = @convert tip
      conv.subtract @clientPositions[i]
      d = conv.innerProduct conv
      if d > dMax
        dMax = d
        dI = i
    if dI >= 0
      @tipPositions.splice dI, 1
      @clientPositions.splice dI, 1

  _resolvSurface: ->
    nTips = @tipPositions.length
    unless nTips < 3
      for i1 in [0 .. nTips - 3]
        for i2 in [i1 + 1 .. nTips - 2]
          for i3 in [i2 + 1 .. nTips - 1]
            console.log @_getSurface @tipPositions[i1], @tipPositions[i2], @tipPositions[i3]

  _getSurface: (p1, p2, p3)->
    v1 = p2.subtract p1
    v2 = p3.subtract p1
    nu = (v1.outerProduct v2).normalized()
    a: nu.x
    b: nu.y
    c: nu.z
    d: -(nu.innerProduct p1)

  convert: (tip)->
    if @origin?.d?
      dTip = new Vector3D tip
        ._subtract @origin.tip
      dTip.x *= @origin.d.x
      dTip.y *= @origin.d.y
      dTip.z *= @origin.d.z
      dTip._add @origin.client

  start: (tipCursor)->
    $('#prices .button')
      .addClass 'selected'
      .on 'calibrate', (e, tapped)->
        console.log @, arguments
        if tipCursor.finger?
          self.push
            tip: new Vector3D tipCursor.finger.stabilizedTipPosition
            client: new Vector3D tapped.clientX, tapped.clientY
          $(@).removeClass 'selected'
    self = @

  stop: ->
    $('#prices .button').removeClass 'selected'
      .off 'calibrate'
    @

$ ->
  $('#panel')
    .on 'click', '.button.selected', (event)->
      $(@).triggerHandler 'calibrate', event


Math.sum ||= ->
  sum = 0
  for v in arguments
    sum += v
  sum

Math.average ||= ->
  (@sum.apply @, arguments) / arguments.length
