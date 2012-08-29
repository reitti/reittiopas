load 'vertx.js'

client = vertx.createHttpClient().setHost('api.reittiopas.fi').setMaxPoolSize(3)
hslApiUsername = vertx.env['HSL_API_USERNAME']
hslApiPassword = vertx.env['HSL_API_PASSWORD']

this.hsl =
  geocode: (query, callback) ->
    client.getNow "/hsl/prod/?request=geocode&key=#{query}&user=#{hslApiUsername}&pass=#{hslApiPassword}", (res) ->
      res.bodyHandler (body) ->
        if res.statusCode is 200
          data = JSON.parse body.getString(0, body.length())
          if data? and data.length
            callback data[0].coords
          else
            callback null
        else
          callback null
