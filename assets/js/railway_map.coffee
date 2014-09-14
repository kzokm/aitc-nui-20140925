class @RailwayMap extends Panel
  name: '路線図でさがす'
  message: '手を近づけると地図が拡大します'

  appendTo: (parent)->
    map = d3.select parent
      .append 'svg'
      .attr
        id: 'railway-map'
        class: 'panel map'

    base = map.append 'g'

    @lines = base.append 'g'
      .attr class: 'lines'

    @stations = base.append 'g'
      .attr class: 'stations'

    dx = dy = 0

    $(map[0]).on
      finger: (event, tip)->
        z = tip.finger.tipPosition[2]
        if z < 0
          outbounds = !@containsPosition tip
          scale = Math.max 1, -z / 20
          if scale <= 5 or outbounds
            scale = Math.min 4, scale

            rect = @getBoundingClientRect()
            x = tip.x - rect.left
            y = tip.y - rect.top

            if outbounds
              dx = Math.min dx, x if x < 0
              dx = Math.max dx, x - rect.width if x > rect.width
              dy = Math.min dy, y if y < 0
              dy = Math.max dy, y - rect.height if y > rect.height
              x = Math.max 0, Math.min x, rect.width
              y = Math.max 0, Math.min y, rect.height
            x -= (x + dx) * scale
            y -= (y + dy) * scale

            base.attr
              transform: "translate(#{x}, #{y}) scale(#{scale})"
        else
          base.attr
            transform: undefined
          dx = dy = 0

  _lat: 35.80
  _lon: 139.5
  _scale: 3000

  x: (lon)->
    Math.floor (lon - @_lon) * @_scale
  y: (lat)->
    Math.floor (@_lat - lat) * @_scale

  draw: (line, options)->
    line.load $.proxy @, '_drawLine', line, options

  _drawLine: (line, options = {})->
    drawer = d3.svg.line()
      .x $.proxy ((d)-> @x d.lon), @
      .y $.proxy ((d)-> @y d.lat), @
      .interpolate 'cardinal'

    if line.code == 11302
      drawer = drawer.interpolate 'cardinal-closed'

    @lines.append 'path'
      .data [ line.data ]
      .attr
        class: "line l_#{line.code}"
        stroke: options.line_color ? line.color
        'stroke-width': options.line_width ? 1
        fill: 'transparent'
        d: drawer line.data.station_l

    unless options.stations == false
      @_drawStations line, options
    @

  _drawStations: (line, options)->
    @stations.append 'g'
      .attr
        class: "l_#{line.code}"
      .selectAll 'circle'
      .data line.data.station_l
      .enter()
        .append 'circle'
      .attr
        class: (d)->"station s_#{d.station_cd}"
        r: 5
        cx: $.proxy ((d)-> @x d.lon), @
        cy: $.proxy ((d)-> @y d.lat), @
    @

  drawLines: (lines, options)->
    for line in lines
      @draw line, options
    @

  onCreate: ->
    super
    @drawLines ekidata.jr, line_width: 2
    @drawLines ekidata.keikyu, stations: false
    @drawLines ekidata.metro, line_width: 5
    @drawLines ekidata.toei, line_width: 3
