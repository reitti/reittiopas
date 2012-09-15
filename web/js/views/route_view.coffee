define ['jquery', 'underscore', 'backbone', 'utils', 'views/route_graph_view', 'hbs!template/route_view'], ($, _, Backbone, Utils, RouteGraphView, template) ->
  class RouteView extends Backbone.View

    tagName: 'li'
    className: 'route'

    events:
      "click a": "select"

    initialize: (routes: routes, index: index) ->
      @route = routes.at(index)
      @graphView = new RouteGraphView(routes: routes, index: index)
      Reitti.Event.on 'route:change', @onRouteChanged

    dispose: ->
      Reitti.Event.off 'route:change', @onRouteChanged

    render: ->
      @$el.html template
        depTime: Utils.formatTime(@route.getDepartureTime())
        arrTime: Utils.formatTime(@route.getArrivalTime())
        boardingType: @_boardingLabel(@route.getFirstTransportType())
        boardingTime: Utils.formatTime(@route.boardingTime())
        totalWalkingDistance: Utils.formatDistance(@route.getTotalWalkingDistance())
        totalDuration: Utils.formatDuration(@route.get('duration'))
      @graphView.setElement(@$el.find('.route-graph')).render()
      this

    select: =>
      Reitti.Event.trigger 'route:change', @route
      false

    _lineCode: () ->
      Utils.parseLineCode _.first()

    # TODO: This should be somewhere in i18n
    _boardingLabel: (type) ->
      switch type
        when '2' then "Ratikkaan"
        when '6' then "Metroon"
        when '7' then "Lauttaan"
        when '12' then "Junaan"
        else "Bussiin"

    onRouteChanged: (route) =>
      @$el.toggleClass 'selected', route is @route


