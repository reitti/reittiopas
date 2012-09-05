define ['underscore', 'utils'], (_, Utils) ->

  legStyles =
    walk: 
      strokeOpacity: 0
      icons: [{
        icon:
          path: 'M 0,-0.2 0,0.2'
          strokeOpacity: 1
          strokeColor: Utils.transportColors['walk']
        offset: '0',
        repeat: '7px'
      }]
      
  class MapRouteLegView
    
    constructor: (@leg, @map) ->

    remove: -> 
      @line.setMap(null) if @line
      this
      
    render: () ->
      @line = new google.maps.Polyline _.extend({
          map: @map
          path: (new google.maps.LatLng point.y, point.x for point in @leg.get('shape'))
          strokeWeight: 4
          strokeColor: Utils.transportColors[@leg.get('type')]
        }, legStyles[@leg.get('type')])
      google.maps.event.addListener @line, 'click', @onLineClicked
      this
      
    onLineClicked: () =>
      Reitti.Event.trigger 'leg:change', @leg

    getBounds: () ->
      bounds = new google.maps.LatLngBounds()
      if @line
        bounds.extend(latLng) for latLng in @line.getPath().getArray()  
      bounds
