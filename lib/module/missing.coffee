
# /*
#   missing
# */
# Author: PerterPon<PerterPon@gmail.com>
# Create: Thu Oct 15 2015 06:47:27 GMT+0800 (CST)
# 

"use strict"

db = require( '../core/db' )()

ADD_MISSING = """
  INSERT INTO 
    missing( code, name )
  VALUES
    ?;
"""

class Missing 

  addMissing : ( results ) ->
    yield db.query ADD_MISSING, [ results ]

module.exports = ->
  new Missing
