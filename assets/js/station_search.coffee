class @StationSearch extends MainPane
  name: '駅名でさがす'
  message: '駅名または駅番号を入力してください'

  constructor: (element)->
    super element
    $name = $('<article id=search-name>')
      .appendTo(element)

    $name = $('<article id=search-code>')
      .appendTo(element)
