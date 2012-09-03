define [
  'jquery'
  'underscore'
  'backbone'
  'views/map_route_view'
  'async!http://maps.googleapis.com/maps/api/js?sensor=true' + if window.location.host is 'localhost' then '' else '&key=AIzaSyDZj9_A4WUDGph6cKf2A7VsFbDz6Pb7QBk'
], ($, _, Backbone, MapRouteView) ->
      

  # Roughly the greater Helsinki area
  maxBounds = new google.maps.LatLngBounds(
    new google.maps.LatLng 59.99907, 24.152104
    new google.maps.LatLng 60.446654, 25.535784
  )

  class MapView extends Backbone.View

    el: $('#map')

    initialize: ->
      Reitti.Event.on 'position:change', (position) =>
        @displayCurrentPosition position

      Reitti.Event.on 'route:change', @drawRoute
      
      Reitti.Event.on 'leg:change', @panToLegBounds

    render: ->
      @map = new google.maps.Map(@el,
        zoom: 16
        mapTypeId: google.maps.MapTypeId.ROADMAP
        mapTypeControlOptions:
          position: google.maps.ControlPosition.TOP_CENTER
        minZoom: 10,
        maxZoom: 18,
        scaleControl: true
      )

      # If we already have the user's current position, use it. If not, center
      # the map to it as soon as everything is initialized and we have the
      # location.
      if initPos = window.initialPosition
        @centerMap(initPos.coords.latitude, initPos.coords.longitude)
      else
        @centerMap(60.171, 24.941) # Rautatieasema
        Reitti.Event.on 'position:change', (position) =>
          _.once @centerMap(position.coords.latitude, position.coords.longitude)

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
      latLng = new google.maps.LatLng lat, lng
      @map.setCenter(latLng) if maxBounds.contains(latLng)

    displayCurrentPosition: (position) ->
      latLng   = new google.maps.LatLng position.coords.latitude, position.coords.longitude
      accuracy = position.coords.accuracy

      @positionIndicator ?= new google.maps.Circle(
        strokeColor: '#0000FF'
        strokeOpacity: 0.50
        strokeWeight: 2
        fillColor: '#0000FF'
        fillOpacity: 0.10
        map: @map
        center: latLng
        radius: accuracy
      )
      @positionIndicator.setCenter latLng
      @positionIndicator.setRadius accuracy