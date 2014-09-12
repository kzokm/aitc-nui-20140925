class @StationSearch extends Panel
  name: '駅名でさがす'
  message: '駅名または駅番号を入力してください'

  constructor: (parent)->
    @panel = $('<div id=search class=content>')
       .appendTo parent
