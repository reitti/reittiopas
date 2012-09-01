load 'vertx.js'

eb = vertx.eventBus

isCoordinate = (str) ->
  /\d+\.\d+,\d+\.\d+/.test str

eb.registerHandler 'reitti.geocode', (query, replier) ->
  if isCoordinate(query)
    replier query
  else
    eb.send 'reitti.hsl.geocode', query, replier