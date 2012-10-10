define ['underscore', 'backbone', 'utils', 'views/route_graph_sizer', 'hbs!template/route_graph', 'i18n!nls/strings'], (_, Backbone, Utils, routeGraphSizer, template, strings) ->

  MINIMUM_WIDTH = 25

  class RouteGraphView extends Backbone.View

    initialize: (routes: routes, routeParams: routeParams, index: index) ->
      @routes = routes
      @routeParams = routeParams
      @index = index
      @route = routes.at(@index)

    render: ->
      @$el.html template(legs: @_legData())
      this

    _legData: () ->
      sizes = routeGraphSizer(@routes, @index, @_availableWidth(), MINIMUM_WIDTH)
      for leg, legIdx in @route.get('legs')
        {size, sizeBefore} = sizes[legIdx]
        {
          type: leg.get('type')
          indicator: @_legIndicator(leg)
          highFloored: leg.get('highFloored')
          width: size
          widthBefore: sizeBefore
          strings: strings
        }

    _availableWidth: ->
      @$el.parent().width() - Utils.getScrollBarWidth()

    _legIndicator: (leg) ->
      switch leg.get('type')
        when 'walk' then ''
        else leg.lineName()

