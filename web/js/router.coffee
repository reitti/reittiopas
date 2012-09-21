define ['backbone', 'utils', 'views/map_view', 'views/search_view', 'views/routes_view'], (Backbone, Utils, MapView, SearchView, RoutesView) ->
  Backbone.Router.extend

    routes:
      '': 'home'
      ':from/:to/:departArrive/:datetime/:transportTypes': 'routesView'
      ':from/:to/:departArrive/:datetime/:transportTypes/:routeIndex': 'routesView'
      ':from/:to/:departArrive/:datetime/:transportTypes/:routeIndex/:legIndex': 'routesView'

    initialize: ->
      @mapView   = new MapView()
      @searchBox = new SearchView()
      @routesView = new RoutesView()
      @mapView.render()
      @searchBox.render()

    home: ->
      @mapView.render()
      @searchBox.render()

    routesView: (from, to, departArrive, datetime, transportTypes, routeIndex = 0, legIndex) ->
      Reitti.Event.trigger 'routes:find',
        from: decodeURIComponent(from)
        to: decodeURIComponent(to)
        date: Utils.parseDateTime(datetime)
        arrivalOrDeparture: departArrive
        transportTypes: transportTypes.split(',')
        routeIndex: parseInt(routeIndex, 10)
        legIndex: if legIndex? then parseInt(legIndex, 10) else undefined



    navigateToRoutes: (params) ->
      path = "/#{encodeURIComponent(params.from)}/#{encodeURIComponent(params.to)}/"+
             "#{params.arrivalOrDeparture}/#{Utils.formatDateTime(params.date)}/#{params.transportTypes.join(',')}"
      if params.routeIndex?
        path += "/#{params.routeIndex}"
        if params.legIndex? then path += "/#{params.legIndex}"

      @navigate path, trigger: true
