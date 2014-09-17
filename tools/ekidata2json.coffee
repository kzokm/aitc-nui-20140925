#!/usr/bin/env coffee
csv = require 'csv'
fs = require 'fs'
http = require 'http'

ekidata =
  api: 'http://www.ekidata.jp/api'
  dir: "#{__dirname}/../public/ekidata"
  get: (path)->
    file = "#{@dir}/#{path}"
    unless fs.existsSync file
      http.get "#{@api}/#{path}", (res)->
        res.on 'data', (content)->
          eval content.toString()
          json = JSON.stringify xml.data
            .replace /},{/g, "},\n{"
            .replace /\[{/g, "[\n{"
          fs.writeFile file, json

company =
  csv:  "#{ekidata.dir}/company20130120.csv"
  json: "#{ekidata.dir}/company.json"
  selected: [
    2 # JR東日本
    11 # 東武鉄道
    12 # 西武鉄道
    13 # 京成電鉄
    14 # 京王電鉄
    15 # 小田急電鉄
    16 # 東急電鉄
    17 # 京急電鉄
    18 # 東京メトロ
    # 19 # 相模鉄道
    119 # 東京都交通局
    # 121 # 埼玉高速鉄道
    # 122 # いすみ鉄道
    123 # 首都圏新都市鉄道（つくばエクスプレス）
    # 124 # 横浜高速鉄道
    # 125 # ゆりかもめ
    # 127 # 山万
    # 130 # 横浜市交通局
    131 # 横浜新都市交通
    # 133 # 江ノ島電鉄
    # 138 # 小湊鐵道
    # 139 # 湘南モノレール
    # 142 # 新京成電鉄
    # 144 # 千葉都市モノレール
    148 # 東京モノレール
    # 149 # 東京臨海高速鉄道
    # 150 # 東葉高速鉄道
    # 152 # 北総鉄道
  ]

station =
  csv:  "#{ekidata.dir}/station20140303.csv"
  json: "#{ekidata.dir}/station.json"
line =
  csv:  "#{ekidata.dir}/line20140303.csv"
  json: "#{ekidata.dir}/line.json"

parse = (file, callback)->
  fs.readFile file, (error, text)->
    csv.parse text,
      columns: true
      (error, data)->
        data = data
          .filter (e)->
            e.e_status == '0'
          .map (e)->
            delete e.e_status
            e
        callback? data

Array::writeTo = (file)->
  console.log @length
  json = JSON.stringify @
    .replace /},{/g, "},\n{"
  fs.writeFile file, json
  @

Array::each = (fn)->
  @forEach fn
  @

company.parse = ->
  parse @csv, (data)->
    company.data = data
      .map (e)->
        e.company_cd = Number(e.company_cd)
        e.rr_cd = Number(e.rr_cd)
        e
      .filter (e)->
        (company.selected.indexOf e.company_cd) > 0
    do line.parse

line.parse = ->
  parse @csv, (data)->
    line.selected = {}
    line.data = data
      .map (e)->
        e.company_cd = Number(e.company_cd)
        e.line_cd = Number(e.line_cd)
        e.line_type = Number(e.line_type)
        e.lon = Number(e.lon)
        e.lat = Number(e.lat)
        e
      .filter (e)->
        (company.selected.indexOf e.company_cd) > 0
      .filter (e)->
        # line_type := 1:新幹線 2:一般 3:地下鉄 4:市電・路面電車 5:モノレール・新交通
        e.line_type == 2 || e.line_type == 3
      .each (e)->
        line.selected[e.line_cd] = e
    do station.parse

station.parse = ->
  parse @csv, (data)->
    station.selected = {}
    station.data = data
      .map (e)->
        e.station_cd = Number(e.station_cd)
        e.station_g_cd = Number(e.station_g_cd)
        e.line_cd = Number(e.line_cd)
        e.pref_cd = Number(e.pref_cd)
        e.lon = Number(e.lon)
        e.lat = Number(e.lat)
        e
      .filter (e)->
        line.selected[e.line_cd]
      .filter (e)->
        # pref_cd: 11=埼玉, 12=千葉, 13=東京, 14=神奈川
        e.pref_cd >= 11 && e.pref_cd <= 14
      .filter (e)->
        e.lat > 35.0 && e.lat <= 35.8 && e.lon >= 139.5 && e.lon <= 140.2

    line.selected = {}
    station.data
      .each (e)->
        line.selected[e.line_cd] = true
      .writeTo station.json

    line.data
      .filter (e)->
        line.selected[e.line_cd]
      .writeTo line.json
      .each (e)->
        ekidata.get "l/#{e.line_cd}.json"

    company.data
      .writeTo company.json

do company.parse
