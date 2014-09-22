
return if @ekidata?

_datacache = {}

@ekidata =
  fetch: (name, callback, self)->
    self ?= @
    cached = _datacache[name]
    if cached
      callback?.call self, cached
    else
      $.getJSON "ekidata/#{name}.json", (data)->
        _datacache[name] = data
        callback.call self, data
    @

  load: (callback, self)->
    self ?= @
    @fetch 'company', (@companies)->
      @fetch 'line', (@lines)->
        @fetch 'station', (@stations)->
          callback?.call self, ekidata

ekidata.load ->
  @companies.find = (code)->
    if typeof code == 'number'
      Array::find.call @, (c)-> c.company_cd == code
    else if typeof code == 'string'
      Array::find.call @, (c)-> c.company_name_r == code
    else
      Array::find.apply @, arguments

  @lines.find = (code)->
    if typeof code == 'number'
      Array::find.call @, (l)-> l.line_cd == code
    else if typeof code == 'string'
      Array::find.call @, (l)-> l.line_name == code
    else
      Array::find.apply @, arguments

  @stations.find = (code)->
    if typeof code == 'number'
      Array::find.call @, (s)-> s.station_cd == code
    else if typeof code == 'string'
      Array::find.call @, (s)-> s.station_name == code
    else
      Array::find.apply @, arguments


class Line
  constructor: (@code, @color = '#000')->

  load: (callback)->
    ekidata.fetch "l/#{@code}", $.proxy (@data)->
      callback.call @, data
    , @

ekidata.jr = [
#      new Line 11301
#      new Line 11303
#      new Line 11304
#      new Line 11305
#      new Line 11322
    new Line 11332, '#00B2E5'
    new Line 11320, '#00b261'
    new Line 11321, '#00b48d'
    new Line 11313, '#ffd400'
    new Line 11312, '#f15a22'
    new Line 11302, '#80c241'
  ]

ekidata.keikyu = [
    new Line 27001
    new Line 27002
    new Line 27003
    new Line 27004
    new Line 27005
  ]

ekidata.metro = [
    new Line 28001, '#f39700'
    new Line '28002-1', '#e60012'
    new Line '28002-2', '#e60012'
    new Line 28003, '#9caeb7'
    new Line 28004, '#00a7db'
    new Line 28005, '#009944'
    new Line 28006, '#d7c447'
    new Line 28008, '#9b7cb6'
    new Line 28009, '#00ada9'
    new Line 28010, '#bb641d'
  ]

ekidata.toei = [
    new Line 99301, '#b6007a'
    new Line 99302, '#e85298'
    new Line 99303, '#0079c2'
    new Line 99304, '#6cbb5a'
  ]
