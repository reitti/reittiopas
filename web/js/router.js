define(['backbone', 'views/map_view', 'views/search_view'], function (Backbone, MapView, SearchView) {

  return Backbone.Router.extend({

    routes: {
      '': 'home'
    },

    initialize: function () {
      this.mapView = new MapView();
      this.searchBox = new SearchView();
    },

    home: function () {
      this.mapView.render();
      this.searchBox.render();
    }
  });
});
