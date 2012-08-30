define(['jquery', 'underscore', 'backbone', 'async!http://maps.googleapis.com/maps/api/js?sensor=true' + (window.location.host === 'localhost' ? '' : '&key=AIzaSyDZj9_A4WUDGph6cKf2A7VsFbDz6Pb7QBk')], function ($, _, Backbone) {
  return Backbone.View.extend({

    el: $('#map'),

    render: function () {
      this.map = new google.maps.Map(this.el, {
        center: new google.maps.LatLng(60.171, 24.941), // Rautatieasema
        zoom: 16,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        mapTypeControlOptions: {
          position: google.maps.ControlPosition.TOP_CENTER
        }
      });
      this.centerOnCurrentLocation();

      return this;
    },

    centerOnCurrentLocation: function () {
      if (navigator.geolocation) {
        var that = this;
        navigator.geolocation.getCurrentPosition(function (position) {
          var latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
          that.map.setCenter(latLng);

          // Testing routing
          $.getJSON('routes?from='+latLng.lng()+','+latLng.lat()+'&to=Leikkikuja 2', function(res) {
            var shapes = _(res[0][0].legs).map(function(leg) { return leg.shape; })
              , points = _(shapes).reduce(function(res, shape) { return res.concat(shape); }, [])
              , latLngs = _(points).map(function(point) { return new google.maps.LatLng(point.y, point.x); });
            new google.maps.Polyline({
              map: that.map,
              path: latLngs,
              strokeColor: '#0000ee',
              strokeWeight: 4
            });
          });

        }, function() { /* error callback */ }, {enableHighAccuracy: true});
      }
    }

  });
});
