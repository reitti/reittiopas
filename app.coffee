load 'vertx.js'
load 'hsl.coffee'

server = vertx.createHttpServer()
routeMatcher = new vertx.RouteMatcher

routeMatcher.get '/ping', (req) ->
  hsl.geocode 'Kuortaneenkatu', (pt) ->
    req.response.end(JSON.stringify(pong: pt))

# TODO: Might want to disable this in production since files are served by Nginx.
routeMatcher.noMatch (req) ->
  file = '';
  if req.path is '/'
    file = 'index.html';
  else if req.path.indexOf('..') is -1
    file = req.path;
  req.response.sendFile 'web/'+file

server.requestHandler(routeMatcher).listen(8080)
