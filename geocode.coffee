vertx = require 'vertx'
hsl   = require 'hsl'

eb = vertx.eventBus

isCoordinate = (str) ->
  /\d+\.\d+,\d+\.\d+/.test str

geocode = (query, callback) ->
  eb.send 'reitti.searchIndex.find', query: query, (data) ->
    if data.results.length > 0 and data.results[0].name.toLowerCase() is query.toLowerCase() and data.results[0].coords?
      callback data.results[0]
    else
      hsl.geocode query, (result) ->
        callback result

module.exports = (query, callback) ->
  if isCoordinate(query)
    callback {name: query, coords: query}
  else
    eb.send 'reitti.cache.get', key: query, (res) ->
      if res.result?
        callback res.result
      else
        geocode query, (result) -> 
          eb.send 'reitti.cache.put', key: query, value: result
          callback result
