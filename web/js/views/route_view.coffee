define ['jquery', 'underscore', 'backbone', 'utils', 'hbs!template/route_view'], ($, _, Backbone, Utils, template) ->
  class RouteView extends Backbone.View

    tagName: 'li'
    className: 'route'

    events:
      "click ol li": "selectLeg"
      "click a": "select"

    initialize: (@route) ->
      Reitti.Event.on 'route:change', @onRouteChanged

    dispose: ->
      Reitti.Event.off 'route:change', @onRouteChanged

    render: ->
      @$el.html template
        depTime: Utils.formatTime(@route.departureTime())
        arrTime: Utils.formatTime(@route.arrivalTime())
        legs: @_legData()
      this

    select: =>
      Reitti.Event.trigger 'route:change', @route
      false

    selectLeg: (evt) =>
      @select()
      Reitti.Event.trigger 'leg:change', @route.legs[$(evt.target).closest('[data-leg]').data('leg')]
      false

    _lineCode: () ->
      Utils.parseLineCode _.first()

    onRouteChanged: (route) =>
      @$el.toggleClass 'selected', route is @route

    _legData: () ->
      for leg in @route.get('legs')
        {
        type: leg.type
        indicator: if leg.type is 'walk' then Utils.formatDistance(leg.length) else Utils.parseLineCode(leg.type, leg.code)
        color: Utils.transportColors[leg.type]
        }
