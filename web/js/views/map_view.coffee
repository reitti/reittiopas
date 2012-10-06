define [
  'jquery'
  'underscore'
  'backbone'
  'utils'
  'views/map_route_view'
  'views/map_menu'
  "async!http://maps.googleapis.com/maps/api/js?sensor=true#{window.gmapsKey}"
], ($, _, Backbone, Utils, MapRouteView, MapMenu) ->
      
  class MapView extends Backbone.View

    el: $('#map')

    initialize: ->
      Reitti.Event.on 'position:change', @displayCurrentPosition
      Reitti.Event.on 'home', @onGoneHome
      Reitti.Event.on 'routes:change', @onRoutesChanged

    render: ->
      @initStreetView()
      @initMap()
      @initPosition()
      @initMapMenu()
      this

    initMap: ->
      @map = new google.maps.Map(@el,
        zoom: 16
        mapTypeId: google.maps.MapTypeId.ROADMAP
        minZoom: 10
        maxZoom: 18
        scaleControl: true
        streetView: @streetView
        styles: [
          {
            stylers: [
              { saturation: -50 }
            ]
          }
        ]
      )

    initStreetView: ->
      @streetView = new google.maps.StreetViewPanorama $('#streetview')[0],
        visible: false
        enableCloseButton: true
      google.maps.event.addListener @streetView, 'visible_changed', @onStreetViewVisibilityChanged

    initMapMenu: ->
      @mapMenu = new MapMenu({@map})

    initPosition: ->
      @centerMap(60.171, 24.941) # Rautatieasema
      Reitti.Event.on 'position:change', _.once (position) =>
        if Utils.isWithinBounds(position)
          @centerMap position.coords.latitude, position.coords.longitude

    onGoneHome: () =>
      @routeView?.dispose()
      @routes = null

    onRoutesChanged: (routes, routeParams) =>
      if routes isnt @routes or routeParams.routeIndex isnt @routeView?.index
        @routes = routes
        @routeView?.dispose()
        @routeView = new MapRouteView(routes: routes, routeParams: routeParams, index: routeParams.routeIndex, map: @map).render()
        # Invoke event handlers explicitly since the newly contructed views won't receive this event.
        legView.onRoutesChanged(routes, routeParams) for legView in @routeView.legViews
        @routeView.onRoutesChanged(routes, routeParams)
      @map.getStreetView()?.setVisible(false) unless routeParams.originOrDestination?
      @adjustPan(routeParams)

    onStreetViewVisibilityChanged: (a) =>
      if @map.getStreetView().getVisible()
        $('#map-wrap').css bottom: '50%'
        $('#streetview-wrap').show()
      else
        $('#map-wrap').css bottom: '0'
        $('#streetview-wrap').hide()
      google.maps.event.trigger @map, 'resize'

    adjustPan: (routeParams) =>
      if routeParams.legIndex?
        if routeParams.originOrDestination?
          @panToLegEnd(routeParams.legIndex, routeParams.originOrDestination)
        else
          @panToLegBounds(routeParams.legIndex)
      else
        @panToRouteBounds()

    panToRouteBounds: () =>
      @map.fitBounds @routeView.getBounds()

    panToLegBounds: (legIndex) =>
      @map.fitBounds @routeView.getBoundsForLeg(legIndex)
      
    panToLegEnd: (legIndex, originOrDestination) =>
      @map.panTo @routeView.getLegEndCoordinates(legIndex, originOrDestination)
      @map.setZoom 18

    centerMap: (lat, lng) ->
      latLng = new google.maps.LatLng lat, lng
      @map.setCenter(latLng)

    displayCurrentPosition: (position) =>
      latLng   = new google.maps.LatLng position.coords.latitude, position.coords.longitude
      accuracy = position.coords.accuracy

      if accuracy < 200
        @accuracyIndicator ?= new google.maps.Circle
          strokeColor: '#0000FF'
          strokeOpacity: 0.50
          strokeWeight: 2
          fillColor: '#0000FF'
          fillOpacity: 0.10
          map: @map
          center: latLng
          radius: accuracy
        @positionIndicator ?= new google.maps.Marker
          map: @map
          position: latLng
          icon: new google.maps.MarkerImage('/img/stop.png', new google.maps.Size(18, 18),
            new google.maps.Point(16, 3), new google.maps.Point(9, 9))
        @accuracyIndicator.setCenter latLng
        @accuracyIndicator.setRadius accuracy
        @positionIndicator.setPosition latLng
