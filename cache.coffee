load 'vertx.js'

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
  logger.debug if value? then "Cache hit: #{qry.key}" else "Cache miss: #{qry.key}"
  replier {result: value}

eb.registerHandler 'reitti.cache.put', (data, value) ->
  cache.put new Packages.net.sf.ehcache.Element(new java.lang.String(data.key), new java.lang.String(data.value))
