class @PricePanel extends MainPane
  name: '金額ボタンで選ぶ'
  header: 'お求めの金額にふれてください'

  constructor: (element)->
    super element

    $(element)
      .tooltip 'button', ->
        {price, names} = $(@).data()
        if price?
          "#{price}円で以下の駅まで乗車できます。<br><em>#{names.join '、'}</em><br>"
      .on 'click', 'button.price', ->
        $.main.show new PaymentOverlay $(@).data()

  onResume: ->
    super
    ekidata.load $.proxy @, 'setPanel', 'keikyu'

  setPanel: (id = 'keikyu')->
    $.tooltip.hide()
    $('.table', @element).remove()

    prices = pricedata[id].prices()
    $.createTable rows = 4, columns = 5, (i, j)->
      price = prices[i * columns + j]
      if price?
        $('<button class=price>')
          .text price
          .data
            price: price
            names: pricedata[id].names price
            company: ekidata.companies.find pricedata[id].code
    .appendTo @element

    $(".cell-#{rows}-#{columns}", @element)
      .append switch id
        when 'keikyu' then @toei()
        when 'toei' then @keikyu()

  keikyu: ->
     $('<button class="line-keikyu">')
      .text '京急線'
      .tooltip ->
        '京急各駅までのきっぷをご購入いただけます。'
      .on 'click', $.proxy @, 'setPanel', 'keikyu'

  toei: ->
     $('<button class="line-toei">')
      .text '都営線'
      .tooltip ->
        '都営線への連絡切符をご購入いただけます。<br>' +
        '泉岳寺から都営浅草線への直通運転を行っております。'
      .on 'click', $.proxy @, 'setPanel', 'toei'
