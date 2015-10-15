
# /*
#   error-handler
# */
# Author: PerterPon<PerterPon@gmail.com>
# Create: Thu Oct 15 2015 02:58:28 GMT+0800 (CST)
#

"use strict"

class ErrorHandler

  construcotr : ( @options ) ->

  middleware : ->
    { log } = @options
    ( req, res, next ) =>
      try
        yield next
      catch e
        { message, stack } = e
        log.error JSON.stringify
          action  : 'error handler catched error'
          message : message
          stack   : stack
        if true is res.writeable
          res.end message

module.exports = ( options ) ->
  new ErrorHandler options
