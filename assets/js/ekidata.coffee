
class Line
  constructor: (@code, @color = '#000')->

  load: (callback)->
    unless @data?
      d3.json "ekidata/l/#{@code}.json", $.proxy (error, json)->
        callback?.apply @, @data = json
      , @
    else
      callback?.apply @, @data

@ekidata =
  jr: [
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

  keikyu: [
    new Line 27001
    new Line 27002
  ]

  metro: [
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

  toei: [
    new Line 99301, '#b6007a'
    new Line 99302, '#e85298'
    new Line 99303, '#0079c2'
    new Line 99304, '#6cbb5a'
  ]
