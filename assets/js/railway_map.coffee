class @RailwayMap extends MainPane
  name: '路線図でさがす'
  header: '手を近づけると地図が拡大します'

  offset =
    x: 500
    y: 300

  projection = d3.geo.mercator()
    .scale 130000
    .center [139.65, 35.63]
    .translate [offset.x, offset.y]

  path = d3.geo.path()
    .projection projection


  constructor: (element)->
    super element

    base = d3.select element
      .append 'svg'
      .attr
        class: 'pane'
        width: 2500
        height: 1500
      .append 'g'

    @map = base.append 'g'
      .attr class: 'map'

    @lines = base.append 'g'
      .attr class: 'lines'

    @stations = base.append 'g'
      .attr class: 'stations'

    do @drawAll

    transform =
      x: 0
      y: 0
      scale: 1
      adjust: ->
        @scale = Math.max 1, (Math.min 4, @scale)
        @
      update: (attr = {})->
        @x = attr.x if attr.x?
        @y = attr.y if attr.y?
        @scale = attr.scale if attr.scale?
        @adjust()
        console.log @
        base.attr transform: "translate(#{@x}, #{@y}) scale(#{@scale})"
        base.selectAll 'text'
          .style 'font-size', @scale * 2
        @

    dx = dy = 0

    $(@stations[0])
      .tooltip '.station', ->
        console.log 'station', @__data__
        data = $(@).data()
        data.station ?= ekidata.stations.find @__data__.station_cd
        data.line ?= ekidata.lines.find data.station.line_cd
        data.price ?= ((pricedata.find data.line.company_cd)?.find data.station.station_name)?[1]

        html = "#{data.line.line_name}
        #{data.station.station_name}駅
        （#{data.station.station_name_k.kana2hira()}）"
        html += "#{data.station.add}"
        if data.price
          html += "<br>#{data.price}円"
        html
      .on 'click', '.station', (event)->
        console.log 'station', @, @__data__
        data = $(@).data()
        data.station ?= ekidata.stations.find @__data__.station_cd
        $.main.show new PaymentOverlay data
        event.stopPropagation()


    $(element).on
      'mousedown touchstart': (event)->
        origin =
          x: transform.x - event.clientX
          y: transform.y - event.clientY
        $(@)
          .on 'mouseup mouseleave touchend touchcancel', (event)->
            $(@).off 'mouseup mouseleave mousemove'
          .on 'mousemove touchmove', (event)->
            transform.update
              x: origin.x + event.clientX
              y: origin.y + event.clientY
      mousewheel: (event)->
        transform.scale += event.originalEvent.deltaY / 600
        transform.update()
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
      group
        .selectAll 'path'
        .data json.features
        .enter()
        .append 'path'
          .attr
            d: path
            class: options.class
          .style
            stroke: options.stroke ? '#000'
            'stroke-width': options.stroke_width ? 1
            fill: options.fill ? 'transparent'
    , @

  _drawJRLINE: (id, options = {})->
    group = @map.append 'g'
      .attr id: id

    d3.json "geodata/#{id}.json", $.proxy (error, json)->
      group
        .selectAll 'path'
        .data json.features.filter (d)-> d.properties.N02_004 == '東日本旅客鉄道'
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

    unless options.station_size == 0
      @_drawStation line, options
    @

  _drawStation: (line, options)->
    station = @stations.append 'g'
      .attr
        class: "l_#{line.code}"
        'data-line_code': line.code
      .selectAll 'g'
      .data line.data.station_l.filter (d)->
        d.station_cd
      .enter()
      .append 'g'
      .attr
        class: (d)->"station s_#{d.station_cd}"
        'data-line_code': line.code
        'data-station_name': (d)-> d.station_name
        'data-station_code': (d)-> d.station_code
        'data-station_group_code': (d)-> d.station_g_code

    station
      .append 'circle'
      .attr
        r: options.station_size ? 5
        cx: (d)-> d.x
        cy: (d)-> d.y
    station
      .append 'text'
      .attr
        x: (d)-> d.x + 5
        y: (d)-> d.y + 5
      .style
        'font-size': 2
      .text (d)-> d.station_name
    @

  drawLines: (lines, options)->
    for line in lines
      @draw line, options
    @


  __drawAll: ->
    @_drawMap 'N02-13_RailroadSection',
      class: 'line'
    @_drawMap 'N02-13_Station',
      class: 'station'
      stroke: '#080'
      stroke_width: 3

    #@_drawMap 'chiba', stroke: '#fff', fill: '#ccc'
    #@_drawMap 'tokyo', stroke: '#fff', fill: '#ccc'
    #@_drawMap 'kanagawa-river', stroke: '#008'

    @drawLines ekidata.metro,
      line_width: 1
      station_size: 0

    @drawLines ekidata.jr,
      line_width: 1
      station_size: 0

  drawAll: ->
    @_drawMap 'chiba',
      stroke: '#fff'
      fill: '#fffaf0'
    @_drawMap 'tokyo',
      stroke: '#fff'
      fill: '#fffaf0'
    @_drawMap 'kanagawa',
      stroke: '#fff'
      fill: '#fffaf0'
    @_drawMap 'chiba-coastline',
      stroke: '#ccc'
    @_drawMap 'tokyo-coastline',
      stroke: '#ccc'
    @_drawMap 'kanagawa-coastline',
      stroke: '#ccc'

    @map.append 'image'
      .attr
        'xlink:href': 'images/map.png'
        x: offset.x - 1225
        y: offset.y - 832.4
        width: 1700 * 1.56
        height: 960 * 1.56

    @_drawJRLINE 'N02-13_RailroadSection',
      stroke: '#888'
      stroke_width: 1

    @drawLines ekidata.keisei,
      line_width: 3
      station_size: 3

    @drawLines ekidata.toei,
      line_width: 3
      station_size: 3

    @drawLines ekidata.keikyu,
      line_width: 5
      station_size: 5
