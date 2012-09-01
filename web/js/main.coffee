require.config
  shim:
    backbone:
      deps: ['underscore', 'jquery']
      exports: 'Backbone'
    underscore:
      exports: '_'
    handlebars:
      exports: 'Handlebars'
    bootstrap:
      deps: ['jquery']
  paths:
    bootstrap: 'lib/bootstrap'
    jquery: 'lib/jquery-1.7.2'
    underscore: 'lib/underscore'
    handlebars: 'lib/handlebars-1.0.0.beta.6'
    backbone: 'lib/backbone'
    text: 'lib/text'
    async: 'lib/async'
    templates: '../templates'

window.Reitti ?= {}

require ['jquery', 'underscore', 'backbone', 'router', 'bootstrap'], ($, _, Backbone, Router) ->

  class Reitti.Event extends Backbone.Events
  Reitti.Router = new Router()
  Backbone.history.start()

  $ ->
    if navigator.geolocation
      navigator.geolocation.watchPosition (position) -> 
        Reitti.Event.trigger 'position:change', position
