require.config
  baseUrl: '/js'
  shim:
    backbone:
      deps: ['underscore', 'jquery']
      exports: 'Backbone'
    backboneAnalytics:
      deps: ['backbone']
    underscore:
      exports: '_'
    handlebars:
      exports: 'Handlebars'
    bootstrap:
      deps: ['jquery']
    modernizr:
      exports: 'Modernizr'
    timepicker:
      deps: ['bootstrap']
    datepicker:
      deps: ['bootstrap']
    datepickerfi:
      deps: ['datepicker']
    datepickersv:
      deps: ['datepicker']
  paths:
    bootstrap: 'lib/bootstrap'
    jquery: 'lib/jquery-1.7.2'
    underscore: 'lib/underscore'
    handlebars: 'lib/handlebars-1.0.0.beta.6'
    backbone: 'lib/backbone'
    backboneLocalStorage: 'lib/backbone.localStorage'
    backboneAnalytics: 'lib/backbone.analytics'
    modernizr: 'lib/modernizr'
    moment: 'lib/moment'
    timepicker: 'lib/bootstrap-timepicker'
    datepicker: 'lib/bootstrap-datepicker'
    datepickerfi: 'lib/bootstrap-datepicker.fi'
    datepickersv: 'lib/bootstrap-datepicker.sv'
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

require [
  'jquery'
  'underscore'
  'backbone'
  'router'
  'settings'
  'position'
  'views/map_view'
  'views/search_view'
  'views/blank_slate_view'
  'views/routes_view'
  'modernizr'
  'bootstrap'
], ($, _, Backbone, Router, Settings, Position, MapView, SearchView, BlankSlateView, RoutesView, Modernizr) ->

  class Reitti.Event extends Backbone.Events
  Reitti.Router = new Router()
  Reitti.Settings = new Settings()
  Reitti.Position = new Position()

  $ ->

    new MapView().render()
    new SearchView().render()
    new BlankSlateView().render()
    new RoutesView().render()

    if Reitti.Settings.get('canWatchPosition')
      Reitti.Position.startWatching()
      
    Backbone.history.start(pushState: true)

    # Inject the Like button after the page has loaded, so it can't delay startup.
    fbLocale = window.appLang.replace('-','_')
    $('.fb-wrap:visible').html '<iframe src="//www.facebook.com/plugins/like.php?locale='+fbLocale+'&href=http%3A%2F%2Fwww.ihanhyv%C3%A4reittiopas.fi&amp;send=false&amp;layout=button_count&amp;width=100&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;font=arial&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:100px; height:21px;" allowTransparency="true"></iframe>'

    # Initialize tooltips
    unless Modernizr.touch
      $('a[rel="tooltip"], button[rel="tooltip"]').tooltip()