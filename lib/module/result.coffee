
# /*
#   result
# */
# Author: PerterPon<PerterPon@gmail.com>
# Create: Thu Oct 15 2015 03:41:23 GMT+0800 (CST)
# 

"use strict"

ADD_RESULT  = """
  INSERT INTO result
    ( code, en_name, vin )
  VALUES
    ?;
"""

GET_CAHCE =
  """
  SELECT
    code,
    en_name
  FROM
    result
  WHERE
    vin = ?;
  """

class Result

  addResult : ( result ) ->
    yield db.query ADD_RESULT, [ result ]

  getCache : ( vin ) ->
    yield db.query GET_CAHCE, [ vin ]

module.exports = ( options ) ->
  new Result options
