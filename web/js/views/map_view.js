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

      EventBus.on('position:updated', _.once(this.centerMapOnCurrentPosition), this);

      EventBus.on('position:updated', function (position) {
        this.displayCurrentPosition(position);
      }, this);

      return this;
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
