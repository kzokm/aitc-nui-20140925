class @StationSearch extends MainPane
  name: '駅名・番号でさがす'
  header: '駅名の先頭１文字または駅番号を入力してください'

  constructor: (element)->
    super element

    $name = $('<article id=search_by_name>')
      .appendTo(element)
      .append '<header>駅名検索'
      .append $.createTable 5, NAME_LETTERS.length, (i, j)->
        ch = NAME_LETTERS[j].charAt i
        if ch && ch != '　'
          $('<button class=letter disabled>')
            .text ch
            .data
              letter: ch
              stations: []
      .tooltip 'button', ->
        {stations} = $(@).data()
        stations.map (s)-> s.station_name
          .join '、'
      .on 'click', 'button', ->
        $.main.show choice $(@).data()

    ekidata.load ->
      $buttons = $name.find 'button'
      do (companies = ['京急', '東京都交通局'])->
        companies.forEach (name)->
          company = ekidata.companies.find name
          ekidata.stations
            .filter (s)->
              line = ekidata.lines.find s.line_cd
              line.company_cd == company.company_cd
            .forEach (s)->
              ch = s.station_name_k[0].kana2hira().unvoiced()
              data = $buttons.filter ":contains(#{ch}):first"
                .enable()
                .data 'stations'
              data.push s if data?

    $code = $('<article id=search_by_code>')
      #.appendTo(element)
      .append '<header>駅番号検索'
      .append $.createTable CODE_LETTERS.length, 5, (i, j)->
        ch = CODE_LETTERS[i].charAt j
        "<button>#{ch}" if ch && ch != ' '


  choice = (data)->
    header: '目的地を選んでください。'

    show: ->
      columns = 3
      rows = data.stations.length / columns + 1

      $('#station_choice')
        .find '.center'
          .find '.table'
            .remove()
            .end()
          .append $.createTable rows, columns, (i, j)->
            idx = i * columns + j
            return unless station = data.stations[idx]
            line = ekidata.lines.find station.line_cd
            price = ((pricedata.find line.company_cd)?.find station.station_name)?[1]

            $('<button class=station>')
              .append "<span class=name>#{station.station_name}"
              .append "<span class=line style='color: ##{line.line_color_c}'>#{line.line_name}"
              .append "<span class=price>#{price ? '???'}"
              .append '<span class=unit>円'
              .data
                names: (pricedata.find line.company_cd)?.names price
                price: price
                station: station
                line: line
                company: ekidata.companies.find line.company_cd
          .end()
        .find('.prev.letter')
          .text -> prevLetter data.letter
          .end()
        .find('.next.letter')
          .text -> nextLetter data.letter
          .end()
        .show()

  $ ->
    $('#station_choice')
      .on 'click', '.letter', ->
        findLetterButton @innerText
          .trigger 'click'
      .on 'click', 'button.station', ->
        $('.overlay').hide()
        $.main.show new PaymentOverlay $(@).data()
      .on 'click', 'button.back', $.main.resume

  findLetterButton = (ch)->
    $("#search_by_name button:enabled:contains(#{ch}):first")

  prevLetter = (ch)->
    if ch <= 'あ'
      prevLetter 'ん'
    else if ch <= 'ん'
      ch = String.fromCharCode(ch.charCodeAt(0) - 1)
      if (findLetterButton ch).length
        ch
      else
        prevLetter ch

  nextLetter = (ch)->
    if ch >= 'ん'
      nextLetter 'ぁ'
    else if ch >= 'ぁ'
      ch = String.fromCharCode(ch.charCodeAt(0) + 1)
      if (findLetterButton ch).length
        ch
      else
        nextLetter ch


NAME_LETTERS = [
  'あいうえお'
  'かきくけこ'
  'さしすせそ'
  'たちつてと'
  'なにぬねの'
  'はひふへほ'
  'まみむめも'
  'や　ゆ　よ'
  'らりるれろ'
  'わ'
  ]

CODE_LETTERS = [
  '123KA'
  '456 I'
  '789 S'
  ' 0  E'
  ]
