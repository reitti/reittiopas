define(['backbone', 'views/map_view'], function(Backbone, MapView) {

  var Router = Backbone.Router.extend({

    routes: {
      '': 'home'
    },

    initialize: function() {
      this.mapView = new MapView();
    },

    home: function() {
      this.mapView.render();
    }
  });

  return Router;

});
