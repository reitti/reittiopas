define ['jquery', 'underscore', 'backbone', 'models/route', 'utils'], ($, _, Backbone, Route, Utils) ->

  class Routes extends Backbone.Model

    @find: (from, to, date, arrivalOrDeparture = 'departure', transportTypes = 'all', callback) ->
      params = $.param
        from: from
        to: to
        date: Utils.formatDate(date)
        time: Utils.formatHSLTime(date)
        arrivalOrDeparture: arrivalOrDeparture
        transportTypes: transportTypes.join('|')
      $.getJSON "/routes?#{params}", (data) ->
        callback(new Routes(from, to, data))

    initialize: (from, to, data) ->
      @set 'routes', (new Route(from, to, routeData[0]) for routeData in data)
      earliestDeparture = @getFirstRoute().getDepartureTime()
      lastArrival = @getLastArrivalTime()
      for i in [0...@length()]
        @getRoute(i).addPreDepartureLeg(earliestDeparture) unless i is 0
        @getRoute(i).addPostArrivalLeg(lastArrival) unless @getRoute(i).getArrivalTime().getTime() is lastArrival.getTime()

    length: () -> @get('routes').length

    getRoute: (idx) -> @get('routes')[idx]
    getFirstRoute: () -> _.first(@get('routes'))
    getLastRoute: () -> _.last(@get('routes'))

    getLastArrivalTime: () -> 
      arrivals = _.map @get('routes'), (route) -> route.getArrivalTime()
      _.reduce arrivals, (last,cand) -> if last.getTime() > cand.getTime() then last else cand

    getLegDurationPercentage: (routeIdx, legIdx) ->
      route = @getRoute(routeIdx)
      percentage = Math.floor route.getLeg(legIdx).duration() * 100 / route.durationWithFill()
      if percentage > 0 then percentage else 1
