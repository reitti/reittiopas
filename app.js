load('vertx.js');

var server = vertx.createHttpServer()
  , routeMatcher = new vertx.RouteMatcher()
  , client = vertx.createHttpClient().setHost('api.reittiopas.fi').setMaxPoolSize(3)
  , hslApiUsername = vertx.env['HSL_API_USERNAME']
  , hslApiPassword = vertx.env['HSL_API_PASSWORD'];

// --- HSL API calls ---

// TODO: The API calls should probably be in a separate module (or "vertex"?)
var hsl = {
  geocode: function(query, callback) {
    client.getNow('/hsl/prod/?request=geocode&key='+query+'&user='+hslApiUsername+'&pass='+hslApiPassword, function(res) {
      res.bodyHandler(function(body) {
        if (res.statusCode == 200) {
          var data = JSON.parse(body.getString(0, body.length()));
          if (data && data.length > 0) {
            callback(data[0].coords);
          } else {
            callback(null);
          }
        } else {
          callback(null);
        }
      });
    });
  }
}


// --- Routes ---

routeMatcher.get('/ping', function(req) {
  hsl.geocode('Kuortaneenkatu', function(pt) {
      req.response.end(JSON.stringify({pong: pt}));
  })
});

// TODO: Might want to disable this in production since files are served by Nginx.
routeMatcher.noMatch(function(req) {
  var file = '';
  if (req.path == '/') {
    file = 'index.html';
  } else if (req.path.indexOf('..') == -1) {
    file = req.path;
  }
  req.response.sendFile('web/' + file);
});

// --- Server launch ---

server.requestHandler(routeMatcher).listen(8080);
