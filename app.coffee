load 'vertx.js'

# Vert.x (1.2.3.final) fscks up the CoffeeScript compiler if you try to deploy 
# coffee vertices in parallel, hence the chain.

vertx.deployVerticle 'hsl.coffee', null, 1, ->
  vertx.deployVerticle 'server.coffee'
