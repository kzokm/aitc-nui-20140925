
# 最初に合致する要素を取得する。
Array::find ?= (callback)->
  found = undefined
  @some (e)->
    if callback e
      found = e
      true
  found

# fuluentなforEach
Array::each ?= ->
  @forEach.apply @, arguments
  @


Number::floor ?= ->
  Math.floor @


# カタカナをひらがなに置換する。
String::kana2hira ?= ->
  @replace /[ァ-ン]/g, (s)->
    String.fromCharCode s.charCodeAt(0) + KANA2HIRA

# ひらがなをカタカナに置換する。
String::hira2kana ?= ->
  @replace /[ぁ-ん]/g, (s)->
    String.fromCharCode s.charCodeAt(0) - KANA2HIRA

KANA2HIRA = 'あ'.charCodeAt(0) - 'ア'.charCodeAt(0)


# 濁音・半濁音を清音に置換する。
String::unvoiced ?= ->
  unvoiced = []
  for ch in @
    unvoiced.push ch = UNVOICED[ch] ? ch
  unvoiced

UNVOICED = do (map = {})->
  for ch in 'がぎぐげござじずぜぞだぢづでどばびぶべぼ'
    map[ch] = String.fromCharCode ch.charCodeAt(0) - 1
    ch = ch.hira2kana()
    map[ch] = String.fromCharCode ch.charCodeAt(0) - 1
  for ch in 'ぱぴぷぺぽ'
    map[ch] = String.fromCharCode ch.charCodeAt(0) - 2
    ch = ch.hira2kana()
    map[ch] = String.fromCharCode ch.charCodeAt(0) - 2
  map


# テーブル構造を作成する。
$.createTable ?= (rows, columns, value)->
  $table = $('<div class=table>')
  for i in [0..rows - 1]
    $row = $('<div class=row>').appendTo $table
      .addClass("row-#{i + 1}")
    for j in [0..columns - 1]
      $('<div class=cell>').appendTo $row
        .addClass("column-#{j + 1} cell-#{i + 1}-#{j + 1}")
        .html value? i, j
  $table


# エレメントの属性操作
$.fn.extend
  isVisible: -> $.expr.filters.visible @[0]
  enable: (bool = true)-> @prop 'disabled', !bool
  disable: (bool = true)-> @prop 'disabled', bool


# ツールチップの表示
$.fn.tooltip = (selector, callback)->
  if typeof selector == 'function'
    [callback, selector] = arguments
  unless typeof callback == 'function'
    return $(@).trigger 'tooltip', selector

  $(@)
    .on 'finger', (event, tip)->
      $selection = if selector
          $(selector, @)
        else
          $(@)
      current = $selection.filter('.hover:first')[0]
      if tip.touching && @containsPosition tip
        $selection.each ->
          if @containsPosition tip
            unless @ == current
              $(current).removeClass 'hover'
              $(@).tooltip 'show'
            current = undefined
      $(current).tooltip 'hide' if current
    .on
      'mouseenter touchstart': ->
        $(@).tooltip 'show'
      'mouseleave touchend touchcancel': ->
        $(@).tooltip 'hide'
      tooltip: (event, command)->
        switch command
          when 'show'
            message = callback.call @
            if message
              d3.select @
                .classed 'hover', true
              $.tooltip.show message
              event.stopPropagation()
            else
              $.tooltip.hide()
          when 'hide'
            if $(@).isVisible()
              $.tooltip.hide()
            d3.select @
              .classed 'hover', false
      , selector
