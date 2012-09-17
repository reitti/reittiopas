define ['underscore', 'utils', 'views/map_marker_image'], (_, Utils, MapMarkerImage) ->

  class MapRouteLegView
    
    constructor: (@leg, @map) ->
      @legStyles = 
        walk: 
          strokeOpacity: 0
          icons: [{
            icon:
              path: 'M 0,-0.2 0,0.2'
              strokeOpacity: 1
            repeat: '7px'
          }, {
            icon:
              path: google.maps.SymbolPath.FORWARD_OPEN_ARROW
              scale: 2.5
              strokeOpacity: 1
            repeat: '100px'
          }]
        default:
          icons: [{
            icon:
              path: google.maps.SymbolPath.FORWARD_OPEN_ARROW
              scale: 2.5
              strokeOpacity: 1
            repeat: '100px'
          }]

    remove: -> 
      @line.setMap(null) if @line
      @marker.setMap(null) if @marker
      this
      
    render: () ->
      path = (new google.maps.LatLng point.y, point.x for point in @leg.get('shape'))
      
      @line = new google.maps.Polyline _.extend({
          map: @map
          path: path
          strokeWeight: 4
          strokeColor: Utils.transportColors[@leg.get('type')]
          strokeOpacity: 1.0
        }, @legStyles[@leg.get('type')] or @legStyles['default'])
      @marker = new MapMarkerImage(@map, path[Math.floor(path.length / 2)], @leg.get('type'))

      google.maps.event.addListener @line, 'click', @onClicked
      google.maps.event.addListener @marker.marker, 'click', @onClicked
      this
      
    onClicked: () =>
      Reitti.Event.trigger 'leg:change', @leg

    getBounds: () ->
      bounds = new google.maps.LatLngBounds()
      if @line
        bounds.extend(latLng) for latLng in @line.getPath().getArray()  
      bounds
