define ['backbone', 'utils', 'hbs!template/route_graph'], (Backbone, Utils, template) ->

  class RouteGraphView extends Backbone.View

    events:
      'click li': 'selectLeg'

    initialize: (routes: routes, index: index) ->
      @routes = routes
      @index = index
      @route = routes.getRoute(@index)

    render: ->
      @$el.html template
        legs: @_legData()
        percentageBeforeDeparture: @routes.getDurationPercentageBeforeDeparture(@index)
      this

    selectLeg: (evt) =>
      legIndex = $(evt.target).closest('[data-leg]').data('leg')
      Reitti.Event.trigger 'route:change', @route
      Reitti.Event.trigger 'leg:change', @route.getLeg(legIndex)
      false

    _legData: () ->
      for leg,legIdx in @route.get('legs')
        percentage = @routes.getLegDurationPercentage(@index, legIdx)
        {
        type: leg.get('type')
        indicator: if leg.isWalk() then "" else leg.lineName()
        color: Utils.transportColors[leg.get('type')]
        percentage: percentage
        iconVisible: percentage > 4
        last: if legIdx is @route.getLegCount() - 1 then 'last' else ''
        }
