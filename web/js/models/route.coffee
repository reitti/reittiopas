define ['jquery', 'underscore', 'backbone', 'utils', 'models/route_leg'], ($, _, Backbone, Utils, RouteLeg) ->
  class Route extends Backbone.Model

    @find: (from, to, date, arrivalOrDeparture = 'departure', transportTypes = 'all', callback) ->
      params = $.param
        from: from
        to: to
        date: Utils.formatDate(date)
        time: Utils.formatHSLTime(date)
        arrivalOrDeparture: arrivalOrDeparture
        transportTypes: transportTypes.join('|')
      $.getJSON "/routes?#{params}", (data) ->
        callback(new Route(routeData[0]) for routeData in data)

    initialize: (routeData) ->
      @set 'legs', (new RouteLeg(legData) for legData in routeData.legs)

    departureTime: ->
      _.first(@get('legs')).firstArrivalTime()

    arrivalTime: () ->
      _.last(@get('legs')).lastArrivalTime()

    boardingTime: ->
      @getFirstNonWalkingLeg()?.firstArrivalTime()

    getFirstTransportType: ->
      @getFirstNonWalkingLeg()?.get('type')

    getFirstNonWalkingLeg: ->
      _.find @get('legs'), ((leg) -> !leg.isWalk())

    getLeg: (idx) -> @get('legs')[idx]

    getLegDurationPercentage: (idx) ->
      Math.floor @getLeg(idx).get('duration') * 100 / @getTotalDuration()

    # Total duration of legs is _not_ the same as the duration attribute
    getTotalDuration: () ->
      @_totalDuration ?= _.reduce @getLegDurations(), ((sum, dur) -> sum + dur), 0

    getTotalWalkingDistance: () ->
      _.reduce @getWalkLegs(), ((sum, leg) -> sum + leg.get('length')), 0

    getWalkLegs: () ->
      _.select @get('legs'), ((leg) -> leg.isWalk())

    getLegDurations: () ->
      leg.get('duration') for leg in @get('legs')

    getLegCount: () ->
      @get('legs').length