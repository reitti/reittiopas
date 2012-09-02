define ['jquery', 'underscore', 'backbone', 'utils', 'hbs!templates/route_view'], ($, _, Backbone, Utils, template) ->
  
  class RouteView extends Backbone.View
    
    tagName: 'li'
      
    events:
      "click": "select"
      
    initialize: (@route, @idx) ->
      Reitti.Event.on 'route:select', @onRouteSelected
      
    dispose: ->
      Reitti.Event.off 'route:select', @onRouteSelected
      
    render: ->
      @$el.html template
        depTime: Utils.formatTime @_depTime()
        arrTime: Utils.formatTime @_arrTime()
      this
      
    select: ->
      Reitti.Event.trigger 'route:select', @idx
      
    onRouteSelected: (idx) =>
      @$el.toggleClass 'active', idx is @idx

    _depTime: () ->
      Utils.parseDateTime _.first(_.first(@route.legs).locs).arrTime
      
    _arrTime: () ->
      Utils.parseDateTime _.last(_.last(@route.legs).locs).arrTime