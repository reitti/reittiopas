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
    bootstrap: 'lib/bootstrap',
    jquery: 'lib/jquery-1.7.2',
    underscore: 'lib/underscore',
    backbone: 'lib/backbone',
    text: 'lib/text',
    async: 'lib/async',
    templates: '../templates'
  }
});

require(['jquery', 'underscore', 'backbone', 'router', 'bootstrap'], function ($, _, Backbone, Router) {

  window.EventBus = _.extend({}, Backbone.Events);

  $(function () {
    // Update location every 5 seconds
    (function run() {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function (position) {
          EventBus.trigger('position:updated', position);
        }, function () {
        }, {enableHighAccuracy: true, maximumAge: 2500});
      }
      setTimeout(run, 5000);
    })();

    window.Router = new Router();
    Backbone.history.start();
  });
});
