load 'vertx.js'

eb = vertx.eventBus
server = vertx.createHttpServer()
routeMatcher = new vertx.RouteMatcher

isResource = (path) ->
  /^.*\.(css|png|js|html|hbs|manifest|ico)$/.test(path)

filterAjaxOnly = (handler) ->
  (req) ->
    if req.headers()["x-requested-with"] is "XMLHttpRequest"
      handler(req)
    else
      req.response.statusCode = 403
      req.response.end()

routeMatcher.get '/routes', filterAjaxOnly (req) ->
  req.response.putHeader 'Content-Type', 'application/json; charset=utf8'
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
        eb.send 'reitti.findRoutes', params, (data) ->
          req.response.end JSON.stringify(from: from, to: to, routes: data.body)
      else
        req.response.statusCode = 400
        req.response.end JSON.stringify(from: !!from, to: !!to)

routeMatcher.get '/address', filterAjaxOnly (req) ->
  req.response.putHeader 'Content-Type', 'application/json; charset=utf8'
  eb.send 'reitti.hsl.reverseGeocode', query: req.params().coords, (address) ->
    if address
      req.response.end JSON.stringify(address)
    else
      req.response.statusCode = 400
      req.response.end()
      
routeMatcher.get '/autocomplete', filterAjaxOnly (req) ->
  req.response.putHeader 'Content-Type', 'application/json; charset=utf8'
  eb.send 'reitti.searchIndex.find', query: req.params().query, (data) ->
    req.response.end JSON.stringify(itm.name for itm in data.results)

routeMatcher.noMatch (req) ->
  file = '';
  if req.path.indexOf('..') is -1 and isResource(req.path)
    file = req.path
  else
    file = 'index.html'

  req.response.sendFile 'web/'+file

server.requestHandler(routeMatcher).listen 8080

stdout.println "Server started"