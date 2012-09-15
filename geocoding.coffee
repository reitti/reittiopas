load 'vertx.js'

eb = vertx.eventBus

isCoordinate = (str) ->
  /\d+\.\d+,\d+\.\d+/.test str

geocode = (query, callback) ->
  eb.send 'reitti.searchIndex.find', query: query, (data) ->
    if data.results.length > 0 and data.results[0].loc?
      callback data.results[0].loc
    else
      eb.send 'reitti.hsl.geocode', query, (result) ->
        callback result

eb.registerHandler 'reitti.geocode', (query, replier) ->
  if isCoordinate(query)
    replier query
  else
    eb.send 'reitti.cache.get', key: query, (res) ->
      if res.result?
        replier res.result
      else
        geocode query, (result) -> 
          eb.send 'reitti.cache.put', key: query, value: result
          replier result
