define [
  'jquery'
  'underscore'
  'backbone'
  'async!http://maps.googleapis.com/maps/api/js?sensor=true' + if window.location.host is 'localhost' or window.location.protocol is 'file:' then '' else '&key=AIzaSyDZj9_A4WUDGph6cKf2A7VsFbDz6Pb7QBk'
], ($, _, Backbone) ->

  class MapView extends Backbone.View

    el: $('#map')

    render: ->
      @map = new google.maps.Map(@el,
        center: new google.maps.LatLng(60.171, 24.941) # Rautatieasema
        zoom: 16
        mapTypeId: google.maps.MapTypeId.ROADMAP
        mapTypeControlOptions:
          position: google.maps.ControlPosition.TOP_CENTER
      )

      Reitti.Event.on 'position:change', (position) =>
        _.once @centerMap(position)
        @displayCurrentPosition position

      Reitti.Event.on 'route:change', @drawRoute, @
      @

    clearRoute: ->
      @route.setMap null if @route

    drawRoute: (route) ->
      @clearRoute()
      shapes = leg.shape for leg in route[0].legs
      points = _.reduce shapes,
        (res, shape) -> res.concat shape,
        []
      latLngs = new google.maps.LatLng point.y, point.x for point in points


      @route = new google.maps.Polyline(
        map: @map
        path: latLngs
        strokeColor: '#0000ee'
        strokeWeight: 4
      )
      @panToNewBounds latLngs

    panToNewBounds: (latLngs) ->
      initialBounds = new google.maps.LatLngBounds()
      bounds = _.reduce latLngs,
        (currentBounds, latLng) -> currentBounds.extend latLng,
        initialBounds
      @map.fitBounds bounds

    centerMap: (position) ->
      latLng = new google.maps.LatLng position.coords.latitude, position.coords.longitude
      @map.setCenter latLng

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