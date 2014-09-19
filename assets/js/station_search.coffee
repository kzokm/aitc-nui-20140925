class @StationSearch extends MainPane
  name: '駅名をさがす'
  header: '駅名の先頭１文字または駅番号を入力してください'

  constructor: (element)->
    super element

    $name = $('<article id=search-name>')
      .appendTo(element)
      .append '<header>駅名検索'
      .append $.createTable 5, NAME_CHARS.length, (i, j)->
        ch = NAME_CHARS[j].charAt i
        "<button disabled>#{ch}" if ch && ch != '　'

    $(element).tooltip 'button', ->
        {stations} = $(@).data()
        stations
          .map (s)-> s.station_name
          .join '、'

    $buttons = $name.find('button')
      .each -> $(@).data 'stations', []

    setCompany = (name)->
      c = ekidata.companies.find (c)-> c.company_name_r == name
      ekidata.stations
        .filter (s)->
          Math.floor(s.line_cd / 1000) == c.rr_cd
        .forEach (s)->
          ch = s.station_name_k[0].kana2hira().unvoiced()
          $buttons.filter ":contains(#{ch})"
            .enable()
            .data('stations').push(s)

    ekidata.load ->
      setCompany '京急'
      setCompany '東京都交通局'

    $code = $('<article id=search-code>')
      #.appendTo(element)
      .append '<header>駅番号検索'
      .append $.createTable CODE_CHARS.length, 5, (i, j)->
        ch = CODE_CHARS[i].charAt j
        "<button>#{ch}" if ch && ch != ' '


NAME_CHARS = [
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

CODE_CHARS = [
  '123KA'
  '456 I'
  '789 S'
  ' 0  E'
  ]
