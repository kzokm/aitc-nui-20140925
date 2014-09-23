class @LangSelect

  # 横の分割数
  x_div = 2
  # 縦の分割数
  y_div = 2

  # 画面サイズ
  screenWidth = screen.width
  screenHeight = screen.height

  # 前に選択していたエリアのindex
  oldIndex = -1
  # 停止対象のエリアindex
  stopIndex = -1
  # アニメーション開始制御フラグ
  animeStartFlg = false
  # アニメーション停止制御フラグ
  animeStopFlg = false

  getMousePosition : (mouseevent) ->
    obj = []
    if mouseevent
      obj.x = mouseevent.pageX
      obj.y = mouseevent.pageY
    else
      obj.x = event.x + document.body.scrollLeft
      obj.y = event.y + document.body.scrollTop
    obj

  calcAreaIndex = (evt) ->
    xi = Math.floor(evt.x / (screenWidth / x_div))
    yi = Math.floor(evt.y / (screenHeight / y_div))
    idx = xi + (yi * x_div)
    if (idx >= x_div * y_div  || (evt.x == 0 && evt.y == 0))
      idx = -1
    idx

  anime_start = (idx) ->
    $("#loadbar" + idx + " div").css({opacity:0})
    $("#loadbar" + idx).show()
    frame.call @, "#loadbar" + idx + " div", idx, 0

  frame = (elm, idx, bar_idx) ->
    n = $(elm)[bar_idx + 1]
    if n?
      if animeStopFlg
        stopAnime.call @, stopIndex
        return

      $(elm + ":eq(" + bar_idx + ")").animate({
          opacity : 1
        },{
          duration : 100,
          easing : "linear",
          complete : ()->
            $(elm + ":eq(" + bar_idx + ")").delay(10)
            frame.call @, elm, idx, bar_idx + 1
        })

    else
      if (animeStopFlg)
        stopAnime.call @, stopIndex
        return
      $(elm + ":eq(" + bar_idx + ")").animate({
          opacity : 1
        }, {
          duration : 100,
          easing : "linear",
          complete : ()->
            $(elm + ":eq(" + bar_idx + ")").delay(10)
            completed.call @, idx
        })

  completed = (idx) ->
    stopAnime.call @, idx
    console.log("completed." + idx)
    if idx == 0
      $.top.set('#main')

  areaCheck : (pos) ->
    idx = calcAreaIndex.call @, pos

    if idx == -1
      return

    if oldIndex != idx
      if animeStopFlg == false && stopIndex == -1
        stopIndex = oldIndex
        animeStopFlg = true
        $("#loadbar" + stopIndex).hide()
      oldIndex = idx;
    else if animeStartFlg == false
      animeStartFlg = true
      $(".langbutton").removeClass("glow")
      $(".langbutton" + ":eq(" + idx + ")").addClass("glow")
      anime_start.call @, idx


  stopAnime = (idx) ->
    $("#loadbar" + idx + " div").css({opacity:0})
    $("#loadbar" + idx + " div").dequeue()
    animeStartFlg = false
    stopIndex = -1
    animeStopFlg = false
    $("#loadbar" + idx).hide()




$(document)
    .on 'mousemove', '#lang-selector', (event)->
#      console.log("event")
#      pos = LangSelect.prototype.getMousePosition(event)
#      LangSelect.prototype.areaCheck(pos)

$(document)
    .on 'keydown', (event) ->
        keycode = 0

        if event != null
            keycode = event.which
            event.preventDefault()
            event.stopPropagation()
        else
            keycode = event.keyCode
            event.returnValue = false
            event.cancelBubble = true

        keychar = String.fromCharCode(keycode).toUpperCase()

        if keychar == "E"
            $(".eye").toggle()

        if keychar == "D"
            $("#dump").toggle()

    .on 'click', '#lang-selector', ->
       $.top.set '#main'
