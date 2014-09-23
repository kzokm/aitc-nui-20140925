class @PaymentOverlay
  header: 'お金を入れて下さい。10円以下の硬貨は利用できません。'

  constructor: (@data)->
    unless data.names
      data.line ?= ekidata.find data.station.line_cd
      data.company ?= ekidata.companies.find data.line.company_cd
      data.prices ?= pricedata.find data.line.company_cd
      data.price ?= (data.prices?.find data.station.station_name)?.price
      data.names = data.prices?.names data.price

    @tooltip = ->
      "この切符で以下の駅まで乗車できます。<br><em>#{data.names.join '、'}"

    @show = ->
      $.tooltip.show @tooltip

      company_cd = data.company.company_cd
      line_name = pricedata.names[data.company.company_cd]

      line_info = switch company_cd
        when pricedata.toei.code
          "泉岳寺接続<br>#{line_name}"
        else
          line_name

      $('#payment')
        .find '#ticket_info .line'
          .html line_info
          .end()
        .find '#ticket_info .price'
          .text data.price
          .end()
        .find '#ticket_price .price'
          .text data.price
          .end()
        .find '#money_input .price'
          .text 0
          .end()
        .find '#money_remains'
          .hide()
          .end()
        .find '#money_change'
          .hide()
          .end()
        .show()

    @demo = ->
      input = 0

      pay =->
        remain = data.price - input
        input += switch
          when remain < 100 then 100
          when remain < 500 then 500
          else 1000
        remain = Math.max 0, data.price - input

        $('#money_input .price').text input
        $('#money_remains .price').text remain
        if remain > 0
          $('#money_remains').show()
          setTimeout pay, 3000
        else
          $('#money_remains').hide()
          $('#money_change').show()
            .find '.price'
            .text input - data.price
          $.tooltip.show '<em>きっぷとおつりをとりわすれないようにご注意ください。'
          setTimeout $.main.reset, 5000

      setTimeout pay, 3000
