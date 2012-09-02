define ['underscore'], (_) ->
  
  legColors =
    walk: '#1e74fc'
    1:    '#193695' # Helsinki internal bus lines
    2:    '#00ab66' # Trams
    3:    '#193695' # Espoo internal bus lines
    4:    '#193695' # Vantaa internal bus lines
    5:    '#193695' # Regional bus lines
    6:    '#fb6500' # Metro
    7:    '#00aee7' # Ferry
    8:    '#193695' # U-lines
    12:   '#ce1141' # Commuter trains
    21:   '#193695' # Helsinki service lines
    22:   '#193695' # Helsinki night buses
    23:   '#193695' # Espoo service lines
    24:   '#193695' # Vantaa service lines
    25:   '#193695' # Region night buses
    36:   '#193695' # Kirkkonummi internal bus lines
    39:   '#193695' # Kerava internal bus lines

  legStyles =
    walk: 
      strokeOpacity: 0
      icons: [{
        icon:
          path: 'M 0,-0.2 0,0.2'
          strokeOpacity: 1
          strokeColor: legColors['walk']
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
      @legs = for leg in route[0].legs
        latLngs = (new google.maps.LatLng point.y, point.x for point in leg.shape)
        new google.maps.Polyline _.extend({
            map: gMap
            path: latLngs
            strokeWeight: 4
            strokeColor: legColors[leg.type]
          }, legStyles[leg.type])
      this

    getBounds: () ->
      bounds = new google.maps.LatLngBounds()
      for leg in @legs
        for latLng in leg.getPath().getArray()
          bounds.extend(latLng)
      bounds
