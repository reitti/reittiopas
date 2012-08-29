load('vertx.js');
load('hsl.js');

var server = vertx.createHttpServer()
  , routeMatcher = new vertx.RouteMatcher();


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
