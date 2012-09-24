define ['jquery', 'underscore', 'backbone', 'models/route', 'utils'], ($, _, Backbone, Route, Utils) ->

  class Routes extends Backbone.Collection

    model: Route

    @find: (from, to, date, arrivalOrDeparture = 'departure', transportTypes, routeParams) ->
      params = $.param
        from: from
        to: to
        date: Utils.formatDateForMachines(date)
        time: Utils.formatTimeForMachines(date)
        arrivalOrDeparture: arrivalOrDeparture
        transportTypes: transportTypes.join('|')
      @_doFind params, date, arrivalOrDeparture, (error, routes) ->
        if error?
          Reitti.Event.trigger 'routes:notfound', error, routeParams
        else
          Reitti.Event.trigger 'routes:change', routes, routeParams

    @_doFind: Utils.asyncMemoize (params, date, arrivalOrDeparture, callback) ->
      $.ajax
          url: "/routes?#{params}"
          dataType: 'json'
          success: (data) -> callback(null, Routes.make(data.from, data.to, data.routes, date, arrivalOrDeparture))
          error: (xhr) -> callback($.parseJSON(xhr.responseText))

    @make: (from, to, data, date, arrivalOrDeparture) ->
      fromName = @_locationString(from)
      toName = @_locationString(to)
      routes = new Routes(new Route(fromName, toName, routeData[0]) for routeData in data)
      routes.from = fromName
      routes.to = toName
      routes.date = date
      routes.arrivalOrDeparture = arrivalOrDeparture
      routes

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
