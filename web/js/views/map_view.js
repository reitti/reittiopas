define(['jquery', 'async!http://maps.googleapis.com/maps/api/js?sensor=true' + (window.location.host === 'localhost' ? '' : '&key=AIzaSyDZj9_A4WUDGph6cKf2A7VsFbDz6Pb7QBk')], function($) {
  return Backbone.View.extend({

    el: $('#map'),

    render: function() {
      this.map = new google.maps.Map(this.el, {
        center: new google.maps.LatLng(60.200833, 24.9375), // Helsinki
        zoom: 12,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        mapTypeControlOptions: {
          position: google.maps.ControlPosition.TOP_CENTER
        }
      });
      return this;
    }

  });
});
