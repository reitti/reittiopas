define(['jquery', 'underscore', 'backbone', 'async!http://maps.googleapis.com/maps/api/js?sensor=true' + (window.location.host === 'localhost' || window.location.protocol === 'file:' ? '' : '&key=AIzaSyDZj9_A4WUDGph6cKf2A7VsFbDz6Pb7QBk')], function ($, _, Backbone) {
  return Backbone.View.extend({

    el: $('#map'),

    initialize: function () {
      Reitti.Event.on('position:updated', function (position) {
        this.currentPosition = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
      }, this);

      Reitti.Event.on('position:updated', _.once(this.centerMapOnCurrentPosition), this);

      Reitti.Event.on('position:updated', function (position) {
        this.displayCurrentPosition(position);
      }, this);

      Reitti.Event.on('route:change', this.drawRoute, this);
    },

    render: function () {
      this.map = new google.maps.Map(this.el, {
        center: new google.maps.LatLng(60.171, 24.941), // Rautatieasema
        zoom: 16,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        mapTypeControlOptions: {
          position: google.maps.ControlPosition.TOP_CENTER
        }
      });

      return this;
    },

    clearRoute: function () {
      if (this.route) {
        this.route.setMap(null);
      }
    },

    drawRoute: function (route) {
      this.clearRoute();

      var shapes = route[0].legs.map(function (leg) {
            return leg.shape;
          }),
          points = _(shapes).reduce(function (res, shape) {
            return res.concat(shape);
          }, []),
          latLngs = _(points).map(function (point) {
            return new google.maps.LatLng(point.y, point.x);
          });

      this.route = new google.maps.Polyline({
        map: this.map,
        path: latLngs,
        strokeColor: '#0000ee',
        strokeWeight: 4
      });

      this.panToNewBounds(latLngs);
    },

    panToNewBounds: function (latLngs) {
      var destination = _(latLngs).last(),
          sw = new google.maps.LatLng(Math.min(this.currentPosition.lat(), destination.lat()),
              Math.min(this.currentPosition.lng(), destination.lng())),
          ne = new google.maps.LatLng(Math.max(this.currentPosition.lat(), destination.lat()),
              Math.max(this.currentPosition.lng(), destination.lng())),
          initialBounds = new google.maps.LatLngBounds(sw, ne);

      var bounds = _.reduce(_.initial(latLngs), function (currentBounds, latLng) {
        return currentBounds.extend(latLng);
      }, initialBounds);

      console.log(bounds);

      this.map.fitBounds(bounds);
    },

    centerMapOnCurrentPosition: function (position) {
      var latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
      this.map.setCenter(latLng);
    },

    displayCurrentPosition: function (position) {
      var latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
      var accuracy = position.coords.accuracy;

      if (this.positionIndicator === undefined) {
        this.positionIndicator = new google.maps.Circle({
          strokeColor: '#0000FF',
          strokeOpacity: 0.50,
          strokeWeight: 2,
          fillColor: '#0000FF',
          fillOpacity: 0.10,
          map: this.map,
          center: latLng,
          radius: accuracy
        });
      } else {
        this.positionIndicator.setCenter(latLng);
        this.positionIndicator.setRadius(accuracy);
      }
    }
  });
});
