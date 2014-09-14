class @PricePanel extends Panel
  name: '金額ボタンで選ぶ'
  message: 'お求めの金額にふれてください'

  appendTo: (parent)->
    $panel = $('<div id=prices class=content>')
       .appendTo parent

    prices = [ 140, 160, 170, 220, 310, 390, 470, 550, 640, 720, 800, 920 ]
    rows = 3
    columns = 5
    for i in [0..rows - 1]
      $panel.append row = $('<div class=row>')
      for j in [0..columns - 1]
        price = prices[i * columns + j] ? ''
        row.append '<div class=cell><div class=button>' + price

    $panel.on
      finger: (event, tip)->
        $buttons = $panel.find '.button'
          .removeClass 'focus'

        if tip.touching && $panel[0].containsPosition tip
          $buttons.each ->
            if @containsPosition tip
              if price = $(@).text()
                $(@).addClass 'focus'
                $.tooltip.show "#{price}円で行ける区間：xxxxxxxxxxxxxxxxx"
              else
                $.tooltip.hide()
        else
          $.tooltip.hide()
