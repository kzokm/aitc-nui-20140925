class @PricePanel
  $header = $('header')

  constructor: (parent)->
    @panel = $('<div id=prices class=content>')
       .appendTo parent

    prices = [ 140, 160, 170, 220, 310, 390, 470, 550, 640, 720, 800, 920 ]
    for i in [0..3]
      @panel.append row = $('<div class=row>')
      for j in [0..5]
        row.append '<div class=cell><div class=button>' + (prices[i * 6 + j] or '')

  show: ->
    $header.text 'お求めの金額にふれてください'
    do @panel.show
    @

  hide: ->
    do @panel.hide
    @

  @appendTo: (parent)->
    new @ parent
