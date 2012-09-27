define ['jquery', 'underscore', 'backbone', 'utils', 'models/route_leg'], ($, _, Backbone, Utils, RouteLeg) ->
  class Route extends Backbone.Model

    initialize: (from, to, routeData) ->
      @set 'legs', (new RouteLeg(legData) for legData in routeData.legs)
      @set 'duration', routeData.duration
      _.first(@get 'legs').set 'originName', from
      _.last(@get 'legs').set 'destinationName', to

    getDepartureTime: ->
      @getLeg(0).firstArrivalTime()

    getArrivalTime: () ->
      @lastLeg().lastArrivalTime()

    duration: () ->
      Utils.getDuration @getDepartureTime(), @getArrivalTime()

    boardingTime: ->
      @getFirstNonWalkingLeg()?.firstArrivalTime()

    lastLeg: () ->
      @getLeg(@getLegCount() - 1)

    longestLeg: () ->
      _.max @get('legs'), (leg) -> leg.duration()

    getFirstTransportType: ->
      @getFirstNonWalkingLeg()?.get('type')

    getFirstNonWalkingLeg: ->
      _.find @get('legs'), ((leg) -> !leg.isWalk())

    getLeg: (idx) -> @get('legs')[idx]

    getTotalWalkingDistance: () ->
      _.reduce @getWalkLegs(), ((sum, leg) -> sum + leg.get('length')), 0

    getWalkLegs: () ->
      leg for leg in @get('legs') when leg.isWalk()

    getLegCount: () ->
      @get('legs').length

    getLegDurationPercentage: (idx) ->
      @_legDurationPercentages ?= @_getLegDurationPercentages()
      @_legDurationPercentages[idx]

    _getLegDurationPercentages: () ->
      totalDuration = @duration()
      percentages = for leg in @get('legs')
        _.max [Math.floor(leg.duration() * 100 / totalDuration), 1]

      # If floored total is less than 100, stick the remainder in the last leg
      remainder = 100 - _.reduce percentages, (t,p) -> t + p
      if remainder > 0 
        percentages[percentages.length - 1] += remainder

      percentages

