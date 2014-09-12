class @RailwayMap
  WIDTH: 1800
  HEIGHT: 1300

  constructor: (parent)->
    map = d3.select parent
      .append 'svg'
      .attr
         id: 'railway_map'
         class: 'map'
         width: @WIDTH
         height: @HEIGHT

    @lines = map.append 'g'
      .attr class: 'lines'

    @stations = map.append 'g'
      .attr class: 'stations'

    console.log map
    @panel = $('#railway_map')

  _lat: 35.80
  _lon: 139.5
  _scale: 3000

  x: (lon)->
    Math.floor (lon - @_lon) * @_scale
  y: (lat)->
    Math.floor (@_lat - lat) * @_scale

  draw: (line, options)->
    line.load $.proxy @, '_drawLine', line, options

  _drawLine: (line, options)->
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
        stroke: options.line_color || line.color
        'stroke-width': options.line_width || 1
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
    lines.forEach $.proxy (line)->
      @draw line, options
    , @
    @

  show: ->
    @panel.show()
    @

  hide: ->
    @panel.hide()
    @


  @appendTo: (parent)->
    new @ parent
      .drawLines ekidata.jr, line_width: 2
      .drawLines ekidata.keikyu, stations: false
      .drawLines ekidata.metro, line_width: 5
      .drawLines ekidata.toei, line_width: 3
