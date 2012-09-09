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
        callback(new Routes(data))

    initialize: (data) ->
      @set 'routes', (new Route(routeData[0]) for routeData in data)

    length: () -> @get('routes').length

    getRoute: (idx) -> @get('routes')[idx]

    getLegDurationPercentage: (routeIdx, legIdx) ->
      Math.floor @getRoute(routeIdx).getLeg(legIdx).get('duration') * 95 / @getTotalDuration()

    getDurationPercentageBeforeDeparture: (routeIdx) ->
      duration = @getRoute(routeIdx).getDepartureTime().getTime() - @getFirstDepartureTime()
      Math.floor duration / 10 / @getTotalDuration()

    getTotalDuration: () ->
      depSeconds = @getFirstDepartureTime().getTime() / 1000
      arrSeconds = @getLastArrivalTime().getTime() / 1000
      arrSeconds - depSeconds

    getFirstDepartureTime: () ->
      @_sortedByDeparture ?= _.sortBy @get('routes'), (route) -> route.getDepartureTime().getTime()
      _(@_sortedByDeparture).first().getDepartureTime()

    getLastArrivalTime: () ->
      @_sortedByArrival ?= _.sortBy @get('routes'), (route) -> route.getArrivalTime().getTime()
      _(@_sortedByArrival).last().getArrivalTime()
