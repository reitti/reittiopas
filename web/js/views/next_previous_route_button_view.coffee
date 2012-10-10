define ['backbone', 'hbs!template/more_routes_button', 'i18n!nls/strings'], (Backbone, template, strings) ->

  class NextPreviousRouteButtonView extends Backbone.View

    tagName: 'li'
    className: 'more'

    events:
      'click a': 'onClicked'

    initialize: ({@routes, @routeParams, @index, @loc}) ->

    render: ->
      icon = if @loc is 'above' then 'chevron-up' else 'chevron-down'
      label = if @loc is 'above'
        if @routes.isBasedOnArrivalTime() then strings.laterArrival else strings.earlierDeparture
      else
        if @routes.isBasedOnArrivalTime() then strings.earlierArrival else strings.laterDeparture
      @$el.html(template(icon: icon, label: label, strings: strings))
      this

    onClicked: =>
      @$el.find('.normal').hide()
      @$el.find('.refreshing').show()
      if @loc is 'above' then @onClickedAbove() else @onClickedBelow()
      false

    onClickedAbove: =>
      if @routes.isBasedOnArrivalTime()
        @_navigateToRouteOrGetMore @routes.getLaterRouteIndex(@index), @routes.loadMoreLater, @onClickedAbove
      else
        @_navigateToRouteOrGetMore @routes.getEarlierRouteIndex(@index), @routes.loadMoreEarlier, @onClickedAbove

    onClickedBelow: =>
      if @routes.isBasedOnArrivalTime()
        @_navigateToRouteOrGetMore @routes.getEarlierRouteIndex(@index), @routes.loadMoreEarlier, @onClickedBelow
      else
        @_navigateToRouteOrGetMore @routes.getLaterRouteIndex(@index), @routes.loadMoreLater, @onClickedBelow

    _navigateToRouteOrGetMore: (idx, moreFn, retryFn) ->
      if idx >= 0
        Reitti.Router.navigateToRoutes _.extend(@routeParams, routeIndex: idx, legIndex: undefined, originOrDestination: undefined)
      else
        moreFn.call @routes, (success) -> if success then retryFn.call(this)

