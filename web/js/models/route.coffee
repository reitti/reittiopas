define ['jquery', 'underscore', 'backbone', 'models/route_leg'], ($, _, Backbone, RouteLeg) ->

  class Route extends Backbone.Model

    @find: (from, to, transportTypes = 'all', callback) ->
      params = $.param {from: from, to: to, transport_types: transportTypes.join('|')}
      $.getJSON "/routes?#{params}", (data) ->
        callback(new Route(routeData[0]) for routeData in data)

    initialize: (routeData) ->
      @set 'legs', (new RouteLeg(legData) for legData in routeData.legs)

    departureTime: ->
      _.first(@get('legs')).firstArrivalTime()

    arrivalTime: () ->
      _.last(@get('legs')).lastArrivalTime()

    getLeg: (idx) -> @get('legs')[idx]
