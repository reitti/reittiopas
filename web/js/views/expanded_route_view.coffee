define ['jquery', 'backbone', 'handlebars', 'utils', 'views/route_graph_sizer', 'views/next_previous_route_button_view', 'hbs!template/expanded_route_view',  'i18n!nls/strings'], ($, Backbone, Handlebars, Utils, routeGraphSizer, NextPreviousRouteButtonView, template, strings) ->

  MINIMUM_HEIGHT = 45

  class ExpandedRouteView extends Backbone.View

    el: $('#expanded-route')

    events:
      'click .from-loc': 'onFromLocationClicked'
      'click .to-loc': 'onToLocationClicked'
      'click': 'onClicked'

    initialize: () ->
      Reitti.Event.on 'routes:change', @onRoutesChanged

    onRoutesChanged: (routes, @routeParams) =>
      if routeParams.routeIndex? and (routeParams.routeIndex isnt @index or @routes isnt routes)
        @$el.empty()
        @routes = routes
        @index = routeParams.routeIndex
        @render()
        @_scrollToRoute()

    render: ->
      route = @routes.at(@index)
      @$el.empty()
      @$el.append(new NextPreviousRouteButtonView(routes: @routes, routeParams: @routeParams, index: @index, loc: 'above').render().el)
      @$el.append template
        legs: @_legData()
        strings: strings
        depTime: Utils.formatTimeForHumans(route.getDepartureTime())
        arrTime: Utils.formatTimeForHumans(route.getArrivalTime())
        boardingType: strings.boardingLabel[route.getFirstTransportType()]
        boardingTime: if route.boardingTime() then Utils.formatTimeForHumans(route.boardingTime())
        boardingColor: Utils.transportColors[route.getFirstTransportType()]
        totalWalkingDistance: Utils.formatDistance(route.getTotalWalkingDistance())
        totalDuration: Utils.formatDuration(route.get('duration'))
      @$el.append(new NextPreviousRouteButtonView(routes: @routes, routeParams: @routeParams, index: @index, loc: 'below').render().el)
      this

    _legData: () ->
      sizes = routeGraphSizer(@routes, @index, 420, MINIMUM_HEIGHT)
      for leg, legIdx in @routes.at(@index).get('legs')
        {size, sizeBefore} = sizes[legIdx]
        {
          type: leg.get('type')
          transport: @_transport(leg)
          transportColor: Utils.transportColors[leg.get('type')]
          depTime: Utils.formatTimeForHumans(leg.firstArrivalTime())
          arrTime: Utils.formatTimeForHumans(leg.lastArrivalTime())
          from: leg.originName()
          to: leg.destinationName()
          duration: Utils.formatDuration(leg.get('duration'))
          highFloored: leg.get('highFloored')
          height: size
          heightBefore: sizeBefore
          last: legIdx is @routes.at(@index).getLegCount() - 1
          strings: strings
        }

    _transport: (leg) ->
      label = strings.transportType[leg.get('type')]
      html = switch leg.get('type')
        when 'walk' then "#{label}, #{Utils.formatDistance(leg.get('length'))}"
        when '6', '7' then "<strong>#{label}</strong>"
        when '12' then "<strong>#{leg.lineName()}-#{label}</strong>"
        else "#{label} <strong>#{leg.lineName()}</strong>"
      new Handlebars.SafeString html

    onFromLocationClicked: (evt) =>
      @_onNavigate evt, 'origin'

    onToLocationClicked: (evt) =>
      @_onNavigate evt, 'destination'

    onClicked: (evt) =>
      @_onNavigate evt

    _onNavigate: (evt, originOrDestination) ->
      legIndex = $(evt.target).closest('[data-leg]').data('leg')
      Reitti.Router.navigateToRoutes _.extend(@routeParams, legIndex: legIndex, originOrDestination: originOrDestination)
      false

    _scrollToRoute: ->
      setTimeout((=> @$el.offsetParent().animate({scrollTop: 0}, 200)), 100)

