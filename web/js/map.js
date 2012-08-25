function initialize() {
	new google.maps.Map(document.getElementById('map'), {
 		center: new google.maps.LatLng(60.200833, 24.9375),
  	zoom: 12,
  	mapTypeId: google.maps.MapTypeId.ROADMAP
	});
}

function loadScript() {
	var url = 'http://maps.googleapis.com/maps/api/js?sensor=true&callback=initialize';
	if (window.location.hostname !== 'localhost') {
		url += '&key=AIzaSyDZj9_A4WUDGph6cKf2A7VsFbDz6Pb7QBk';
	}
	
	var script = document.createElement('script');
	script.src = url;
	document.body.appendChild(script);
}

window.onload = loadScript;
