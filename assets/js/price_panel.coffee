class @PricePanel extends MainPane
  name: '金額ボタンで選ぶ'
  message: 'お求めの金額にふれてください'

  constructor: (element)->
    super element

    prices = pricedata.keikyu.prices()
    $.createTable rows = 4, columns = 5, (i, j)->
      price = prices[i * columns + j]
      if price?
        $('<button>')
          .text price
          .data
            price: price
            names: pricedata.keikyu.names price
    .appendTo element

    $(element)
      .on 'finger', (event, tip)->
        $buttons = $('button', element)
          .removeClass 'hover'

        if tip.touching && element.containsPosition tip
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
