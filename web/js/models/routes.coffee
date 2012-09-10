define ['jquery', 'backbone', 'models/route', 'utils'], ($, Backbone, Route, Utils) ->

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

    length: () -> @get('routes').length

    getRoute: (idx) -> @get('routes')[idx]

    getLegDurationPercentage: (routeIdx, legIdx) ->
      percentage = Math.floor @getRoute(routeIdx).getLeg(legIdx).get('duration') * 95 / @getTotalDuration()
      if percentage > 0 then percentage else 1

    getDurationPercentageBeforeDeparture: (routeIdx) ->
      duration = @getRoute(routeIdx).getDepartureTime().getTime() - @getFirstDepartureTime()
      Math.floor duration / 9.5 / @getTotalDuration()

    getTotalDuration: () ->
      Utils.getDuration @getFirstDepartureTime(), @getLastArrivalTime()

    getFirstDepartureTime: () ->
      @_sortedByDeparture ?= _.sortBy @get('routes'), (route) -> route.getDepartureTime().getTime()
      _(@_sortedByDeparture).first().getDepartureTime()

    getLastArrivalTime: () ->
      @_sortedByArrival ?= _.sortBy @get('routes'), (route) -> route.getArrivalTime().getTime()
      _(@_sortedByArrival).last().getArrivalTime()
