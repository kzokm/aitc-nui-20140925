class @RailwayMap extends MainPane
  name: '路線図でさがす'
  header: '手を近づけると地図が拡大します'

  projection = d3.geo.mercator()
    .scale 130000
    .center [139.65, 35.63]
    .translate [500, 400]

  path = d3.geo.path()
    .projection projection

  constructor: (element)->
    super element

    svg = d3.select element
      .append 'svg'
      .attr
        class: 'pane'
        width: 2000
        height: 1000

    base = svg.append 'g'

    @map = base.append 'g'
      .attr class: 'map'

    @map.append 'image'
      .attr
        'xlink:href': 'images/map.png'
        x: -725
        y: -432.4
        width: 1700 * 1.56
        height: 960 * 1.56

    @_drawMap 'N02-13_RailroadSection',
      class: 'line'
    @_drawMap 'N02-13_Station',
      class: 'station'
      stroke: '#080'
      stroke_width: 3

    $(@map[0]).on 'mouseover', '.station', ->
      console.log @__data__

    #@_drawMap 'chiba', stroke: '#fff', fill: '#ccc'
    #@_drawMap 'tokyo', stroke: '#fff', fill: '#ccc'
    #@_drawMap 'chiba-coastline', stroke: '#000'
    #@_drawMap 'tokyo-coastline', stroke: '#000'
    #@_drawMap 'kanagawa-coastline', stroke: '#000'
    #@_drawMap 'kanagawa-river', stroke: '#008'

    @lines = base.append 'g'
      .attr class: 'lines'

    @stations = base.append 'g'
      .attr class: 'stations'

    @drawLines ekidata.jr, line_width: 2
    @drawLines ekidata.keikyu, stations: false
    @drawLines ekidata.metro, line_width: 5
    @drawLines ekidata.toei, line_width: 3

    dx = dy = 0

    $(element).on
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

  _drawMap: (id, options = {})->
    group = @map.append 'g'
      .attr id: id

    d3.json "geodata/#{id}.json", $.proxy (error, json)->
      console.log error
      console.log json.features.length
      console.log d3.geo.centroid json

      group
        .selectAll 'path'
        .data json.features
        .enter()
        .append 'path'
          .attr
            d: path
            class: options.class
            'data-railroad_category': (d)-> d.properties.N02_001
            'data-company_category': (d)-> d.properties.N02_002
            'data-line_name': (d)-> d.properties.N02_003
            'data-company_name': (d)-> d.properties.N02_004
            'data-station_name': (d)-> d.properties.N02_005
          .style
            stroke: options.stroke ? '#000'
            'stroke-width': options.stroke_width ? 1
            fill: options.fill ? 'transparent'
    , @

  draw: (line, options = {})->
    line.load $.proxy @, '_drawLine', line, options

  _drawLine: (line, options)->
    line.data.station_l.forEach (d)->
      [d.x, d.y] = projection [d.lon, d.lat]

    drawer = d3.svg.line()
      .x (d)-> d.x
      .y (d)-> d.y
      .interpolate 'cardinal'

    if line.code == 11302
      drawer = drawer.interpolate 'cardinal-closed'

    @lines.append 'path'
      .datum line.data
      .attr
        class: "line l_#{line.code}"
        d: drawer line.data.station_l
        'data-line_code': (d)-> d.line_cd
        'data-line_name': (d)-> d.line_name
        'data-line_zoom': (d)-> d.line_zoom
      .style
        stroke: options.line_color ? line.color
        'stroke-width': options.line_width ? 1
        fill: 'transparent'

    unless options.stations == false
      @_drawStations line, options
    @

  _drawStations: (line, options)->
    @stations.append 'g'
      .attr
        class: "l_#{line.code}"
        'data-line_code': line.code
      .selectAll 'circle'
      .data line.data.station_l.filter (d)-> d.station_cd
      .enter()
        .append 'circle'
      .attr
        class: (d)->"station s_#{d.station_cd}"
        r: 5
        cx: (d)-> d.x
        cy: (d)-> d.y
        'data-station_name': (d)-> d.station_name
        'data-station_code': (d)-> d.station_code
        'data-station_group_code': (d)-> d.station_g_code
    @

  drawLines: (lines, options)->
    for line in lines
      @draw line, options
    @
