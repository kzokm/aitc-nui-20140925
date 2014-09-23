
return if @pricedata?

class PriceData
  all = []

  constructor: (@id, @code)->
    all.push do @load

  load: (callback)->
    if @data?
      callback?.call @, @data
    else
      d3.csv "pricedata/#{@id}.csv", $.proxy (error, @data)->
        console.log data
        callback?.call @, data
      , @
    @

  @find: (code)->
    all.find (e)-> e.code == code

  prices: ->
    $.unique @data.map (d)-> d.price
      .sort (d1, d2)-> d1 - d2

  names: (price)->
    $.unique @data.filter (d)-> d.price == price
      .map (d)-> d.name

  find: (name)->
    @data.find (d)-> d.name == name

@pricedata =
  names:
    17: '京急線'
    18: '東京メトロ'
    119: '都営線'

  keikyu: new PriceData 'keikyu', 17
  toei: new PriceData 'toei', 119

  find: (code, name)->
    PriceData.find code
