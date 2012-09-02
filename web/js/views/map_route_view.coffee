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
      
  class MapRouteView
    
    constructor: ->
      @legs = []
      
    remove: ->
      leg.setMap(null) for leg in @legs
      this
      
    render: (route, gMap) ->
      @legs = for leg in route.legs
        latLngs = (new google.maps.LatLng point.y, point.x for point in leg.shape)
        new google.maps.Polyline _.extend({
            map: gMap
            path: latLngs
            strokeWeight: 4
            strokeColor: Utils.transportColors[leg.type]
          }, legStyles[leg.type])
      this

    getBounds: () ->
      bounds = new google.maps.LatLngBounds()
      for leg in @legs
        for latLng in leg.getPath().getArray()
          bounds.extend(latLng)
      bounds
