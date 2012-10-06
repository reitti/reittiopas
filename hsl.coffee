vertx = require 'vertx'

logger = vertx.logger;
client = vertx.createHttpClient().setHost('api.reittiopas.fi').setMaxPoolSize(3)
hslApiUsername = vertx.env['HSL_API_USERNAME']
hslApiPassword = vertx.env['HSL_API_PASSWORD']

getHslQueryString = (request, params) ->
  qry = "/hsl/prod/?request=#{request}&user=#{hslApiUsername}&pass=#{hslApiPassword}&epsg_in=4326&epsg_out=4326"
  for own k,v of params
    qry += "&#{k}=#{encodeURIComponent(v)}"
  qry

hslRequest = (request, params, callback) ->
  qryString = getHslQueryString(request, params)
  logger.info "HSL outgoing: #{qryString}"
  client.getNow qryString, (res) ->
    res.bodyHandler (body) -> callback(res, body)
    
hslRequestWithJSONRes = (request, params, callback) ->
  hslRequest request, params, (res, body) ->
    if res.statusCode is 200 and body.length()
      data = JSON.parse body.getString(0, body.length())
      callback data
    else
      callback null

module.exports =

  geocode: (query, callback) ->
    hslRequestWithJSONRes 'geocode', {key: query}, (json) ->
      if json? and json.length
        callback json[0]
      else
        callback null

  reverseGeocode: (coords, callback) ->
    hslRequestWithJSONRes 'reverse_geocode', {coordinate: coords, radius: 200}, (json) ->
      if json? and json.length
        callback {name: json[0].name, coords: json[0].coords}
      else
        callback {name: null, coords: coords}

  findRoutes: (params, callback) ->
    params =
      from: params.from
      to: params.to
      date: params.date
      time: params.time
      detail: 'full'
      show: 5
      timetype: params.arrivalOrDeparture or 'departure'
      transport_types: params.transportTypes or 'all'
    hslRequest 'route', params, (res, body) ->
      callback {body: JSON.parse(body.getString(0, body.length()))}
