load 'vertx.js'

client = vertx.createHttpClient().setHost('api.reittiopas.fi').setMaxPoolSize(3)
hslApiUsername = vertx.env['HSL_API_USERNAME']
hslApiPassword = vertx.env['HSL_API_PASSWORD']

this.hsl =
  geocode: (query, callback) ->
    client.getNow "/hsl/prod/?request=geocode&key=#{encodeURIComponent(query)}&user=#{hslApiUsername}&pass=#{hslApiPassword}&epsg_out=4326", (res) ->
      res.bodyHandler (body) ->
        if res.statusCode is 200 and body.length()
          data = JSON.parse body.getString(0, body.length())
          if data? and data.length
            callback data[0].coords
          else
            callback null
        else
          callback null

  findRoutes: (fromPt, toPt, writeStream, endCallback) ->
    client.getNow "/hsl/prod/?request=route&from=#{fromPt}&to=#{toPt}&detail=full&user=#{hslApiUsername}&pass=#{hslApiPassword}&epsg_in=4326&epsg_out=4326", (res) ->
      new vertx.Pump(res, writeStream).start()
      res.endHandler(endCallback)
