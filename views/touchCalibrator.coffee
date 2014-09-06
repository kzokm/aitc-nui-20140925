class @TouchCalibrator
  tipPositions: []
  clientPositions: []

  push: (h)->
    console.log 'push: ', h.tip, h.client
    @tipPositions.push h.tip
    @clientPositions.push h.client

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

    if sum.x.length > 0 && sum.y.length > 0 && sum.z.length > 0
      @origin.d =
        x: Math.average.apply Math, sum.x
        y: Math.average.apply Math, sum.y
        z: Math.average.apply Math, sum.z

  convert: (tip)->
    if @origin?.d?
      dTip = new Vector3D tip
        ._subtract @origin.tip
      dTip.x *= @origin.d.x
      dTip.y *= @origin.d.y
      dTip.z *= @origin.d.z
      dTip._add @origin.client

  start: (tipCursor)->
    $('#panel .button')
      .addClass 'selected'
      .one 'click', (event)->
        self.push
          tip: new Vector3D tipCursor.finger.stabilizedTipPosition
          client: new Vector3D event.clientX, event.clientY
        $(@).removeClass 'selected'
    self = @

Math.sum ||= ->
  sum = 0
  for v in arguments
    sum += v
  sum

Math.average ||= ->
  (@sum.apply @, arguments) / arguments.length
