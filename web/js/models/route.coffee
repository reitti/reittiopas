define ['jquery', 'underscore', 'backbone', 'models/route_leg'], ($, _, Backbone, RouteLeg) ->

  class Route extends Backbone.Model

    @find: (from, to, callback) ->
      params = $.param {from: from, to: to}
      $.getJSON "/routes?#{params}", (data) ->
        callback(new Route(routeData[0]) for routeData in data)

    initialize: (a) ->
      @set 'legs', (new RouteLeg(legData) for legData in a.legs)

    departureTime: ->
      _.first(@get('legs')).firstArrivalTime()

    arrivalTime: () ->
      _.last(@get('legs')).lastArrivalTime()

    getLeg: (idx) -> @get('legs')[idx]
