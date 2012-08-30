load 'vertx.js'
load 'hsl.coffee'

server = vertx.createHttpServer()
routeMatcher = new vertx.RouteMatcher

routeMatcher.get '/routes', (req) ->
  req.response.setChunked true
  hsl.geocode req.params().from, (pt1) -> # The geocoding requests could be done in parallel
    hsl.geocode req.params().to, (pt2) ->
      if pt1 and pt2
        hsl.findRoutes pt1, pt2, req.response, req.response.end
      else
        req.response.statusCode = 400
        req.response.end(JSON.stringify({from: !!pt1, to: !!pt2}))

# TODO: Might want to disable this in production since files are served by Nginx.
routeMatcher.noMatch (req) ->
  file = '';
  if req.path is '/'
    file = 'index.html';
  else if req.path.indexOf('..') is -1
    file = req.path;
  req.response.sendFile 'web/'+file

server.requestHandler(routeMatcher).listen(8080)
