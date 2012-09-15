define ['jquery', 'underscore', 'backbone', 'models/route', 'utils'], ($, _, Backbone, Route, Utils) ->

  class Routes extends Backbone.Collection

    model: Route

    @find: (from, to, date, arrivalOrDeparture = 'departure', transportTypes = 'all', callback) ->
      params = $.param
        from: from
        to: to
        date: Utils.formatDate(date)
        time: Utils.formatHSLTime(date)
        arrivalOrDeparture: arrivalOrDeparture
        transportTypes: transportTypes.join('|')
      $.getJSON "/routes?#{params}", (data) ->
        callback(Routes.make(from, to, data))

    @make: (from, to, data) ->
      routes = new Routes(new Route(from, to, routeData[0]) for routeData in data)
      routes.addPreAndPostLegs()
      routes

    addPreAndPostLegs: () ->
      earliestDeparture = @first().getDepartureTime()
      lastArrival = @getLastArrivalTime()
      for i in [0...@size()]
        @at(i).addPreDepartureLeg(earliestDeparture) unless i is 0
        @at(i).addPostArrivalLeg(lastArrival) unless @at(i).getArrivalTime().getTime() is lastArrival.getTime()

    getLastArrivalTime: () -> 
      arrivals = @map (route) -> route.getArrivalTime()
      _.reduce arrivals, (last,cand) -> if last.getTime() > cand.getTime() then last else cand

    getLegDurationPercentage: (routeIdx, legIdx) ->
      route = @at(routeIdx)
      percentage = Math.floor route.getLeg(legIdx).duration() * 100 / route.durationWithFill()
      if percentage > 0 then percentage else 1
