class @PricePanel extends MainPane
  name: '金額ボタンで選ぶ'
  header: 'お求めの金額にふれてください'

  constructor: (element)->
    super element

    ekidata.load ->
      prices = pricedata.keikyu.prices()
      $.createTable rows = 4, columns = 5, (i, j)->
        price = prices[i * columns + j]
        if price?
          $('<button class=price>')
            .text price
            .data
              price: price
              names: pricedata.keikyu.names price
              company: ekidata.companies.find '京急'
      .appendTo element

    $(element)
      .tooltip 'button', ->
        {price, names} = $(@).data()
        if price?
          "#{price}円で以下の駅まで乗車できます。<br><em>#{names.join '、'}</em><br>"
      .on 'click', 'button', ->
        $.main.show new PaymentOverlay $(@).data()
        event.stopPropagation()
