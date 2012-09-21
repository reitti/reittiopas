define ['jquery', 'underscore', 'backbone', 'models/route', 'utils'], ($, _, Backbone, Route, Utils) ->

  class Routes extends Backbone.Collection

    model: Route

    @find: (from, to, date, arrivalOrDeparture = 'departure', transportTypes = 'all') ->
      params = $.param
        from: from
        to: to
        date: Utils.formatDate(date)
        time: Utils.formatHSLTime(date)
        arrivalOrDeparture: arrivalOrDeparture
        transportTypes: transportTypes.join('|')
      successCallback = (data) =>
        @putCached(params, data)
        Reitti.Event.trigger 'routes:change', Routes.make(data.from, data.to, data.routes, date, arrivalOrDeparture)
      errorCallback = (xhr, status) =>
        Reitti.Event.trigger 'routes:notfound', $.parseJSON(xhr.responseText)

      if data = @getCached(params)
        successCallback(data)
      else
        $.ajax
          url: "/routes?#{params}"
          dataType: 'json'
          success: successCallback
          error: errorCallback

    @getCached: (params) ->
      (@_cache ?= {})[params]
    @putCached: (params,data) ->
      (@_cache ?= {})[params] = data

    @make: (from, to, data, date, arrivalOrDeparture) ->
      fromName = @_locationString(from)
      toName = @_locationString(to)
      routes = new Routes(new Route(fromName, toName, routeData[0]) for routeData in data)
      routes.from = fromName
      routes.to = toName
      routes.date = date
      routes.arrivalOrDeparture = arrivalOrDeparture
      #routes.addPreAndPostLegs()
      routes

    addPreAndPostLegs: () ->
      earliestDeparture = @getEarliestDepartureTime()
      lastArrival = @getLastArrivalTime()
      for i in [0...@size()]
        @at(i).addPreDepartureLeg(earliestDeparture) unless @at(i).getDepartureTime().getTime() is earliestDeparture.getTime()
        @at(i).addPostArrivalLeg(lastArrival) unless @at(i).getArrivalTime().getTime() is lastArrival.getTime()

    getEarliestDepartureTime: () ->
      departures = @map (route) -> route.getDepartureTime()
      _.reduce departures, (first,cand) -> if first.getTime() < cand.getTime() then first else cand

    getLastArrivalTime: () ->
      if @isBasedOnArrivalTime()
        @date
      else
        arrivals = @map (route) -> route.getArrivalTime()
        _.reduce arrivals, (last,cand) -> if last.getTime() > cand.getTime() then last else cand

    getLegDurationPercentage: (routeIdx, legIdx) ->
      route = @at(routeIdx).getLegDurationPercentage(legIdx)

    isBasedOnArrivalTime: () ->
      @arrivalOrDeparture is 'arrival'

    @_locationString: (loc) ->
      str = loc.name
      if loc.details?.houseNumber?
        str += " " + loc.details.houseNumber
      if loc.city?
        str += ", "
        str += loc.city
      str
