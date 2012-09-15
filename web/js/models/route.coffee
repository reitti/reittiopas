define ['jquery', 'underscore', 'backbone', 'utils', 'models/route_leg'], ($, _, Backbone, Utils, RouteLeg) ->
  class Route extends Backbone.Model

    initialize: (routeData) ->
      @set 'legs', (new RouteLeg(legData) for legData in routeData.legs)
      @set 'duration', routeData.duration

    addPreDepartureLeg: (fromTime) ->
      firstLeg = @getLeg(0)
      @get('legs').unshift new RouteLeg
        type: 'pre_departure'
        locs: []
        firstArrivalTime: fromTime
        lastArrivalTime: firstLeg.firstArrivalTime()

    addPostArrivalLeg: (toTime) ->
      lastLeg = _.last(@get('legs'))
      @get('legs').push new RouteLeg
        type: 'post_arrival'
        locs: []
        firstArrivalTime: lastLeg.lastArrivalTime()
        lastArrivalTime: toTime

    getFirstTime: ->
      _.first(@get('legs')).firstArrivalTime()
    
    getLastTime: ->
      _.last(@get('legs')).lastArrivalTime()

    getDepartureTime: ->
      @getFirstLegAfterDeparture().firstArrivalTime()

    getArrivalTime: () ->
      @getLastLegBeforeArrival().lastArrivalTime()

    duration: () ->
      Utils.getDuration @getDepartureTime(), @getArrivalTime()

    durationWithFill: () ->
      Utils.getDuration @getFirstTime(), @getLastTime()

    boardingTime: ->
      @getFirstNonWalkingLeg()?.firstArrivalTime()

    getFirstTransportType: ->
      @getFirstNonWalkingLeg()?.get('type')

    getFirstNonWalkingLeg: ->
      _.find @get('legs'), ((leg) -> !leg.isWalk())

    getFirstLegAfterDeparture: ->
      if @getLeg(0).isFiller() then @getLeg(1) else @getLeg(0)
    getLastLegBeforeArrival: -> 
      lastIdx = @getLegCount() - 1
      if @getLeg(lastIdx).isFiller() then @getLeg(lastIdx - 1) else @getLeg(lastIdx)

    getLeg: (idx) -> @get('legs')[idx]

    getTotalWalkingDistance: () ->
      _.reduce @getWalkLegs(), ((sum, leg) -> sum + leg.get('length')), 0

    getWalkLegs: () ->
      _.select @get('legs'), ((leg) -> leg.isWalk())

    getLegCount: () ->
      @get('legs').length
