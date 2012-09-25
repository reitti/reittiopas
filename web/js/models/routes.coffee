define ['jquery', 'underscore', 'backbone', 'models/route', 'utils'], ($, _, Backbone, Route, Utils) ->

  class Routes extends Backbone.Collection

    model: Route

    @find: (from, to, date, arrivalOrDeparture = 'departure', transportTypes, routeParams) ->
      @_doFind from, to, date, arrivalOrDeparture, transportTypes, (error, routes) ->
        if error?
          Reitti.Event.trigger 'routes:notfound', error, routeParams
        else
          if routeParams.routeIndex > routes.length - 1
            routeParams.routeIndex = 0
            delete routeParams.legIndex
          Reitti.Event.trigger 'routes:change', routes, routeParams

    @_doFind: Utils.asyncMemoize (from, to, date, arrivalOrDeparture, transportTypes, callback) ->
      params = $.param
        from: from
        to: to
        date: Utils.formatDateForMachines(if date is 'now' then new Date() else date)
        time: Utils.formatTimeForMachines(if date is 'now' then new Date() else date)
        arrivalOrDeparture: arrivalOrDeparture
        transportTypes: transportTypes.join('|')
      $.ajax
          url: "/routes?#{params}"
          dataType: 'json'
          success: (data) -> callback(null, Routes.make(data.from, data.to, data.routes, date, arrivalOrDeparture, transportTypes))
          error: (xhr) -> callback($.parseJSON(xhr.responseText))

    @make: (from, to, data, date, arrivalOrDeparture, transportTypes) ->
      fromName = @_locationString(from)
      toName = @_locationString(to)
      routes = new Routes(new Route(fromName, toName, routeData[0]) for routeData in data)
      routes.fromName = fromName
      routes.toName = toName
      routes.date = date
      routes.arrivalOrDeparture = arrivalOrDeparture
      routes.transportTypes = transportTypes
      routes

    loadMoreEarlier: () ->
      date = if @arrivalOrDeparture is 'departure'
        depTimes = @getDepartureTimes()
        span = Utils.getDuration(depTimes[0], depTimes[4]) / 60
        Utils.addMinutes(depTimes[0], -(span + 2))
      else
        Utils.addMinutes(_.last(@getArrivalTimes()), -1)
      @loadMore(date)

    loadMoreLater: () ->
      date = if @arrivalOrDeparture is 'departure'
        Utils.addMinutes(_.last(@getDepartureTimes()), 1)
      else
        arrTimes = @getArrivalTimes()
        span = Utils.getDuration(arrTimes[0], arrTimes[4]) / 60
        Utils.addMinutes(arrTimes[0], span + 2)
      @loadMore(date)

    loadMore: (fromDate) ->
      Routes._doFind @fromName, @toName, fromDate, @arrivalOrDeparture, @transportTypes, (error, newRoutes) =>
        if error?
          Reitti.Event.trigger 'routes:more:error', error
        else
          @add(@filterNewRoutes(newRoutes.models))

    filterNewRoutes: (routes) ->
      existingDepTimes = (d.getTime() for d in @getDepartureTimes())
      _.reject routes, (r) -> _.include(existingDepTimes, r.getDepartureTime().getTime())

    getLegDurationPercentage: (routeIdx, legIdx) ->
      route = @at(routeIdx).getLegDurationPercentage(legIdx)

    isBasedOnArrivalTime: () ->
      @arrivalOrDeparture is 'arrival'

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
