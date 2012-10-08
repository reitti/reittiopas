vertx         = require 'vertx'
hsl           = require 'hsl'
accessibility = require 'accessibility'

CACHE_TTL = 60 * 60 # One hour

eb = vertx.eventBus

module.exports = (params, callback) ->
  cacheKey = JSON.stringify(params)
  eb.send 'reitti.cache.get', key: cacheKey, (res) ->
    if res.result?
      callback res.result
    else
      hsl.findRoutes params, (data) ->
        accessibility.attachFloorHeights data.body, (error) ->
          eb.send 'reitti.cache.put', key: cacheKey, value: data, ttl: CACHE_TTL
          callback data
