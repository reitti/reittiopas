load 'vertx.js'

eb = vertx.eventBus
server = vertx.createHttpServer()
routeMatcher = new vertx.RouteMatcher

routeMatcher.get '/routes', (req) ->
  req.response.setChunked true
  eb.send 'reitti.hsl.geocode', req.params().from, (pt1) ->
    eb.send 'reitti.hsl.geocode', req.params().to, (pt2) ->
      if pt1 and pt2
        eb.send 'reitti.hsl.findRoutes', {from: pt1, to: pt2}, (data) -> req.response.end data.body
      else
        req.response.statusCode = 400
        req.response.end JSON.stringify(from: !!pt1, to: !!pt2)

routeMatcher.get '/address', (req) ->
  eb.send 'reitti.hsl.reverseGeocode', query: req.params().coords, (address) ->
    if address
      req.response.end JSON.stringify(address)
    else
      req.response.statusCode = 400
      req.response.end()

# TODO: Might want to disable this in production since files are served by Nginx.
routeMatcher.noMatch (req) ->
  file = '';
  if req.path is '/'
    file = 'index.html';
  else if req.path.indexOf('..') is -1
    file = req.path;
  req.response.sendFile 'web/'+file

server.requestHandler(routeMatcher).listen 8080
