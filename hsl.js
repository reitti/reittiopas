load('vertx.js');
load('lib/async.js');

var client = vertx.createHttpClient().setHost('api.reittiopas.fi').setMaxPoolSize(3)
  , hslApiUsername = vertx.env['HSL_API_USERNAME']
  , hslApiPassword = vertx.env['HSL_API_PASSWORD'];

var hsl = {

  geocode: function(query, callback) {
    async.waterfall([
      function(callback) {
        client.getNow('/hsl/prod/?request=geocode&key='+query+'&user='+hslApiUsername+'&pass='+hslApiPassword, callback);
      },
      function(res, callback) {
        res.bodyHandler(callback);
      },
      function(body, callback) {
        if (res.statusCode === 200) {
          var data = JSON.parse(body.getString(0, body.length()));
          if (data && data.length > 0) {
            callback(data[0].coords);
          } else {
            callback(null);
          }
        } else {
          callback(null);
        }
      }
    ], callback);
  }

};
