load 'vertx.js'

client = vertx.createHttpClient().setHost('api.reittiopas.fi').setMaxPoolSize(3)
hslApiUsername = vertx.env['HSL_API_USERNAME']
hslApiPassword = vertx.env['HSL_API_PASSWORD']
constantQueryParams = "user=#{hslApiUsername}&pass=#{hslApiPassword}&epsg_in=4326&epsg_out=4326"

getNowWithJSONBody = (url, callback) ->
  client.getNow url, (res) ->
    res.bodyHandler (body) ->
      if res.statusCode is 200 and body.length()
        data = JSON.parse body.getString(0, body.length())
        callback data
      else
        callback null

this.hsl =
  geocode: (query, callback) ->
    getNowWithJSONBody "/hsl/prod/?request=geocode&key=#{encodeURIComponent(query)}&#{constantQueryParams}", (json) ->
      if json? and json.length
        callback json[0].coords
      else
        callback null

  reverseGeocode: (query, callback) ->
    getNowWithJSONBody "/hsl/prod/?request=reverse_geocode&coordinate=#{encodeURIComponent(query)}&#{constantQueryParams}", (json) ->
      if json? and json.length
        callback {name: json[0].name, coords: json[0].coords}
      else
        callback null

  findRoutes: (fromPt, toPt, writeStream, endCallback) ->
    client.getNow "/hsl/prod/?request=route&from=#{fromPt}&to=#{toPt}&detail=full&#{constantQueryParams}", (res) ->
      new vertx.Pump(res, writeStream).start()
      res.endHandler(endCallback)
