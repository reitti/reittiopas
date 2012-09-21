define ['backbone', 'utils', 'views/map_view', 'views/search_view', 'views/routes_view'], (Backbone, Utils, MapView, SearchView, RoutesView) ->
  Backbone.Router.extend

    routes:
      '': 'home'
      ':from/:to/:departArrive/:datetime/:transportTypes': 'routesView'

    initialize: ->
      @mapView   = new MapView()
      @searchBox = new SearchView()
      @routesView = new RoutesView()
      @mapView.render()
      @searchBox.render()

    home: ->
      @mapView.render()
      @searchBox.render()

    routesView: (from, to, departArrive, datetime, transportTypes) ->
      Reitti.Event.trigger 'routes:find',
        from: from
        to: to
        date: Utils.parseDateTime(datetime)
        arrivalOrDeparture: departArrive
        transportTypes: transportTypes.split(',')