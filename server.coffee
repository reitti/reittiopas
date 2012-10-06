vertx      = require 'vertx'
_          = require 'web/js/lib/underscore'
async      = require 'lib/async'
geocode    = require 'geocode'
findRoutes = require 'find_routes'
hsl        = require 'hsl'
validation = require 'validation'

strings =
  'en-US': require 'nls/en-us/strings'
  'fi-FI':  require 'nls/root/strings'
supportedLocales = _.keys(strings)

port = parseInt(vertx.env['REITTIOPAS_PORT'] or 8080, 10)
 
eb = vertx.eventBus
server = vertx.createHttpServer()
routeMatcher = new vertx.RouteMatcher
helsinkiTimezone = java.util.TimeZone.getTimeZone("Europe/Helsinki")

indexTemplateSource = vertx.fileSystem.readFileSync("web/template/index.hbs")
indexTemplate = new com.github.jknack.handlebars.Handlebars().compile(indexTemplateSource.getString(0, indexTemplateSource.length()))

isResource = (path) ->
  /^.*\.(css|png|js|html|hbs|manifest|ico)$/.test(path)

filterAjaxOnly = (handler) ->
  (req) ->
    if req.headers()["x-requested-with"] is "XMLHttpRequest"
      handler(req)
    else
      req.response.statusCode = 403
      req.response.end()

routeMatcher.get '/routes', filterAjaxOnly validation.validateGetRoutes (req) ->
  req.response.putHeader 'Content-Type', 'application/json; charset=utf-8'
  geocodeFrom = (cb) -> geocode req.params().from, (r) -> cb(null, r)
  geocodeTo =  (cb) -> geocode req.params().to, (r) -> cb(null, r)
  async.parallel {from: geocodeFrom, to: geocodeTo}, (error, {from,to}) ->
    if from? and to?
      params =
        from: from.coords
        to: to.coords
        date: req.params().date
        time: req.params().time
        arrivalOrDeparture: req.params().arrivalOrDeparture
        transportTypes: req.params().transportTypes
      findRoutes params, (data) ->
        req.response.end JSON.stringify(from: from, to: to, routes: data.body)
    else
      req.response.statusCode = 400
      req.response.end JSON.stringify(from: !!from, to: !!to)

routeMatcher.get '/address', filterAjaxOnly validation.validateGetAddress (req) ->
  req.response.putHeader 'Content-Type', 'application/json; charset=utf-8'
  hsl.reverseGeocode req.params().coords, (addressOrCoordinates) ->
    if addressOrCoordinates
      req.response.end JSON.stringify(addressOrCoordinates)
    else
      req.response.statusCode = 400
      req.response.end()

routeMatcher.get '/autocomplete', filterAjaxOnly validation.validateAutocomplete (req) ->
  req.response.putHeader 'Content-Type', 'application/json; charset=utf-8'
  eb.send 'reitti.searchIndex.find', query: req.params().query, (data) ->
    req.response.end JSON.stringify(itm.name for itm in data.results)

routeMatcher.noMatch (req) ->
  if req.path.indexOf('..') is -1 and isResource(req.path)
    req.response.sendFile 'web/'+req.path
  else
    locale = req.params().locale
    unless _.contains(supportedLocales, locale)
      locale = 'fi-FI'

    tzOffset = helsinkiTimezone.getOffset(new java.util.Date().getTime())
    blankSlateActive = !/blankSlateDismissed/.test(req.headers()['cookie'])
    blankSlateHidden = !blankSlateActive or (req.path isnt '' and req.path isnt '/')

    req.response.putHeader 'Content-Type', 'text/html; charset=utf-8'
    req.response.end indexTemplate.apply
      timezoneOffset: tzOffset
      locale: locale
      strings: strings[locale]
      blankSlateActive: blankSlateActive
      blankSlateHidden: blankSlateHidden

server.requestHandler(routeMatcher).listen port

stdout.println "Server started"
