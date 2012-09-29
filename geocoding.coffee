load 'vertx.js'

eb = vertx.eventBus

isCoordinate = (str) ->
  /\d+\.\d+,\d+\.\d+/.test str

geocode = (query, callback) ->
  eb.send 'reitti.searchIndex.find', query: query, (data) ->
    if data.results.length > 0 and data.results[0].name.toLowerCase() is query.toLowerCase() and data.results[0].coords?
      callback data.results[0]
    else
      eb.send 'reitti.hsl.geocode', query: query, (result) ->
        callback result

eb.registerHandler 'reitti.geocode', (params, replier) ->
  if isCoordinate(params.query)
    replier {name: params.query, coords: params.query}
  else
    eb.send 'reitti.cache.get', key: params.query, (res) ->
      if res.result?
        replier res.result
      else
        geocode params.query, (result) -> 
          eb.send 'reitti.cache.put', key: params.query, value: result
          replier result
