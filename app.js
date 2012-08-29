load('vertx.js');

var server = vertx.createHttpServer(),
    routeMatcher = new vertx.RouteMatcher();

routeMatcher.get('/ping', function(req) {
  req.response.end(JSON.stringify({pong: new Date()}));
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


server.requestHandler(routeMatcher).listen(8080);
