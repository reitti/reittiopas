define ['underscore', 'utils', 'leaflet', 'views/map_marker_image'], (_, Utils, L, MapMarkerImage) ->

  class MapRouteLegView
    
    constructor: (@leg, @map) ->

    remove: -> 
      @map.removeLayer @line if @line
      @map.removeLayer @marker.marker if @marker
      this
      
    render: () ->
      latLngs = (new L.LatLng pt.y, pt.x for pt in @leg.get('shape'))
      @line = L.polyline latLngs, {
        weight: 4
        opacity: 1
        color: Utils.transportColors[@leg.get('type')],
        dashArray: @_lineDashes()
      }
      @marker = new MapMarkerImage(@map, latLngs[Math.floor(latLngs.length / 2)], @leg.get('type'))

      @line.on 'click', @onClicked
      @marker.on 'click', @onClicked

      @line.addTo @map
      @marker.marker.addTo @map
      this
      
    onClicked: () =>
      Reitti.Event.trigger 'leg:change', @leg

    getBounds: () ->
      new L.LatLngBounds @line.getLatLngs()

    _lineDashes: () ->
      switch @leg.get('type')
        when 'walk' then [5, 10]
        else undefined