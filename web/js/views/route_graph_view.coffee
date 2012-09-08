define ['backbone', 'utils', 'hbs!template/route_graph'], (Backbone, Utils, template) ->

  class RouteGraphView extends Backbone.View

    events:
      'click li': 'selectLeg'

    initialize: (@route) ->

    render: ->
      @$el.html template(legs: @_legData())
      this

    selectLeg: (evt) =>
      legIndex = $(evt.target).closest('[data-leg]').data('leg')
      Reitti.Event.trigger 'route:change', @route
      Reitti.Event.trigger 'leg:change', @route.getLeg(legIndex)
      false

    _legData: () ->
      for leg,idx in @route.get('legs')
        {
        type: leg.get('type')
        indicator: if leg.isWalk() then Utils.formatDistance(leg.get('length')) else leg.lineName()
        color: Utils.transportColors[leg.get('type')]
        percentage: @route.getLegDurationPercentage(idx)
        last: if idx is @route.getLegCount() - 1 then 'last' else ''
        }
