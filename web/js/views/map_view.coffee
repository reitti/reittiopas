define [
  'jquery'
  'underscore'
  'backbone'
  'utils'
  'views/map_route_view'
  "async!http://maps.googleapis.com/maps/api/js?sensor=true#{window.gmapsKey}"
], ($, _, Backbone, Utils, MapRouteView) ->
      
  class MapView extends Backbone.View

    el: $('#map')

    initialize: ->
      Reitti.Event.on 'position:change', (position) =>
        @displayCurrentPosition position

      Reitti.Event.on 'routes:change', @drawRoute

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
      initPos = window.initialPosition
      if initPos? and Utils.isWithinBounds(initPos)
        @centerMap(initPos.coords.latitude, initPos.coords.longitude)
      else
        @centerMap(60.171, 24.941) # Rautatieasema
        Reitti.Event.on 'position:change', _.once (position) =>
          if Utils.isWithinBounds(position)
            @centerMap position.coords.latitude, position.coords.longitude
      @

    drawRoute: (routes, routeParams) =>
      newRoute = routes.at(routeParams.routeIndex)
      if newRoute isnt @routeView?.route
        @routeView?.remove()
        @routeView = new MapRouteView(newRoute, routeParams.routeIndex, routes, @map).render()
        _.invoke @routeView.legViews, 'onRoutesChanged', routes, routeParams
      if routeParams.legIndex?
        @panToLegBounds(newRoute.getLeg(routeParams.legIndex))
      else
        @panToRouteBounds()

    panToRouteBounds: () =>
      @map.fitBounds @routeView.getBounds()

    panToLegBounds: (leg) =>
      @map.fitBounds @routeView.getBoundsForLeg(leg)
      
    centerMap: (lat, lng) ->
      latLng = new google.maps.LatLng lat, lng
      @map.setCenter(latLng)

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