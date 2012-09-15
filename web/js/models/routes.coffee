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
        callback(Routes.make(data.from, data.to, data.routes))

    @make: (from, to, data) ->
      routes = new Routes(new Route(routeData[0]) for routeData in data)
      routes.setFrom(from)
      routes.setTo(to)
      routes.addPreAndPostLegs()
      routes

    setFrom: (from) ->
      @from = @_locationString(from)
    setTo: (to) ->
      @to = @_locationString(to)

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

    _locationString: (loc) ->
      str = loc.name
      if loc.details?.houseNumber?
        str += " " + loc.details.houseNumber
      if loc.city?
        str += ", "
        str += loc.city
      str
