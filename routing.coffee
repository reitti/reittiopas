load 'vertx.js'

CACHE_TTL = 60 * 60 # One hour

eb = vertx.eventBus

eb.registerHandler 'reitti.findRoutes', (params, replier) ->
  cacheKey = JSON.stringify(params)
  eb.send 'reitti.cache.get', key: cacheKey, (res) ->
    if res.result?
      replier res.result
    else
      eb.send 'reitti.hsl.findRoutes', params, (data) ->
        eb.send 'reitti.cache.put', key: cacheKey, value: data, ttl: CACHE_TTL
        replier data
