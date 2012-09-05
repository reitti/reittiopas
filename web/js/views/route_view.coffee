define ['jquery', 'underscore', 'backbone', 'utils', 'views/route_graph_view', 'hbs!template/route_view'], ($, _, Backbone, Utils, RouteGraphView, template) ->
  class RouteView extends Backbone.View

    tagName: 'li'
    className: 'route'

    events:
      "click a": "select"

    initialize: (@route) ->
      @graphView = new RouteGraphView(@route)
      Reitti.Event.on 'route:change', @onRouteChanged

    dispose: ->
      Reitti.Event.off 'route:change', @onRouteChanged

    render: ->
      @$el.html template
        depTime: Utils.formatTime(@route.departureTime())
        arrTime: Utils.formatTime(@route.arrivalTime())
      @graphView.setElement(@$el.find('.leg-icons')).render()
      this

    select: =>
      Reitti.Event.trigger 'route:change', @route
      false

    _lineCode: () ->
      Utils.parseLineCode _.first()

    onRouteChanged: (route) =>
      @$el.toggleClass 'selected', route is @route

