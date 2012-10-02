vertx = require 'vertx'

eb = vertx.eventBus
logger = vertx.logger

eb.registerHandler 'reitti.cache.get', (qry, replier) ->
  eb.send 'redis-client', {command: 'get', key: qry.key}, ({status, value}) ->
    if value?
      logger.debug "Cache hit: #{qry.key}"
      replier {result: JSON.parse(value)}
    else
      logger.info "Cache miss: #{qry.key}"
      replier {result: undefined}

eb.registerHandler 'reitti.cache.put', (data) ->
  eb.send 'redis-client', command: 'set', key: data.key, value: JSON.stringify(data.value)
  if data.ttl?
    eb.send 'redis-client', command: 'expire', key: data.key, seconds: data.ttl
