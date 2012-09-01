load 'vertx.js'

eb = vertx.eventBus
client = vertx.createHttpClient().setHost('api.reittiopas.fi').setMaxPoolSize(3)
hslApiUsername = vertx.env['HSL_API_USERNAME']
hslApiPassword = vertx.env['HSL_API_PASSWORD']

getHslQueryString = (request, params) ->
  qry = "/hsl/prod/?request=#{request}&user=#{hslApiUsername}&pass=#{hslApiPassword}&epsg_in=4326&epsg_out=4326"
  qry += "&#{k}=#{encodeURIComponent(v)}" for own k,v of params    
  
hslRequest = (request, params, callback) ->
  client.getNow getHslQueryString(request, params), (res) ->
    res.bodyHandler (body) -> callback(res, body)
    
hslRequestWithJSONRes = (request, params, callback) ->
  hslRequest request, params, (res, body) ->
    if res.statusCode is 200 and body.length()
      data = JSON.parse body.getString(0, body.length())
      callback data
    else
      callback null

# ToDo: Fix https://github.com/vert-x/vert.x/issues/205 :)

eb.registerHandler 'reitti.hsl.geocode', (query, replier) ->
  hslRequestWithJSONRes 'geocode', {key: query}, (json) ->
    if json? and json.length
      replier json[0].coords
    else
      replier null

eb.registerHandler 'reitti.hsl.reverseGeocode', (params, replier) ->
  hslRequestWithJSONRes 'reverse_geocode', {coordinate: params.query}, (json) ->
    if json? and json.length
      replier {name: json[0].name, coords: json[0].coords}
    else
      replier null

eb.registerHandler 'reitti.hsl.findRoutes', (params, replier) ->
  hslRequest 'route', {from: params.from, to: params.to, detail: 'full'}, (res, body) ->
    replier {body: body.getString(0, body.length())}
