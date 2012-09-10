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
      route = @getRoute(routeIdx)
      percentage = Math.floor route.getLeg(legIdx).duration() * 100 / route.duration()
      if percentage > 0 then percentage else 1
