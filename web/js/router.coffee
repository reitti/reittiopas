define ['backbone', 'utils', 'backboneAnalytics'], (Backbone, Utils) ->
  Backbone.Router.extend

    initialize: () ->
      @route '', 'homeView'
      @route /([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)(?:\/([^\/]+))?(?:\/([^\/]+))?(?:\/([^\/]+))?\/?/, 'routesView'

    homeView: () =>
      Reitti.Event.trigger 'home'

    routesView: (from, to, arrivalOrDeparture, datetime, transportTypes, routeIndex, legIndex, originOrDestination) =>
      Reitti.Event.trigger 'routes:find',
        from: Utils.decodeURIComponent(from)
        to: Utils.decodeURIComponent(to)
        date: if datetime is 'now' then 'now' else Utils.parseDateTimeFromMachines(datetime)
        arrivalOrDeparture: arrivalOrDeparture
        transportTypes: transportTypes.split(',')
        routeIndex: if routeIndex? then parseInt(routeIndex, 10)
        legIndex: if legIndex?.length > 0 then parseInt(legIndex, 10) else undefined
        originOrDestination: originOrDestination

    navigateToRoutes: (params) ->
      path = [Utils.encodeURIComponent(params.from),
              Utils.encodeURIComponent(params.to),
              params.arrivalOrDeparture,
              if params.date is 'now' then 'now' else Utils.formatDateTimeForMachines(params.date),
              params.transportTypes.join(',')]
      if params.routeIndex?
        path.push params.routeIndex
        if params.legIndex?
          path.push params.legIndex
          if params.originOrDestination?
            path.push params.originOrDestination

      @navigate '/' + path.join('/'), trigger: true
