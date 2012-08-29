"use strict";

require.config({
  shim: {
    backbone: {
      deps: ['underscore', 'jquery'],
      exports: 'Backbone'
    },
    underscore: {
      exports: '_'
    }
  },
  paths: {
    jquery: 'lib/jquery-1.7.2',
    underscore: 'lib/underscore',
    backbone: 'lib/backbone',
    text: 'lib/text',
    templates: '../templates'
  }
});

require(['jquery', 'underscore', 'router', 'map'], function($, _, AppRouter) {
  $(function () {
    window.Router = new AppRouter();
    Backbone.history.start();
  });
});
