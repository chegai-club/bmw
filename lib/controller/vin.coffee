
# /*
#   vin
# */
# Author: PerterPon<PerterPon@gmail.com>
# Create: Thu Oct 15 2015 03:34:00 GMT+0800 (CST)
# 

"use strict"

thunkify = require 'thunkify'

request  = thunkify require 'request'

yaml     = require 'yamljs'

path     = require 'path'

bmwCfg   = yaml.load path.join __dirname, '../../etc/bmw.yaml'

urlLib   = require 'url'

cheerio  = require 'cheerio'

vinModule     = require( '../module/vin' )()

resultModule  = require( '../module/result' )()

missingModule = require( '../module/missing' )()

class Vin

  construtor : ( @options ) ->

  getCache : ->
    ( req, res, next ) =>
      { vin }    = req.body
      cachedData = yield resultModule.getCache vin
      if 0 is cachedData.length
        res.send '', 404
      else
        ayData = []
        for { code, en_name } in cachedData
          ayData.push [ code, en_name ]

        cnData = @_translate ayData
        res.send cnData

  getVin : ->
    ( req, res, next ) =>
      url = urlLib.format
        protocol : 'http'
        hostname : 'www.baidu.com'
        query    : req.body

      { vin } = req.body
      resData = yield request url

      [ trash, body ] = resData
      $          = cheerio.load body
      parsedData = @decodeRes $, body, vin
      { wrong }  = parsedData

      if true is wrong
        cnData   = @_translate parsedData

      res.send cnData or parsedData
      yield vinModule.addVin vin, Boolean( wrong )

      if true isnt wrong
        yield resultModule.addResult parsedData

  decodeRes : ( $, body, vin ) ->
    $tables = $( '#content > table' ).not '.table1'
    parsedData = []
    if 0 is $tables.length
      if 0 <= body.indexOf 'Wrong captcha code. Try again.'
        return {
          wrong : true
          msg   : '验证码填写有误, 请重新填写.'
        }
      else if 0 <= body.indexOf 'An error occured. Maybe wrong VIN or our service is temporarily unavailable.'
        return {
          wrong : true
          msg   : '车架号有误, 或者服务器发生了一个错误, 请核对后重试'
        }
    else
      for table, i in $tables
        $table = $tables.eq i
        $trs   = $ 'tr', $table
        itemInfo = $trs.eq( 0 ).find( 'td' ).eq( 1 ).text()
        parsedData.push [ '__item_name__', itemInfo, vin ]
        for tr, j in $trs
          continue if 0 is j
          $tr  = $trs.eq j
          continue if 2 is $tr.find( 'td' ).length
          id   = $tr.find( 'td' ).eq( 1 ).text().trim()
          name = $tr.find( 'td' ).eq( 2 ).text().trim()
          parsedData.push [ id, name, vin ]
    parsedData

  _translate : ( data ) ->
    resData  = {}
    itemName = null
    for [ id, name ] in data
      if '__item_name__' is id
        itemName = name
        resData[ itemName ] = []
        continue
      cnId   = null
      cnName = null
      # if 'No.' isnt id.trim()
      #   resData.__original.push [ id, name ]
      if 'Vehicle information' is itemName
        cnId   = bmwCfg.VehicleId[ id ]
      else
        cnName = bmwCfg.No[ id ]

      resData[ itemName ].push { id : cnId, name : cnName, en_name : name, en_id : id }

      if 'VIN long' is id.trim()
        factory   = name[ 10 ]
        facName   = ''
        if factory in [ 'A', 'F', 'K' ]
          facName = '德国慕尼黑'
        else if factory in [ 'E', 'J', 'P' ]
          facName = '德国雷根斯堡'
        else if factory in [ 'B', 'C', 'D', 'G' ]
          facName = '德国丁格芬'
        else if factory in [ 'L' ]
          facName = '美国斯巴腾堡'
        else if factory in [ 'N' ]
          facName = '南非罗斯林'
        else if factory in [ 'W' ]
          facName = '奥地利Graz'
        else
          facName = '中国或其他地区'
        resData[ itemName ].push
          id   : '组装工厂'
          name : facName

    resData

  getChallenge : ->
    { challenge, domain } = @options
    ( req, res, next ) =>
      resData = yield request challenge
      [ trash, body ] = resData
      body    = body.replace 'http://www.google.com/recaptcha/api/', "#{domain}/google/"
      res.send body

module.exports = ( options ) ->
  new Vin options
