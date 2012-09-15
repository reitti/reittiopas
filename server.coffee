load 'vertx.js'

eb = vertx.eventBus
server = vertx.createHttpServer()
routeMatcher = new vertx.RouteMatcher

routeMatcher.get '/routes', (req) ->
  req.response.setChunked true
  eb.send 'reitti.geocode', query: req.params().from, (from) ->
    eb.send 'reitti.geocode', query: req.params().to, (to) ->
      if from and to
        params =
          from: from.coords
          to: to.coords
          date: req.params().date
          time: req.params().time
          arrivalOrDeparture: req.params().arrivalOrDeparture
          transportTypes: req.params().transportTypes
        eb.send 'reitti.hsl.findRoutes', params, (data) ->
          req.response.end JSON.stringify(from: from, to: to, routes: data.body)
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
      
routeMatcher.get '/autocomplete', (req) ->
  eb.send 'reitti.searchIndex.find', query: req.params().query, (data) ->
    req.response.end JSON.stringify(itm.name for itm in data.results)

# TODO: Might want to disable this in production since files are served by Nginx.
routeMatcher.noMatch (req) ->
  file = '';
  if req.path is '/'
    file = 'index.html';
  else if req.path.indexOf('..') is -1
    file = req.path;
  req.response.sendFile 'web/'+file

server.requestHandler(routeMatcher).listen 8080

stdout.println "Server started"