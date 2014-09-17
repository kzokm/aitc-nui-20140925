class @PricePanel extends MainPane
  name: '金額ボタンで選ぶ'
  message: 'お求めの金額にふれてください'

  constructor: (element)->
    super element
    $panel = $(element)

    prices = [ 140, 160, 170, 220, 310, 390, 470, 550, 640, 720, 800, 920 ]
    rows = 3
    columns = 5
    for i in [0..rows - 1]
      $panel.append row = $('<div class=row>')
      for j in [0..columns - 1]
        price = prices[i * columns + j]
        row.append '<div class=cell><button>' + price if price

    $panel.on
      finger: (event, tip)->
        $buttons = $panel.find 'button'
          .removeClass 'hover'

        if tip.touching && $panel[0].containsPosition tip
          $buttons.each ->
            if @containsPosition tip
              if price = $(@).text()
                $(@).addClass 'hover'
                $.tooltip.show "#{price}円で行ける区間：xxxxxxxxxxxxxxxxx"
              else
                $.tooltip.hide()
        else
          $.tooltip.hide()
