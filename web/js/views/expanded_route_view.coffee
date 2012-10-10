define ['jquery', 'backbone', 'handlebars', 'utils', 'views/route_graph_sizer', 'hbs!template/expanded_route_view',  'i18n!nls/strings'], ($, Backbone, Handlebars, Utils, routeGraphSizer, template, strings) ->

  MINIMUM_HEIGHT = 45

  class ExpandedRouteView extends Backbone.View

    el: $('#expanded-route')

    events:
      'click .from-loc': 'onFromLocationClicked'
      'click .to-loc': 'onToLocationClicked'
      'click': 'onClicked'

    initialize: () ->
      Reitti.Event.on 'routes:change', @onRoutesChanged

    onRoutesChanged: (@routes, @routeParams) =>
      if routeParams.routeIndex?
        @$el.empty()
        @index = routeParams.routeIndex
        @render()
        @_scrollToRoutes()

    render: ->
      @$el.html template(legs: @_legData())
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
          height: size
          heightBefore: sizeBefore
          last: legIdx is @routes.at(@index).getLegCount() - 1
        }

    _transport: (leg) ->
      label = strings.transportType[leg.get('type')]
      html = switch leg.get('type')
        when 'walk' then "#{label}, #{Utils.formatDistance(leg.get('length'))}"
        when '6', '7' then "<strong>label</strong>"
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

    _scrollToRoutes: ->
      setTimeout((=> @$el.offsetParent().animate({scrollTop: @$el.offset().top }, 200)), 100)

