load('vertx.js');

var webServerConf = {
	port: 8080
};

vertx.deployModule('vertx.web-server-v1.0', webServerConf);