define ['backbone', 'utils', 'backboneAnalytics'], (Backbone, Utils) ->
  Backbone.Router.extend

    initialize: () ->
      @route '', 'homeView'
      @route /([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)(?:\/([^\/]+))?(?:\/([^\/]+))?\/?/, 'routesView'

    homeView: () =>
      Reitti.Event.trigger 'home'

    routesView: (from, to, departArrive, datetime, transportTypes, routeIndex, legIndex) =>
      routeIndex = 0 if !routeIndex or routeIndex is ''
      Reitti.Event.trigger 'routes:find',
        from: Utils.decodeURIComponent(from)
        to: Utils.decodeURIComponent(to)
        date: if datetime is 'now' then 'now' else Utils.parseDateTimeFromMachines(datetime)
        arrivalOrDeparture: departArrive
        transportTypes: transportTypes.split(',')
        routeIndex: parseInt(routeIndex, 10)
        legIndex: if legIndex?.length > 0 then parseInt(legIndex, 10) else undefined

    navigateToRoutes: (params) ->
      path = [Utils.encodeURIComponent(params.from),
              Utils.encodeURIComponent(params.to),
              params.arrivalOrDeparture,
              if params.date is 'now' then 'now' else Utils.formatDateTimeForMachines(params.date),
              params.transportTypes.join(',')]
      if params.routeIndex?
        path.push params.routeIndex
        if params.legIndex? then path.push params.legIndex

      @navigate '/' + path.join('/'), trigger: true
