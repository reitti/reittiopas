define ['jquery', 'underscore', 'backbone', 'utils', 'models/route_leg'], ($, _, Backbone, Utils, RouteLeg) ->
  class Route extends Backbone.Model

    initialize: (from, to, routeData) ->
      @set 'from', from
      @set 'to', to
      @set 'legs', (new RouteLeg(legData) for legData in routeData.legs)
      @set 'duration', routeData.duration

    getDepartureTime: ->
      _.first(@get('legs')).firstArrivalTime()

    getArrivalTime: () ->
      _.last(@get('legs')).lastArrivalTime()

    boardingTime: ->
      @getFirstNonWalkingLeg()?.firstArrivalTime()

    getFirstTransportType: ->
      @getFirstNonWalkingLeg()?.get('type')

    getFirstNonWalkingLeg: ->
      _.find @get('legs'), ((leg) -> !leg.isWalk())

    getLeg: (idx) -> @get('legs')[idx]

    getTotalWalkingDistance: () ->
      _.reduce @getWalkLegs(), ((sum, leg) -> sum + leg.get('length')), 0

    getWalkLegs: () ->
      _.select @get('legs'), ((leg) -> leg.isWalk())

    getLegCount: () ->
      @get('legs').length