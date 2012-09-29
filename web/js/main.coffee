require.config
  baseUrl: '/js'
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
    timepicker:
      deps: ['jquery']
  paths:
    bootstrap: 'lib/bootstrap'
    jquery: 'lib/jquery-1.7.2'
    underscore: 'lib/underscore'
    handlebars: 'lib/handlebars-1.0.0.beta.6'
    backbone: 'lib/backbone'
    moment: 'lib/moment'
    timepicker: 'lib/jquery.timePicker'
    async: 'lib/async'
    hbs: 'lib/hbs'
    i18n: 'lib/i18n'
    template: '../template'
  hbs:
    disableI18n: true
  pragmasOnSave:
    excludeHbsParser : true,
    excludeHbs: true,
    excludeAfterBuild: true

window.Reitti ?= {}

require ['jquery', 'underscore', 'backbone', 'router', 'views/map_view', 'views/search_view', 'views/routes_view', 'nls/set_host_page_strings', 'bootstrap'], ($, _, Backbone, Router, MapView, SearchView, RoutesView, setHostPageStrings) ->
  class Reitti.Event extends Backbone.Events
  Reitti.Router = new Router()

  $ ->

    setHostPageStrings()
    new MapView().render()
    new SearchView().render()
    new RoutesView()
      
    Backbone.history.start(pushState: true)

    if navigator.geolocation
      navigator.geolocation.watchPosition(
        (position) -> Reitti.Event.trigger 'position:change', position,
        () ->,
        { enableHighAccuracy: true})

    $('.fb-wrap:visible').html '<iframe src="//www.facebook.com/plugins/like.php?href=http%3A%2F%2Fwww.ihanhyv%C3%A4reittiopas.fi&amp;send=false&amp;layout=button_count&amp;width=450&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;font=arial&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:450px; height:21px;" allowTransparency="true"></iframe>'
