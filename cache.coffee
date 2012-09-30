vertx = require 'vertx'

eb = vertx.eventBus
logger = vertx.logger

cacheManager = Packages.net.sf.ehcache.CacheManager.newInstance()
cacheConfig = new Packages.net.sf.ehcache.config.CacheConfiguration("reittiCache", 100000)
  .memoryStoreEvictionPolicy(net.sf.ehcache.store.MemoryStoreEvictionPolicy.LFU)
  .overflowToDisk(false)
  .eternal(true)
cache = new Packages.net.sf.ehcache.Cache(cacheConfig)
cacheManager.addCache cache

eb.registerHandler 'reitti.cache.get', (qry, replier) ->
  value = cache.get(new java.lang.String(qry.key))?.getValue()
  if value?
    logger.debug "Cache hit: #{qry.key}"
    replier {result: JSON.parse(value)}
  else
    logger.info "Cache miss: #{qry.key}"
    replier {result: undefined}

eb.registerHandler 'reitti.cache.put', (data, value) ->
  key = new java.lang.String(data.key)
  val = new java.lang.String(JSON.stringify(data.value))
  element = new Packages.net.sf.ehcache.Element(key, val)
  element.setTimeToLive(data.ttl) if data.ttl?
  cache.put element
