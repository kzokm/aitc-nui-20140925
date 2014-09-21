class @PricePanel extends MainPane
  name: '金額ボタンで選ぶ'
  header: 'お求めの金額にふれてください'

  constructor: (element)->
    super element

    prices = pricedata.keikyu.prices()
    $.createTable rows = 4, columns = 5, (i, j)->
      price = prices[i * columns + j]
      if price?
        $('<button class=price>')
          .text price
          .data
            price: price
            names: pricedata.keikyu.names price
    .appendTo element

    $(element)
      .tooltip 'button', tooltip
      .on 'click', 'button', ->
        $.main.show payment $(@).data()
        $.tooltip.show tooltip.call @
        event.stopPropagation()

  tooltip = ()->
    {price, names} = $(@).data()
    if price?
      "#{price}円で以下の駅まで乗車できます。<br><em>#{names.join '、'}"

  payment = (data)->
    header: 'お金を入れて下さい。10円以下の硬貨は利用できません。'

    show: ->
      $('#payment')
        .find '#ticket_info .price'
          .text data.price
          .end()
        .find '#ticket_price .price'
          .text data.price
          .end()
        .find '#money_input .price'
          .text 0
          .end()
        .find '#money_change'
          .hide()
          .end()
        .show()

    demo: ->
      input = 0

      pay =->
        remain = data.price - input
        input += switch
          when remain < 100 then 100
          when remain < 500 then 500
          else 1000
        $('#money_input .price').text input
        if remain >= 1000
          setTimeout pay, 1000
        else
          $('#money_change').show()
            .find '.price'
            .text input - data.price
          $.tooltip.show '<em>きっぷとおつりをとりわすれないようにご注意ください。'
          setTimeout $.proxy($.main, 'resume'), 5000

      setTimeout pay, 3000
