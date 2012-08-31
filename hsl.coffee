load 'vertx.js'

eb = vertx.eventBus
client = vertx.createHttpClient().setHost('api.reittiopas.fi').setMaxPoolSize(3)
hslApiUsername = vertx.env['HSL_API_USERNAME']
hslApiPassword = vertx.env['HSL_API_PASSWORD']
constantQueryParams = "user=#{hslApiUsername}&pass=#{hslApiPassword}&epsg_in=4326&epsg_out=4326"

isCoordinate = (str) ->
  /\d+\.\d+,\d+\.\d+/.test str
   
getNowWithJSONBody = (url, callback) ->
  client.getNow url, (res) ->
    res.bodyHandler (body) ->
      if res.statusCode is 200 and body.length()
        data = JSON.parse body.getString(0, body.length())
        callback data
      else
        callback null

# ToDo: Fix https://github.com/vert-x/vert.x/issues/205 :)

eb.registerHandler 'reitti.hsl.geocode', (query, replier) ->
  if isCoordinate(query)
    replier query
  else
    getNowWithJSONBody "/hsl/prod/?request=geocode&key=#{encodeURIComponent(query)}&#{constantQueryParams}", (json) ->
      if json? and json.length
        replier json[0].coords
      else
        replier null

eb.registerHandler 'reitti.hsl.reverseGeocode', (params, replier) ->
  getNowWithJSONBody "/hsl/prod/?request=reverse_geocode&coordinate=#{encodeURIComponent(params.query)}&#{constantQueryParams}", (json) ->
    if json? and json.length
      replier {name: json[0].name, coords: json[0].coords}
    else
      replier null

eb.registerHandler 'reitti.hsl.findRoutes', (params, replier) ->
  {from: fromPt, to: toPt} = params
  client.getNow "/hsl/prod/?request=route&from=#{fromPt}&to=#{toPt}&detail=full&#{constantQueryParams}", (res) ->
    res.bodyHandler (body) -> replier {body: body.getString(0, body.length())}
