
# /*
#   google
# */
# Author: PerterPon<PerterPon@gmail.com>
# Create: Thu Oct 15 2015 06:52:27 GMT+0800 (CST)
# 

"use strict"

request    = require 'request'

class Google

  constructor : ( @options ) ->

  middleware : ->
    ( req, res, next ) =>
      { url }  = req
      url      = url.replace '/google/', ''
      request( 'http://www.google.com/recaptcha/api/#{url}' ).pipe res

module.exports = ( options ) ->
  new Google options
