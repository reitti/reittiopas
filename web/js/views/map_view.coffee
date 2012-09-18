define ['jquery', 'underscore', 'backbone', 'utils', 'leaflet', 'views/map_route_view'], ($, _, Backbone, Utils, L, MapRouteView) ->
      
  class MapView extends Backbone.View

    el: $('#map')

    initialize: ->
      Reitti.Event.on 'position:change', (position) =>
        @displayCurrentPosition position

      Reitti.Event.on 'route:change', @drawRoute
      Reitti.Event.on 'leg:change', @panToLegBounds

    render: ->
      @map = L.map @el, {
        attributionControl: true
        maxZoom: 19
        minZoom: 10
        maxBounds: new L.LatLngBounds new L.LatLng(59.99907, 24.152104), new L.LatLng(60.446654, 25.535784)
      }
      @map.attributionControl.addAttribution "<a href=\"http://www.openstreetmap.org/copyright\">&copy; OpenStreetMap contributors</a>"
      @map.setView([60.171, 24.941], 17)
      L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo @map

      # If we already have the user's current position, use it. If not, center
      # the map to it as soon as everything is initialized and we have the
      # location.
      initPos = window.initialPosition
      if initPos? and Utils.isWithinBounds(initPos)
        @centerMap(initPos.coords.latitude, initPos.coords.longitude)
      else
        @centerMap(60.171, 24.941) # Rautatieasema
        Reitti.Event.on 'position:change', _.once (position) =>
          if Utils.isWithinBounds(position)
            @centerMap position.coords.latitude, position.coords.longitude
      @

    drawRoute: (route) =>
      @routeView?.remove()
      @routeView = new MapRouteView(route, @map).render()
      @panToRouteBounds()

    panToRouteBounds: () =>
      @map.fitBounds @routeView.getBounds()

    panToLegBounds: (leg) =>
      @map.fitBounds @routeView.getBoundsForLeg(leg)
      
    centerMap: (lat, lng) ->
      @map.panTo([lat, lng])

    displayCurrentPosition: (position) ->
      @positionIndicator = L.circle [position.coords.latitude, position.coords.longitude], position.coords.accuracy
      @positionIndicator.addTo @map
