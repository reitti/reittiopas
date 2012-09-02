define ['backbone', 'views/map_view', 'views/search_view', 'views/routes_view'], (Backbone, MapView, SearchView, RoutesView) ->
  Backbone.Router.extend
    routes:
      '': 'home'

    initialize: ->
      @mapView   = new MapView()
      @searchBox = new SearchView()
      @routesView = new RoutesView()

    home: ->
      @mapView.render()
      @searchBox.render()


