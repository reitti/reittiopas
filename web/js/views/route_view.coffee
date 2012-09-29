define ['jquery', 'underscore', 'backbone', 'utils', 'views/route_graph_view', 'hbs!template/route_view', 'i18n!nls/strings'], ($, _, Backbone, Utils, RouteGraphView, template, strings) ->
  class RouteView extends Backbone.View

    tagName: 'li'
    className: 'route'

    events:
      "click a": "select"

    initialize: (routes: routes, routeParams: routeParams, index: index) ->
      @routes = routes
      @routeParams = routeParams
      @index = index

      @route = routes.at(index)
      @graphView = new RouteGraphView(routes: routes, routeParams: routeParams, index: index)
      Reitti.Event.on 'routes:change', @onRoutesChanged

    dispose: ->
      Reitti.Event.off 'routes:change', @onRoutesChanged

    render: ->
      @$el.html template
        strings: strings
        depTime: Utils.formatTimeForHumans(@route.getDepartureTime())
        arrTime: Utils.formatTimeForHumans(@route.getArrivalTime())
        boardingType: strings.boardingLabel[@route.getFirstTransportType()]
        boardingTime: if @route.boardingTime() then Utils.formatTimeForHumans(@route.boardingTime())
        totalWalkingDistance: Utils.formatDistance(@route.getTotalWalkingDistance())
        totalDuration: Utils.formatDuration(@route.get('duration'))
      @graphView.setElement(@$el.find('.route-graph')).render()
      this

    select: =>
      Reitti.Router.navigateToRoutes _.extend(@routeParams, routeIndex: @index, legIndex: undefined)
      false

    _lineCode: () ->
      Utils.parseLineCode _.first()

    onRoutesChanged: (routes, routeParams) =>
      isThis = routes is @routes and routeParams.routeIndex is @index
      @$el.toggleClass 'selected', isThis
      @graphView.onRoutesChanged routes, routeParams



