define ['jquery', 'underscore', 'backbone', 'models/route', 'utils'], ($, _, Backbone, Route, Utils) ->

  class Routes extends Backbone.Collection

    model: Route

    @find: (from, to, date, arrivalOrDeparture = 'departure', transportTypes, routeParams) ->
      @_doFind from, to, date, arrivalOrDeparture, transportTypes, (error, routes) ->
        if error?
          Reitti.Event.trigger 'routes:notfound', error, routeParams
        else
          if routeParams.routeIndex > routes.length - 1
            delete routeParams.routeIndex
            delete routeParams.legIndex
          Reitti.Event.trigger 'routes:change', routes, routeParams

    @_doFind: Utils.asyncMemoize (from, to, date, arrivalOrDeparture, transportTypes, callback) ->
      params = $.param
        from: from
        to: to
        date: Utils.formatDateForMachines(if date is 'now' then Utils.now() else date)
        time: Utils.formatTimeForMachines(if date is 'now' then Utils.now() else date)
        arrivalOrDeparture: arrivalOrDeparture
        transportTypes: transportTypes.join('|')
      $.ajax
          url: "/routes?#{params}"
          dataType: 'json'
          success: (data) -> callback(null, Routes.make(data.from, data.to, data.routes, date, arrivalOrDeparture, transportTypes))
          error: (xhr) -> callback($.parseJSON(xhr.responseText))

    @make: (from, to, data, date, arrivalOrDeparture, transportTypes) ->
      fromName = @_locationString(from)
      fromCoords = @_locationCoords(from)
      toName = @_locationString(to)
      toCoords = @_locationCoords(to)
      routes = new Routes(new Route(fromName, fromCoords, toName, toCoords, routeData[0]) for routeData in data)
      routes.fromName = fromName
      routes.toName = toName
      routes.date = date
      routes.arrivalOrDeparture = arrivalOrDeparture
      routes.transportTypes = transportTypes
      routes

    loadMoreEarlier: (callback) ->
      @loadMore(@_earlierTime(), callback)

    _earlierTime: () ->
      if @arrivalOrDeparture is 'departure'
        # Heuristic reverse-engineered from original Reittiopas:
        # Duration between the earliest 5 routes + 2 minutes.
        depTimes = @getDepartureTimes()
        span = Utils.getDuration(depTimes[0], depTimes[4]) / 60
        Utils.addMinutes(depTimes[0], -(span + 2))
      else
        Utils.addMinutes(_.last(@getArrivalTimes()), -1)

    loadMoreLater: (callback) ->
      @loadMore(@_laterTime(), callback)

    _laterTime: () ->
      if @arrivalOrDeparture is 'departure'
        Utils.addMinutes(_.last(@getDepartureTimes()), 1)
      else
        # Heuristic reverse-engineered from original Reittiopas:
        # Duration between the earliest 5 routes + 2 minutes.
        arrTimes = @getArrivalTimes()
        span = Utils.getDuration(arrTimes[0], arrTimes[4]) / 60
        Utils.addMinutes(arrTimes[0], span + 2)      

    loadMore: (fromDate, callback) ->
      Routes._doFind @fromName, @toName, fromDate, @arrivalOrDeparture, @transportTypes, (error, newRoutes) =>
        if error?
          Reitti.Event.trigger 'routes:more:error', error
          callback?(false)
        else
          @add(@filterNewRoutes(newRoutes.models))
          callback?(true)

    filterNewRoutes: (routes) ->
      existingDepTimes = (d.getTime() for d in @getDepartureTimes())
      _.reject routes, (r) -> _.include(existingDepTimes, r.getDepartureTime().getTime())

    getLegDurationPercentage: (routeIdx, legIdx) ->
      route = @at(routeIdx).getLegDurationPercentage(legIdx)

    isBasedOnArrivalTime: () ->
      @arrivalOrDeparture is 'arrival'

    getLaterRouteIndex: (fromIdx) ->
      @_nextIndexBasedOnTime(fromIdx, 1)

    getEarlierRouteIndex: (fromIdx) ->
      @_nextIndexBasedOnTime(fromIdx, -1)

    _nextIndexBasedOnTime: (idx, next) ->
      current = @at(idx)
      sorted = @sortBy(if @isBasedOnArrivalTime() then ((r) -> r.getArrivalTime().getTime()) else ((r) -> r.getDepartureTime().getTime()))
      nextIndexInSorted = _.indexOf(sorted, current) + next
      @indexOf(sorted[nextIndexInSorted])

    getDepartureTimes: ->
      times = (r.getDepartureTime() for r in @models)
      _.sortBy times, (r) -> r.getTime()

    getArrivalTimes: ->
      times = (r.getArrivalTime() for r in @models)
      _.sortBy(times, (r) -> r.getTime()).reverse()

    @_locationString: (loc) ->
      str = loc.name
      if loc.details?.houseNumber?
        str += " " + loc.details.houseNumber
      if loc.city?
        str += ", "
        str += loc.city
      str

    @_locationCoords: (loc) ->
      [x, y] = loc.coords.split /,/
      x: x, y: y

