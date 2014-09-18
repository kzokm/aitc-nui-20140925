class @PricePanel extends MainPane
  name: '金額ボタンで選ぶ'
  message: 'お求めの金額にふれてください'

  constructor: (element)->
    super element
    $panel = $(element)
    $table = $('<div class=table>').appendTo $panel

    # prices = [ 140, 160, 170, 220, 310, 390, 470, 550, 640, 720, 800, 920 ]
    prices = pricedata.keikyu.prices()
    rows = 4
    columns = 5
    for i in [0..rows - 1]
      $row = $('<div class=row>').appendTo $table
      for j in [0..columns - 1]
        price = prices[i * columns + j]
        $cell = $('<div class=cell>').appendTo $row
        continue unless price?
        $('<button>')
          .text price
          .data
            price: price
            names: pricedata.keikyu.names price
          .appendTo $cell

    $panel
      .on 'finger', (event, tip)->
        $buttons = $panel.find 'button'
          .removeClass 'hover'

        if tip.touching && $panel[0].containsPosition tip
          $buttons.each ->
            if @containsPosition tip
              $(@).trigger 'mouseenter'
        else
          $.tooltip.hide()

      .on 'mouseenter', 'button', ()->
        {price, names} = $(@).data()
        if price?
          $(@).addClass 'hover'
          $.tooltip.show "#{price}円で以下の駅まで乗車できます。<br><em>#{names.join '、'}</em>"
        else
          $.tooltip.hide()

      .on 'mouseleave', 'button', ()->
        $(@).removeClass 'hover'
        $.tooltip.hide()
