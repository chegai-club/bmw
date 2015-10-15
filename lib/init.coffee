
# /*
#   init
# */
# Author: PerterPon<PerterPon@gmail.com>
# Create: Thu Oct 15 2015 02:56:21 GMT+0800 (CST)
# 

"use strict"

require 'response-patch'

db = require './core/db'

class Init

  construcotr : ( options ) ->
    @initDb options.database

  initDb : ( options ) ->
    db.init options

  middleware : ->
    ( req, res, next ) =>
      res.req = req
      yield next

module.exports = ( options ) ->
  new Init options
