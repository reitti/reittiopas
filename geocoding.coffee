load 'vertx.js'

eb = vertx.eventBus

isCoordinate = (str) ->
  /\d+\.\d+,\d+\.\d+/.test str

eb.registerHandler 'reitti.geocode', (query, replier) ->
  if isCoordinate(query)
    replier query
  else
    eb.send 'reitti.searchIndex.find', query: query, (data) ->
      if data.results.length > 0 and data.results[0].loc?
        replier data.results[0].loc
      else
        eb.send 'reitti.hsl.geocode', query, replier