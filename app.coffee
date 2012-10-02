vertx = require 'vertx'

# Vert.x (1.2.3.final) fscks up the CoffeeScript compiler if you try to deploy 
# coffee vertices in parallel, hence the chain.

vertx.deployModule 'ml.redis-client-v0.3'

vertx.deployWorkerVerticle 'cache.coffee', null, 1, ->
  vertx.deployWorkerVerticle 'search_index/search_index.coffee', null, 1, ->
    vertx.deployVerticle 'server.coffee'
