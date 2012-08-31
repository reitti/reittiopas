define ['backbone', 'views/map_view', 'views/search_view'], (Backbone, MapView, SearchView) ->
  Backbone.Router.extend
    routes:
      '': 'home'

    initialize: ->
      @mapView   = new MapView()
      @searchBox = new SearchView()

    home: ->
      @mapView.render()
      @searchBox.render()


