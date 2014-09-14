class @PricePanel extends Panel
  name: '金額ボタンで選ぶ'
  message: 'お求めの金額にふれてください'

  constructor: (parent)->
    $panel = @panel = $('<div id=prices class=content>')
       .appendTo parent

    prices = [ 140, 160, 170, 220, 310, 390, 470, 550, 640, 720, 800, 920 ]
    rows = 3
    columns = 5
    for i in [0..rows - 1]
      $panel.append row = $('<div class=row>')
      for j in [0..columns - 1]
        row.append '<div class=cell><div class=button>' + (prices[i * columns + j] or '')

    $panel
      .on 'touching', (event, tipCursor)->
        $panel.find '.button'
          .each ->
            inbounds = @containsPosition tipCursor
            $(@).toggleClass 'focus', inbounds
            $(@).focus() if inbounds
      .on 'blur', ->
        $panel.find '.button'
          .removeClass 'focus'
