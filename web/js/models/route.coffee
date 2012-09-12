define ['jquery', 'underscore', 'backbone', 'utils', 'models/route_leg'], ($, _, Backbone, Utils, RouteLeg) ->
  class Route extends Backbone.Model

    initialize: (from, to, routeData) ->
      @set 'from', from
      @set 'to', to
      @set 'legs', (new RouteLeg(legData) for legData in routeData.legs)
      @set 'duration', routeData.duration

    addPreDepartureLeg: (fromTime) ->
      firstLeg = @getLeg(0)
      @get('legs').unshift new RouteLeg
        type: 'pre_departure'
        locs: []
        firstArrivalTime: fromTime
        lastArrivalTime: firstLeg.firstArrivalTime()

    getFirstTime: ->
      _.first(@get('legs')).firstArrivalTime()
      
    getDepartureTime: ->
      @getFirstLegAfterDeparture().firstArrivalTime()

    getArrivalTime: () ->
      _.last(@get('legs')).lastArrivalTime()

    duration: () ->
      Utils.getDuration @getDepartureTime(), @getArrivalTime()

    durationFromPreDeparture: () ->
      Utils.getDuration @getFirstTime(), @getArrivalTime()

    boardingTime: ->
      @getFirstNonWalkingLeg()?.firstArrivalTime()

    getFirstTransportType: ->
      @getFirstNonWalkingLeg()?.get('type')

    getFirstNonWalkingLeg: ->
      _.find @get('legs'), ((leg) -> !leg.isWalk())

    getFirstLegAfterDeparture: ->
      _.find @get('legs'), ((leg) -> !leg.isPreDeparture())

    getLeg: (idx) -> @get('legs')[idx]

    getTotalWalkingDistance: () ->
      _.reduce @getWalkLegs(), ((sum, leg) -> sum + leg.get('length')), 0

    getWalkLegs: () ->
      _.select @get('legs'), ((leg) -> leg.isWalk())

    getLegCount: () ->
      @get('legs').length