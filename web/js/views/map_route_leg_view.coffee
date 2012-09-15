define ['underscore', 'utils'], (_, Utils) ->
      
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
      this
      
    render: () ->
      @line = new google.maps.Polyline _.extend({
          map: @map
          path: (new google.maps.LatLng point.y, point.x for point in @leg.get('shape'))
          strokeWeight: 4
          strokeColor: Utils.transportColors[@leg.get('type')]
          strokeOpacity: 1.0
        }, @legStyles[@leg.get('type')] or @legStyles['default'])
      google.maps.event.addListener @line, 'click', @onLineClicked
      this
      
    onLineClicked: () =>
      Reitti.Event.trigger 'leg:change', @leg

    getBounds: () ->
      bounds = new google.maps.LatLngBounds()
      if @line
        bounds.extend(latLng) for latLng in @line.getPath().getArray()  
      bounds
