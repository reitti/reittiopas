// TODO: Make the map a Backbone view?

require(['async!http://maps.googleapis.com/maps/api/js?sensor=true' + (window.location.host === 'localhost' ? '' : '&key=AIzaSyDZj9_A4WUDGph6cKf2A7VsFbDz6Pb7QBk')], function() {
	var mapEl = $('#map')[0];
	new google.maps.Map(mapEl, {
 		center: new google.maps.LatLng(60.200833, 24.9375), // Helsinki
  	zoom: 12,
  	mapTypeId: google.maps.MapTypeId.ROADMAP,
  	mapTypeControlOptions: {
  		position: google.maps.ControlPosition.TOP_CENTER
  	}
	});
});
