class @RailwayMap extends MainPane
  name: '路線図でさがす'
  header: '手を近づけると地図が拡大します'

  offset =
    x: 500
    y: 250

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


    $(@stations[0])
      .tooltip '.station', ->
        console.log 'station', @__data__
        data = $(@).data()
        data.station ?= ekidata.stations.find @__data__.station_cd
        data.line ?= ekidata.lines.find data.station.line_cd
        data.price ?= ((pricedata.find data.line.company_cd)?.find data.station.station_name)?.price

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


    transform =
      x: 0
      y: 0
      scale: 1

      current: {}

      set: (params)->
        @x = (params.x ?= @x)
        @y = (params.y ?= @y)
        params.scale ?= @scale
        @scale = Math.max config.zoom.min, (Math.min config.zoom.max, params.scale)

      zoom: (params)->
        @set params
        ratio = @scale / @current.scale
        @x += (@current.x - @x) * ratio
        @y += (@current.y - @y) * ratio
        @

      update: (params = {})->
        params = {} if params == @
        @set params
        if @current.x != params.x ||
            @current.y != params.y ||
            @current.scale != params.scale
          console.log 'update', @
          base.attr transform: "translate(#{@x}, #{@y}) scale(#{@scale})"
          if @current.scale != params.scale
            base.selectAll 'text'
              .style 'font-size', @scale * 2
          @current = params
        @

    config.zoom.rate ?= -> (@start_z - @stop_z) / (@max - @min)
    config.zoom.rate = config.zoom.rate()

    $svg = $('svg', element)
    previous_touch = undefined

    $(element).on
      'mousedown touchstart': (event)->
        position = event.originalEvent.targetTouches?[0] ? event
        console.log event.type, position
        previous_touch =
          x: position.clientX
          y: position.clientY
      'mouseleave mouseup': (event)->
        previous_touch = undefined
      'mousemove touchmove': (event)->
        if previous_touch
          position = event.originalEvent.targetTouches?[0] ? event
          console.log event.type, position
          transform.update
            x: transform.x + position.clientX - previous_touch.x
            y: transform.y + position.clientY - previous_touch.y
          previous_touch.x = position.clientX
          previous_touch.y = position.clientY
      mousewheel: (event)->
        transform
          .zoom
            x: event.clientX
            y: event.clientY
            scale: transform.scale + event.originalEvent.deltaY / 600
          .update()

      finger: (event, tip)->
        z = config.zoom.start_z - tip.finger.tipPosition[2]
        if z > 0
          outbounds = !$svg[0].containsPosition tip
          scale = z / config.zoom.rate + config.zoom.min
          if scale <= config.zoom.max or outbounds
            rect = $svg[0].getBoundingClientRect()
            x = tip.x - rect.left
            y = tip.y - rect.top

            unless tip.previous?
              tip.previous = x: x, y: y
              tip.element.addClass 'zooming'

            dx = dy = 0
            do ->
              padding = config.scroll.padding.x
              if x < padding
                x = padding
                if tip.finger.tipVelocity[0] <= 0
                  dx += config.scroll.gain
                  dx *= 2 if x < 0
              else if x > rect.width - padding
                x = rect.width - padding
                if tip.finger.tipVelocity[0] >= 0
                  dx -= config.scroll.gain
                  dx *= 2 if dx > rect.width

              padding = config.scroll.padding.y
              if y < padding
                y = padding
                if tip.finger.tipVelocity[1] >= 0
                  dy += config.scroll.gain
                  dy *= 2 if y < 0
              else if y > rect.height - padding
                y = rect.height - padding
                if tip.finger.tipVelocity[1] <= 0
                  dy -= config.scroll.gain
                  dy *= 2 if y > rect.height

            transform
              .zoom
                x: x
                y: y
                scale: scale
              .update
                x: transform.x - x + tip.previous.x + dx
                y: transform.y - y + tip.previous.y + dy
            tip.previous = x: x, y: y
          else
            endFinger tip
        else
          endFinger tip

    endFinger = (tip)->
      delete tip.previous
      tip.element.removeClass 'zooming'

    @onResume = ->
      transform.update config.transform

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
