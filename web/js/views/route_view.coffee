define ['jquery', 'underscore', 'backbone', 'utils', 'hbs!template/route_view'], ($, _, Backbone, Utils, template) ->
  
  class RouteView extends Backbone.View
    
    tagName: 'li'
      
    events:
      "click li": "selectLeg"
      "click": "select"
      
    initialize: (@route) ->
      Reitti.Event.on 'route:change', @onRouteChanged
      
    dispose: ->
      Reitti.Event.off 'route:change', @onRouteChanged
      
    render: ->
      @$el.html template
        depTime: Utils.formatTime @_depTime()
        arrTime: Utils.formatTime @_arrTime()
        legs: @_legData()
      this
      
    select: =>
      Reitti.Event.trigger 'route:change', @route
      
    selectLeg: (evt) =>
      @select()
      Reitti.Event.trigger 'leg:change', @route.legs[$(evt.target).data('leg')]
      false
      
    onRouteChanged: (route) =>
      @$el.toggleClass 'selected', route is @route

    _depTime: () ->
      Utils.parseDateTime _.first(_.first(@route.legs).locs).arrTime
      
    _arrTime: () ->
      Utils.parseDateTime _.last(_.last(@route.legs).locs).arrTime
      
    _legData: () ->
      for leg in @route.legs
        {
          type: leg.type
          indicator: if leg.type is 'walk' then Utils.formatDistance(leg.length) else Utils.parseLineCode(leg.type, leg.code)
          color: Utils.transportColors[leg.type]
        }
