define ['backbone', 'utils', 'views/map_view', 'views/search_view', 'views/routes_view'], (Backbone, Utils, MapView, SearchView, RoutesView) ->
  Backbone.Router.extend

    routes:
      ':from/:to/:departArrive/:datetime/:transportTypes': 'routesView'
      ':from/:to/:departArrive/:datetime/:transportTypes/:routeIndex': 'routesView'
      ':from/:to/:departArrive/:datetime/:transportTypes/:routeIndex/:legIndex': 'routesView'

    initialize: ->
      @mapView   = new MapView()
      @searchBox = new SearchView()
      @routesView = new RoutesView()
      @mapView.render()
      @searchBox.render()

    routesView: (from, to, departArrive, datetime, transportTypes, routeIndex = 0, legIndex) ->
      Reitti.Event.trigger 'routes:find',
        from: Utils.decodeURIComponent(from)
        to: Utils.decodeURIComponent(to)
        date: if datetime is 'now' then 'now' else Utils.parseDateTime(datetime)
        arrivalOrDeparture: departArrive
        transportTypes: transportTypes.split(',')
        routeIndex: parseInt(routeIndex, 10)
        legIndex: if legIndex? then parseInt(legIndex, 10) else undefined

    navigateToRoutes: (params) ->
      path = [Utils.encodeURIComponent(params.from),
              Utils.encodeURIComponent(params.to),
              params.arrivalOrDeparture,
              if params.date is 'now' then 'now' else Utils.formatDateTime(params.date),
              params.transportTypes.join(',')]
      if params.routeIndex?
        path.push params.routeIndex
        if params.legIndex? then path.push params.legIndex

      @navigate '/' + path.join('/'), trigger: true
