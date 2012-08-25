// Called by Google Maps once it has loaded everything it needs (specified as ballcack in the Maps API URL)
window.initGoogleMaps = function() {
	var mapEl = $('#map')[0];
	new google.maps.Map(mapEl, {
 		center: new google.maps.LatLng(60.200833, 24.9375), // Helsinki
  	zoom: 12,
  	mapTypeId: google.maps.MapTypeId.ROADMAP,
  	mapTypeControlOptions: {
  		position: google.maps.ControlPosition.TOP_CENTER
  	}
	});
}

$(function() {
	var url = 'http://maps.googleapis.com/maps/api/js?sensor=true&callback=initGoogleMaps';
	if (window.location.hostname !== 'localhost') { // Don't use API key in local development
		url += '&key=AIzaSyDZj9_A4WUDGph6cKf2A7VsFbDz6Pb7QBk';
	}
	$.getScript(url);
});
