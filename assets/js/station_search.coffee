class @StationSearch extends Panel
  name: '駅名でさがす'
  message: '駅名または駅番号を入力してください'

  appendTo: (parent)->
    $('<div id=search class=panel>')
      .appendTo parent
